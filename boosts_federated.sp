dashboard "BoostsFederated" {

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
        "[BoostsFederated](${local.host}/mastodon.dashboard.BoostsFederated)",
        "BoostsFederated"
      )
    }
  }

  container {

    graph {

      title = "boosts from server to server"

      node {
        category = category.server
        sql = <<EOQ
          select
            server as id,
            server as title,
            jsonb_build_object(
              'server', server,
              'reblog_server', reblog_server
            ) as properties
          from
            mastodon_toot_home
          where
            reblog_server is not null
          limit ${local.limit}
        EOQ
      }

      node {
        category = category.server
        sql = <<EOQ
          select
            reblog_server as id,
            reblog_server as title,
            jsonb_build_object(
              'server', server,
              'reblog_server', reblog_server
            ) as properties
          from
            mastodon_toot_home
          where
            reblog_server is not null
          limit ${local.limit}
        EOQ
      }

      edge {
        category = category.boost
        sql = <<EOQ
          select
            server as from_id,
            reblog_server as to_id,
            'boosts' as title
          from
            mastodon_toot_home
          where
            reblog_server is not null
          limit ${local.limit}
        EOQ
      }

    }

  }

}

