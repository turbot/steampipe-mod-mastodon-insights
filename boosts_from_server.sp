dashboard "BoostsFromServer" {

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
        "[BoostsFromServer](${local.host}/mastodon.dashboard.BoostsFromServer)",
        "BoostsFromServer"
      )
    }
  }

  container {
    input "server" {
      base = input.server
    }

    graph {

      title = "boosts from selected server"

      node {
        category = category.boosted_server
        args = [ self.input.server.value ]
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
            and server = $1
          limit ${local.limit}
        EOQ
      }

      // Note: the sequence of nodes matters. If mastodon.social is both a server and
      // reblog_server, we want this node here to have the selected_server category
      node {
        category = category.selected_server
        args = [ self.input.server.value ]
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
            and server = $1
          limit ${local.limit}
        EOQ
      }

      node {
        category = category.person
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            username as id,
            display_name as title,
            jsonb_build_object(
              'server', server,
              'reblog_server', reblog_server,
              'instance_qualified_account_url', instance_qualified_account_url
            ) as properties
          from
            mastodon_toot_home
          where
            reblog_server is not null
            and server = $1
          limit ${local.limit}
        EOQ
      }

      node {
        category = category.boosted_person
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_username as id,
            reblog_username as title,
            jsonb_build_object(
              'server', server,
              'reblog_server', reblog_server,
              'instance_qualified_reblog_url', instance_qualified_reblog_url,
              'content', reblog_content
            ) as properties
          from
            mastodon_toot_home
          where
            reblog_server is not null
            and server = $1
          limit ${local.limit}
        EOQ
      }

      edge {
        sql = <<EOQ
          select
            username as from_id,
            server as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'username', username,
              'server', server,
              'reblog_username', reblog_username,
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
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_username as from_id,
            reblog_server as to_id,
            'belongs to' as title
          from
            mastodon_toot_home
          where
            reblog_server is not null
            and server = $1
          limit ${local.limit}
        EOQ
      }

      edge {
        category = category.boost
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            username as from_id,
            reblog_username as to_id,
            'boosts' as title,
            jsonb_build_object(
              'reblog_username', reblog_username,
              'reblog_server', reblog_server,
              'content', reblog_content
            ) as properties
          from
            mastodon_toot_home
          where
            reblog_server is not null
            and server = $1
          limit ${local.limit}
          EOQ
      }

    }

  }

}

