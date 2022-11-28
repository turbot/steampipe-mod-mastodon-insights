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
      toot,
      boosted 🢁,
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
      toot,
      boosted 🢁,
      in_reply_to 🡼,
      url
    from
      toots
    order by
      created_at desc
  EOQ
  param "search_term" {}
}

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
    select
      url,
      display_name,
      to_char(created_at, 'YYYY-MM-DD') as created_at,
      followers_count as followers,
      following_count as following,
      statuses_count as toots,
      note
    from
      mastodon_followers
    order by
      followers_count desc
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
    with following as (
      select
        *
      from
        mastodon_following
    )
    select
      f.url,
      f.display_name,
      --m.followed_by,
      to_char(f.created_at, 'YYYY-MM-DD') as created_at,
      f.followers_count as followers,
      f.following_count as following,
      f.statuses_count as toots,
      f.note
    from
      following f
    --join
    --  mastodon_relationship m
    --on
    --  f.id = m.id
    order by
      created_at desc
  EOQ
}


query "notification" {
  sql = <<EOQ
    select
      category,
      account_url,
      display_name,
      to_char(created_at, 'YYYY-MM-DD HH24:MI') as created_at,
      status_url
    from
      mastodon_notification
    order by
      created_at desc
  EOQ
}

query "users_by_wordcount" {
  sql = <<EOQ
    with toots as (
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