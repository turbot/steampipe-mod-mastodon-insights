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
    select 
      url,
      display_name as person,
      followers_count,
      following_count,
      note
    from 
      mastodon_search_account
    where 
      query = $1
    order by
      display_name
  EOQ
  param "search_term" {}
}


query "notification" {
  sql = <<EOQ
    select
      category,
      to_char(created_at, 'YYYY-MM-DD HH24::MI') as created_at,
      account,
      url
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