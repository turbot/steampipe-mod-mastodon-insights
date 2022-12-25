dashboard "Relationships" {

  tags = {
    service = "Mastodon"
  }

  with "mastodon_recent_toots" {
    sql = <<EOQ
      create or replace function public.mastodon_recent_toots() returns setof mastodon_toot as $$
        with data as (
          select distinct
            server, 
            reblog_server,
            username,
            display_name,
            reblog_username,
            reblog,
            account_url,
            in_reply_to_account_id
          from 
            mastodon_toot 
          where 
            timeline = 'home'
          )
          select
            *
          from
            data
        limit 100
      $$ language sql;
    EOQ
  }

  with "mastodon_recent_toots_for_server" {
    sql = <<EOQ
      create or replace function public.mastodon_recent_toots_for_server(selected_server text) returns setof mastodon_toot as $$
        select
          *
        from
          mastodon_recent_toots()
        where
          server = selected_server
      $$ language sql;
    EOQ
  }

  container {

    table {
      width = 4
      sql = <<EOQ
      select 
        _ctx ->> 'connection_name' as connection,
        name as server
      from
        mastodon_server
      EOQ
    }

    input "server" {
      width = 2
      type = "select"
      sql = <<EOQ
        with data as (
          select 
            server,
            count(*)
          from
            mastodon_recent_toots()
          group by
            server
        )
        select 
          server || '(' || count || ')' as label,
          server as value
        from
          data
        order by 
          server
      EOQ
    }

  }

  container {

    graph {
      type = "graph"

      category "server" {
        color = "yellow"
        icon = "server"
      }

      category "user" {
        color = "orange"
        icon = "user"
      }


      node {
      // primary server
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            server as id,
            server as title,
            'server' as category,
            jsonb_build_object(
              'server', server
            ) as properties
          from public.mastodon_recent_toots_for_server($1)
        EOQ
      }

      node { // reblog server
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_server as id,
            reblog_server as title,
            'server' as category,
            jsonb_build_object(
              'server', reblog_server
            )
          from public.mastodon_recent_toots_for_server($1)
        EOQ
      }

      node { // primary person
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            username as id,
            display_name as title,
            'user' as category,
            jsonb_build_object(
              'type', 'primary',
              'display_name', display_name,
              'server', server
            ) as properties
          from
            public.mastodon_recent_toots_for_server($1)
        EOQ
      }

      node { // reblog person
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_username as id,
            reblog_username as title,
            'user' as category,
            jsonb_build_object(
              'type', 'reblog',
              'server', reblog_server,
              'display_name', reblog -> 'account' ->> display_name,
              'followers', reblog -> 'account' ->> 'followers_count',
              'following', reblog -> 'account' ->> 'following_count'
            ) as properties
          from 
            public.mastodon_recent_toots_for_server($1)
          where 
            reblog is not null
        EOQ
      }

      edge { // primary person to server
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            username as from_id,
            server as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots_for_server($1)
        EOQ
      }

      edge { // reblog person to server
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_username as from_id,
            reblog_server as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots_for_server($1)
        EOQ
      }

      edge { // person boost person
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            username as from_id,
            reblog_username as to_id,
            'boosts' as title,
            jsonb_build_object(
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots_for_server($1)
          where
            reblog is not null
        EOQ
      }

    }

  }

}

