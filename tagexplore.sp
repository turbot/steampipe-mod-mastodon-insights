dashboard "TagExplore" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
[Blocked](${local.host}/mastodon.dashboard.Blocked)
•
[Direct](${local.host}/mastodon.dashboard.Direct)
•
[Favorites](${local.host}/mastodon.dashboard.Favorites)
•
[Followers](${local.host}/mastodon.dashboard.Followers)
•
[Following](${local.host}/mastodon.dashboard.Following)
•
[Home](${local.host}/mastodon.dashboard.Home)
•
[List](${local.host}/mastodon.dashboard.List)
•
[Local](${local.host}/mastodon.dashboard.Local)
•
[Me](${local.host}/mastodon.dashboard.Me)
•
[Notification](${local.host}/mastodon.dashboard.Notification)
•
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
•
[Rate](${local.host}/mastodon.dashboard.Rate)
•
[Relationships](${local.host}/mastodon.dashboard.Relationships)
•
[Remote](${local.host}/mastodon.dashboard.Remote)
•
[Server](${local.host}/mastodon.dashboard.Server)
•
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
•
TagExplore
•
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
    }
  }

  with "mastodon_qualified_account_url" {
    sql = <<EOQ
      create or replace function public.mastodon_qualified_account_url(url text) returns text as $$
        with data as (
          select
            (regexp_match(url, 'https://([^/]+)'))[1] as server,
            (regexp_match(url, '@(.+)$'))[1] as person,
            ( select name from mastodon_server) as home_server
        )
        select
          case
            when server != home_server then 'https://elk.zone/' || home_server || '/@' || person || '@' || server
            else 'https://elk.zone/' || home_server || '/@' || person
          end as account_url
        from
          data
      $$ language sql
    EOQ
  }


  container {

    table {
      width = 4
      query = query.connection
    }

    input "tag" {
      width = 2
      type = "text"
      title = "tag"
    }

    input "limit" {
      base = input.limit
    }

    table "tag_page" {
      width = 3
      args = [ self.input.tag.value ]
      sql = <<EOQ
        select 'https://' || ( select name from mastodon_server ) || '/tags/' || $1 as "tag page"
        union
        select 'https://' || 'elk.zone/' || ( select name from mastodon_server ) || '/tags/' || $1 as "tag page"
      EOQ
    }


  }

  container {

    chart {
      width = 4
      type = "donut"
      args = [ with.data.rows[*].account_url_tag_note ]
      sql = <<EOQ
        with data as (
          select 
            jsonb_array_elements_text($1::jsonb)::jsonb as account_url_tag_note
        ),
        unnested as (
          select
            account_url_tag_note->>'account_url' as account_url,
            account_url_tag_note->>'tag' as tag
          from
            data
        )
        select
          tag,
          count(*)
        from
          unnested
        group by 
          tag
        order by
          count desc

      EOQ      
    }


  }

  container {
    
    graph {

      node {
        category = category.tagger
        args = [ with.data.rows[*].account_url_tag_note ]
        sql = <<EOQ
          with data as (
            select 
              jsonb_array_elements_text($1::jsonb)::jsonb as account_url_tag_note
          ),
          unnested as (
            select
              account_url_tag_note->>'account_url' as account_url,
              account_url_tag_note->>'tag' as tag,
              account_url_tag_note->>'note' as note
            from
              data
          )
          select
            account_url as id,
            regexp_match(account_url, '@.+') as title,
            jsonb_build_object(
              'account_url', mastodon_qualified_account_url(account_url),
              'note', note
            ) as properties
          from
            unnested
        EOQ
      }

      node {
        category = category.tag
        args = [ with.data.rows[*].account_url_tag_note ]
        sql = <<EOQ
          with data as (
            select 
              jsonb_array_elements_text($1::jsonb)::jsonb as account_url_tag_note
          ),
          unnested as (
            select
              account_url_tag_note->>'account_url' as account_url,
              account_url_tag_note->>'tag' as tag
            from
              data
          )
          select
            tag as id,
            tag as title,
            jsonb_build_object(
              'tag', tag,
              'url', '${local.host}/mastodon.dashboard.TagExplore?input.tag=' || tag
            ) as properties
          from
            unnested
        EOQ
      }

      edge {
        args = [ with.data.rows[*].account_url_tag_note ]
        sql = <<EOQ
          with data as (
            select 
              jsonb_array_elements_text($1::jsonb)::jsonb as account_url_tag_note
          ),
          unnested as (
            select
              account_url_tag_note->>'account_url' as account_url,
              account_url_tag_note->>'tag' as tag
            from
              data
          )
          select
            account_url as from_id,
            tag as to_id
          from
            unnested
        EOQ
      }

    }

  }

  with "data" {
    args = [ self.input.tag.value, self.input.limit.value]
    sql = <<EOQ
      with data as (
        with feed_link as (  -- this extra cte level should not be necessary
          select 'https://' || ( select name from mastodon_server ) || '/tags/' || $1 || '.rss' as feed_link
        )
        select feed_link from feed_link
      ),
      feed as (
          select
            (regexp_match(link, '(.+)/\d+$'))[1] as account_url,
            jsonb_array_elements_text(categories) as tag
          from
            rss_item r
          join
            data d
          using (feed_link)
          limit $2
      )
      select distinct on (account_url, tag)
        jsonb_build_object(
          'account_url', account_url,
          'tag', tag,
          'note', case
            when account_url is not null then (select note from mastodon_search_account where query = account_url)
            else ''
            end
        ) as account_url_tag_note
      from
        feed
    EOQ
  }

}

