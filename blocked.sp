dashboard "Blocked" {

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
        "[Blocked](${local.host}/mastodon.dashboard.Blocked)",
        "Blocked"
      )
    }
  }

  with "blocking_servers"  {
    sql = <<EOQ
      create or replace function public.blocking_servers(max int) returns table (
        blocking_server text,
        blocked_server text
      ) as $$
      with servers as (
        select distinct
          server as domain,
          'https://' || server as server_url
        from
          mastodon_toot_home
        limit max
      ),
      blocking_and_blocked as (
        select distinct
          s.domain as blocking_domain,
          d.domain as blocked_domain
        from
          servers s
        join
          mastodon_domain_block d
        on
          s.server_url = d.server
      )
      select
        blocking_domain,
        blocked_domain
      from
        blocking_and_blocked
      order by
        blocking_domain, blocked_domain
      $$ language sql
    EOQ
  }

  with "blocked_servers"{
    sql = <<EOQ
      create or replace function public.blocked_servers(max int) returns table (
        blocked_server text,
        blocking_server text
      ) as $$
      with servers as (
        select
          server as domain,
          'https://' || server as server
        from
          mastodon_toot_home
        limit max
      )
      select distinct
        d.domain as blocked_domain,
        s.domain as blocking_domain
      from
        servers s
      join
        mastodon_domain_block d
      on
        s.server = d.server
      order by
        blocked_domain, blocking_domain
      $$ language sql
    EOQ
  }

  with "blocked_and_blocking_servers" {
    sql = <<EOQ
      create or replace function public.blocked_and_blocking_servers(max int) returns table (
        blocked_server text,
        blocking_server text
      ) as $$
      select
        blocked_server,
        blocking_server
      from
        blocked_servers(max)
      where
        blocked_server in (select blocking_server from blocking_servers(max) )
      $$ language sql
    EOQ
  }

  container {

    table {
      width = 4
      query = query.connection
    }

  }

  container {

    container {

      width = 6

      input "blocking_server" {
        title = "blocking server"
        sql = <<EOQ
          with servers as (
            select distinct
              server as domain,
              'https://' || server as server_url
            from
              mastodon_toot_home
            limit ${local.limit}
          ),
          blocking_and_blocked as (
            select distinct
              s.domain as blocking_domain,
              d.domain as blocked_domain
            from
              servers s
            join
              mastodon_domain_block d
            on
              s.server_url = d.server
          )
          select distinct
            blocking_domain as label,
            blocking_domain as value
          from
            blocking_and_blocked
          where
            blocked_domain in ( select blocked_server from blocked_servers(${local.limit}) )
        EOQ
      }

      graph {

        node {
          base = node.blocking_server
        }

        node {
          base = node.blocked_server
        }

        node {
          base = node.blocked_and_blocking_server
        }

        edge {
          args = [ self.input.blocking_server.value ]
          base = edge.match_blocked_server
        }

        edge {
          args = [ self.input.blocking_server.value ]
          base = edge.match_blocking_server
        }

      }

      table {
        args = [ self.input.blocking_server.value ]
        sql = <<EOQ
          select
            'https://' || blocked_server as blocked_server,
            (  select count(*) from blocked_servers(${local.limit}) where blocked_server = bs.blocked_server) as blocking_servers,
            '${local.host}/mastodon.dashboard.Blocked?input.blocked_server=' || blocked_server as graph_link
          from
            blocking_servers(${local.limit}) bs
          where blocking_server = $1
        EOQ
      }

    }

    container {

      width = 6

      input "blocked_server" {
        title = "blocked server"
        sql = <<EOQ
          select distinct
            blocked_server as label,
            blocked_server as value
          from
            blocked_servers(${local.limit})
          order by
            blocked_server
        EOQ
      }


      graph {

        node {
          base = node.blocking_server
        }

        node {
          base = node.blocked_server
        }

        node {
          base = node.blocked_and_blocking_server
        }

        edge {
          args = [ self.input.blocked_server.value ]
          base = edge.match_blocked_server
        }

        edge {
          args = [ self.input.blocked_server.value ]
          base = edge.match_blocking_server
        }


      }

      table {
        args = [ self.input.blocked_server.value ]
        sql = <<EOQ
          select
            blocking_server,
            ( select count(*) from blocked_servers(${local.limit}) where blocking_server = bs.blocking_server ) as blocked_servers,
            '${local.host}/mastodon.dashboard.Blocked?input.blocking_server=' || blocking_server as graph_link
          from
            blocking_servers(${local.limit}) bs
          where blocked_server = $1
        EOQ
      }


    }

  }

/*
  container {

    title = "tables"

    table {
      width = 3
      title = "blocked servers"
      sql = <<EOQ
        select * from blocked_servers(${local.limit})
      EOQ
    }

    table {
      width = 3
      title = "blocked and blocking servers"
      sql = <<EOQ
        select * from blocked_and_blocking_servers(${local.limit})
      EOQ
    }

  }
*/

}

node "blocking_server" {
  category = category.blocking_server
  sql = <<EOQ
    with servers as (
      select distinct
        blocking_server,
        blocked_server
      from
        blocking_servers(${local.limit})
    )
    select
      blocking_server as id,
      blocking_server as title,
      jsonb_build_object(
        'blocked_server', blocked_server,
        'blocking_server', blocking_server,
        'link_to', blocking_server
      ) as properties
    from
      servers
    order by
      blocking_server
  EOQ
}

node "blocked_server" {
  category = category.blocked_server
  sql = <<EOQ
    with servers as (
      select distinct
        blocked_server,
        blocking_server
      from
        blocked_servers(${local.limit})
      where
        blocked_server not in ( select blocked_server from blocked_and_blocking_servers(${local.limit})  )
    )
    select
      blocked_server as id,
      blocked_server as title,
      jsonb_build_object(
        'blocked_server', blocked_server,
        'blocking_server', blocking_server,
        'link_to', blocked_server
      ) as properties
    from
      servers
    order by
      blocked_server
  EOQ
}

node "blocked_and_blocking_server" {
  category = category.blocked_and_blocking_server
  sql = <<EOQ
    with servers as (
      select distinct
        blocked_server,
        blocking_server
      from
        blocked_and_blocking_servers(${local.limit})
    )
    select
      blocked_server as id,
      blocked_server as title,
      jsonb_build_object(
        'blocked_server', blocked_server,
        'blocking_server', blocking_server,
        'link_to', blocked_server
      ) as properties
    from
      servers
    order by
      blocked_server
  EOQ
}

edge "match_blocking_server" {
  sql = <<EOQ
    with servers as (
      select distinct
        blocking_server,
        blocked_server
      from
        blocking_servers(${local.limit})
    where
      blocking_server = $1
    )
    select
      blocking_server as from_id,
      blocked_server as to_id
    from
      servers
  EOQ
}

edge "match_blocked_server" {
  sql = <<EOQ
    with servers as (
      select distinct
        blocking_server,
        blocked_server
      from
        blocking_servers(${local.limit})
    where
      blocked_server = $1
    )
    select
      blocking_server as from_id,
      blocked_server as to_id
    from
      servers
  EOQ
}
