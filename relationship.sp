dashboard "Relationships" {

  tags = {
    service = "Mastodon"
  }

  with "mastodon_recent_toots" {
    sql = <<EOQ
      create or replace function public.mastodon_recent_toots() returns setof mastodon_toot as $$
        select distinct
          *
        from 
          mastodon_toot 
        where 
          timeline = 'home'
         limit 50
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

  }



  container {

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


    graph {

      title = "boosts from a selected server"

      category "server" {
        color = "yellow"
        icon = "server"
        href  = "https://{{.properties.'server'}}"
      }

      category "reblog_server" {
        color = "brown"
        icon = "server"
        href  = "https://{{.properties.'server'}}"
      }

      category "user" {
        color = "orange"
        icon = "user"
        href  = "https://{{.properties.'server'}}/@{{.properties.'username'}}"
      }

      category "reblog_user_edge" {
        color = "green"
        href = "https://{{.properties.'server'}}/@{{.properties.'reblog_username'}}@{{.properties.'reblog_server'}}/{{.properties.'id'}}"
      }

      category "reblogged_user_node" {
        color = "green"
        icon = "user"
        href = "https://{{.properties.'server'}}/@{{.properties.'reblog_username'}}@{{.properties.'reblog_server'}}/{{.properties.'id'}}"
      }



      node {
      // primary server
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            server as id,
            server as title,
            jsonb_build_object(
                'server', server,
                'reblog_server', reblog_server
              ) as properties,
            case when $1 = server then 'server' else 'reblog_server' end as category
          from public.mastodon_recent_toots_for_server($1)
        EOQ
      }

      node { // reblog server
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_server as id,
            reblog_server as title,
            'reblog_server' as category,
            jsonb_build_object(
              'server', server,
              'reblog_server', reblog_server
            ) as properties,
            case when $1 = reblog_server then 'server' else 'reblog_server' end as category
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
              'username', username,
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
            'reblogged_user_node' as category,
            jsonb_build_object(
              'type', 'reblog',
              'server', reblog_server,
              'id', id,
              'username', username,
              'display_name', display_name,
              'server', server,
              'reblog_server', reblog_server,
              'reblog_username', reblog_username,
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
              'username', username,
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
              'username', username,
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
            'reblog_user_edge' as category,
            jsonb_build_object(
              'id', id,
              'username', username,
              'display_name', display_name,
              'server', server,
              'reblog_server', reblog_server,
              'reblog_username', reblog_username
            ) as properties
          from
            public.mastodon_recent_toots_for_server($1)
          where
            reblog is not null
        EOQ
      }

    }

  }

  container {

    graph {

      title = "boosts from server to server"

      category "server" {
        color = "yellow"
        icon = "server"
        href  = "http://localhost:9194/mastodon.dashboard.Relationships?input.server={{.properties.'server'}}"
      }

      category "reblog_server" {
        color = "brown"
        icon = "server"
        href  = "https://{{.properties.'server'}}"
      }

      node {
      // primary servers
        sql = <<EOQ
          select distinct
            server as id,
            server as title,
            'server' as category,
            jsonb_build_object(
                'server', server,
                'reblog_server', reblog_server
              ) as properties
          from 
            public.mastodon_recent_toots()
        EOQ
      }

      node { // reblog servers
        args = [ self.input.server.value ]
        sql = <<EOQ
          select
            reblog_server as id,
            reblog_server as title,
            'reblog_server' as category,
            jsonb_build_object(
              'server', server,
              'reblog_server', reblog_server
            ) as properties,
              case when $1 = reblog_server then 'server' else 'reblog_server' end as category
          from public.mastodon_recent_toots_for_server($1)
        EOQ
      }


      edge { //  server reblog server
        sql = <<EOQ
          with data as (
            select distinct
              server as from_id,
              reblog_server as to_id,
              'boosts' as title
            from
              public.mastodon_recent_toots()
            where
              reblog is not null
          )
          select
            *
          from 
            data
        EOQ
      }

    }

  }    


}

