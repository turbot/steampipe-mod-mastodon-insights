query "hashtag_detail" {
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
        u.recent_uses,
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
        recent_uses > 0
      order by 
        recent_uses desc, published desc
    EOQ
    param "hashtag" {}
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