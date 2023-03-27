dashboard "TagExplore" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = replace(
        replace(
          "${local.menu}",
          "__HOST__",
          "${local.host}"
        ),
        "[TagExplore](${local.host}/mastodon.dashboard.TagExplore)",
        "TagExplore"
      )
    }
  }

  with "mastodon_tag_data" {
    sql = <<EOQ
      create or replace function public.mastodon_tag_data(tag text, max int) returns table (
        account_url text,
        tag text
      ) as $$
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
        account_url,
        tag
      from
        feed
      $$ language sql
    EOQ
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
      args = [ self.input.tag.value, self.input.limit.value]
      sql = <<EOQ
        select
          tag,
          count(*)
        from
          mastodon_tag_data($1, $2)
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
        args = [ self.input.tag.value, self.input.limit.value]
        sql = <<EOQ
          select
            account_url as id,
            regexp_match(account_url, '@.+') as title,
            jsonb_build_object(
              'account_url', mastodon_qualified_account_url(account_url)
            ) as properties
          from
            mastodon_tag_data($1, $2)
        EOQ
      }

      node {
        category = category.tag
        args = [ self.input.tag.value, self.input.limit.value]        
        sql = <<EOQ
          select
            tag as id,
            tag as title,
            jsonb_build_object(
              'tag', tag,
              'url', '${local.host}/mastodon.dashboard.TagExplore?input.tag=' || tag
            ) as properties
          from
            mastodon_tag_data($1, $2)
        EOQ
      }

      edge {
        args = [ self.input.tag.value, self.input.limit.value]        
        sql = <<EOQ
          select
            account_url as from_id,
            tag as to_id
          from
            mastodon_tag_data($1, $2)
        EOQ
      }

    }

  }


}

