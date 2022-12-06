query "timeline" {
  sql = <<EOQ
    with toots as (
      select
        account_url as account,
        display_name as person,
        case
          when reblog -> 'url' is null then
            content
          else
            reblog_content
        end as toot,
        to_char(created_at, 'MM-DD HH24:MI') as created_at,
        case
          when reblog -> 'url' is not null then '🢁'
          else ''
        end as boosted,
        case
          when in_reply_to_account_id is not null then '🡼 ' || ( select acct from mastodon_account where id = in_reply_to_account_id )
          else ''
        end as in_reply_to,
        case
          when reblog -> 'url' is not null then reblog ->> 'url'
          else url
        end as url
      from
        mastodon_toot
      where
        timeline = $1
      limit ${local.limit}
    )
    select
      account,
      person,
      boosted 🢁,
      toot,
      in_reply_to 🡼,
      url
    from
      toots
    order by
      created_at desc
  EOQ
  param "timeline" {}
}

query "search_status" {
  sql = <<EOQ
    with toots as (
      select
        account_url as account,
        display_name as person,
        case
          when reblog -> 'url' is null then
            content
          else
            reblog_content
        end as toot,
        to_char(created_at, 'MM-DD HH24:MI') as created_at,
        case
          when reblog -> 'url' is not null then '🢁'
          else ''
        end as boosted,
        case
          when in_reply_to_account_id is not null then '🡼 ' || ( select acct from mastodon_account where id = in_reply_to_account_id )
          else ''
        end as in_reply_to,
        case
          when reblog -> 'url' is not null then reblog ->> 'url'
          else url
        end as url
      from
        mastodon_toot
      where
        timeline = 'search_status'
        and query = $1
      limit ${local.limit}
    )
    select
      account,
      person,
      boosted 🢁,
      toot,
      in_reply_to 🡼,
      url
    from
      toots
    order by
      created_at desc
  EOQ
  param "search_term" {}
}

query "favorite" {
  sql = <<EOQ
    with toots as (
      select
        account_url as account,
        display_name as person,
        case
          when reblog -> 'url' is null then
            content
          else
            reblog_content
        end as toot,
        to_char(created_at, 'MM-DD HH24:MI') as created_at,
        case
          when reblog -> 'url' is not null then '🢁'
          else ''
        end as boosted,
        case
          when in_reply_to_account_id is not null then '🡼 ' || ( select acct from mastodon_account where id = in_reply_to_account_id )
          else ''
        end as in_reply_to,
        case
          when reblog -> 'url' is not null then reblog ->> 'url'
          else url
        end as url
      from
        mastodon_favorite
    )
    select
      account,
      person,
      boosted 🢁,
      toot,
      in_reply_to 🡼,
      url
    from
      toots
    order by
      created_at desc
    limit ${local.limit}
  EOQ
}

/*
The duplicate code in the above three queries could be DRYed out using a Postgres function parameterized by table name. But there's
not currently a standard way to deploy a mod that defines and uses functions. If we could alternatively parameterize queries by 
table name in HCL that would be very nice. 
*/

query "search_hashtag" {
  sql = <<EOQ
    with data as (
      select 
        _ctx ->> 'connection_name' as connection,
        name,
        url,
        ( jsonb_array_elements(history) ->> 'uses' )::int as uses
      from 
        mastodon_search_hashtag 
      where 
        query = $1
      ),
      uses as (
        select 
          connection,
          name,
          url || '.rss' as feed_link,
          sum(uses) as recent_uses
        from 
          data 
        group 
          by connection, name, url
      )
      select
        u.connection,
        u.name,
        r.guid as link,
        to_char(r.published, 'YYYY-MM-DD') as published,
        r.categories
      from
        uses u
      join
        rss_item r
      on 
        r.feed_link = u.feed_link
      where
        recent_uses > 1
      order by 
        recent_uses desc, published desc
    EOQ
    param "search_term" {}
}

query "search_people" {
  sql = <<EOQ
    with data as (
      select
        id,
        url,
        display_name as person,
        to_char(created_at, 'YYYY-MM-DD') as created_at,
        followers_count,
        following_count,
        statuses_count as toots,
        note
      from 
        mastodon_search_account
      where 
        query = $1
      order by
        display_name
    )
    select
      d.url,
      d.person,
      r.following,
      r.followed_by,
      d.created_at,
      d.followers_count,
      d.following_count,
      d.toots,
      d.note
    from
      data d
    join
      mastodon_relationship r
    on
      d.id = r.id
    order by following desc
  EOQ
  param "search_term" {}
}

