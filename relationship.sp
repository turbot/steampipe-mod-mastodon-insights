dashboard "Relationships" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Favorites](${local.host}/mastodon.dashboard.Favorites)
🞄
[Followers](${local.host}/mastodon.dashboard.Followers)
🞄
[Following](${local.host}/mastodon.dashboard.Following)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[List](${local.host}/mastodon.dashboard.List)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Me](${local.host}/mastodon.dashboard.Me)
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
🞄
[Rate](${local.host}/mastodon.dashboard.Rate)
🞄
Relationships
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
🞄
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
    }
  }

  input "server" {
    base = input.server
  }

  container {

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
            mastodon_boosts()
          where
            server = $1
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
            mastodon_boosts()
          where
            server = $1
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
            mastodon_boosts()
          where
            server = $1
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
              'content', reblog ->> 'content'
            ) as properties
          from
            mastodon_boosts()
          where
            server = $1
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
            mastodon_boosts()
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
            mastodon_boosts()
          where
            server = $1
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
              'content', reblog ->> 'content'
            ) as properties
          from
            mastodon_boosts()
          where
            server = $1
        EOQ
      }

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
            mastodon_boosts()
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
            mastodon_boosts()
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
            mastodon_boosts()
        EOQ
      }

    }

  }

  with "mastodon_boosts" {
    sql = <<EOQ
      create or replace function public.mastodon_boosts()
      returns setof mastodon_toot as $$
        select
          *
        from
          mastodon_toot
        where
          timeline = 'home'
          and reblog_server is not null
          limit ${local.limit}
      $$ language sql;
    EOQ
  }

}