query "followers" {
  sql = <<EOQ
    with data as (
      select
        l.title as list,
        a.*
      from
        mastodon_list l
      join
        mastodon_list_account a
      on
        l.id = a.list_id
    )
    select
      d.list,
      f.url,
      f.username,
      f.display_name,
      to_char(f.created_at, 'YYYY-MM-DD') as created_at,
      f.followers_count as followers,
      f.following_count as following,
      f.statuses_count as toots,
      f.note
    from
      mastodon_followers f
    left join
      data d
    on
      f.id = d.id
    order by
      d.list, followers desc
  EOQ
}

/*
Joining with `mastodon_relationship` is possible, and useful -- I want to see at a glance 
if a person I follow has followed me back! -- but not yet practical. The API's `accounts/relationships` 
endpoint takes an array of ids, but the `mastodon_relationship` table for now only takes one id at a time because
you can't make an URL like `accounts/relationships?id[]=1&id[]=2...&id[]=500`. The one-at-a-time approach
is not only slow, but worse, quickly exhausts the 300-API-calls-per-5-minutes limit if you are following
hundreds of people.

TBD: Work out a way to query `mastodon_relationship` with batches of (10? 100?) ids.

Meanwhile, see query.search_people, this approach is practical there if the query yields a small result set.
*/
query "following" {
  sql = <<EOQ
    with data as (
      select
        l.title as list,
        a.*
      from
        mastodon_list l
      join
        mastodon_list_account a
      on
        l.id = a.list_id
    )
    select
      d.list,
      f.url,
      f.username,
      f.display_name,
      to_char(f.created_at, 'YYYY-MM-DD') as created_at,
      f.followers_count as followers,
      f.following_count as following,
      f.statuses_count as toots,
      f.note
    from 
      mastodon_following f
    left join
      data d
    on
      f.id = d.id
    order by
      d.list, followers desc
  EOQ
}

query "notification" {
  sql = <<EOQ
    with notifications as (
      select
        category,
        account_url,
        account_id,
        display_name,
        to_char(created_at, 'MM-DD HH24:MI') as created_at,
        status_url,
        status_content
      from
        mastodon_notification
    )
    select
      n.category,
      n.account_url,
      n.display_name,
      r.following,
      r.followed_by,
      n.created_at,
      n.status_url,
      substring(n.status_content from 1 for 20) as toot
    from
      notifications n
    join
      mastodon_relationship r
    on
      r.id = n.account_id
    order by
      n.created_at desc
    limit ${local.limit}
  EOQ
}

query "list" {
  sql = <<EOQ
    with list_ids as (
      select
        id,
        title as list
      from
        mastodon_list
    ),
    data as (
      select
        l.list,
        t.user_name,
        t.display_name,
        t.url,
        to_char(t.created_at, 'MM-DD HH24:MI') as created_at,
        to_char(t.created_at, 'MM-DD HH24') as hour,
        t.content as toot
      from
        mastodon_toot t
      join
        list_ids l
      on
        l.id = t.list_id
      where
        timeline = 'list'
    )
    select distinct on (list, user_name, display_name, hour)
      list,
      user_name,
      display_name,
      url,
      hour,
      toot
    from
      data
    order by
      hour desc, list, user_name, display_name
  EOQ
}

query "my_toots" {
  sql = <<EOQ
      select
        to_char(created_at, 'MM-DD HH24:MI') as created_at,
        case
          when reblog -> 'url' is not null then '🢁'
          else ''
        end as boosted,
        case
          when reblog -> 'url' is null then
            content
          else
            reblog_content
        end as toot,
        case
          when in_reply_to_account_id is not null then '🡼 ' || ( select acct from mastodon_account where id = in_reply_to_account_id )
          else ''
        end as in_reply_to,
        case
          when reblog -> 'url' is not null then reblog ->> 'url'
          else url
        end as url
      from
        mastodon_toot
      where 
        timeline = 'me'
      order by
        created_at desc
  EOQ
}

query "users_by_wordcount" {
  sql = <<EOQ
    with toots as (o
      select
        *,
        regexp_matches(content, '\s+', 'g')  as match
      from 
        mastodon_local_toot
      limit 300
    ),
    words as (
      select
        id,
        user_name,
        display_name,
        created_at,
        cardinality(array_agg(match)) as words
      from 
        toots
      where
        content != ''
      group by
        id, user_name, display_name, created_at
    )
    select
      *
    from
      words
    order by
      created_at desc
  EOQ
}