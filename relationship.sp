dashboard "Relationships" {

  tags = {
    service = "Mastodon"
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

  with "recent_toots" {
    sql = <<EOQ
      create or replace function public.mastodon_recent_toots() returns table (
          server text, 
          reblog_server text,
          username text,
          display_name text,
          reblog_username text,
          reblog jsonb,
          account_url text,
          in_reply_to_account_id text
        ) as $$
        select 
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
        limit 20
      $$ language sql;
    EOQ
  }

  container {

    graph {
      type = "graph"

      category "server" {
        title = "server"
        color = "orange"
        icon = "heroicons-outline:cpu-chip"
      }      

      -- primary server
      node {
        sql = <<EOQ
          select
            server as id,
            server as title,
            'server' as category, -- why doesn't this work?
            jsonb_build_object(
              'server', server
            ) as properties,
          from public.mastodon_recent_toots()
        EOQ
      }

      -- reblog server
      node {
        sql = <<EOQ
          select
            reblog_server as id,
            reblog_server as title,
            'server' as category,
            jsonb_build_object(
              'server', reblog_server
            )
          from public.mastodon_recent_toots()
        EOQ
      }

      -- primary person
      node {
        sql = <<EOQ
          select
            username as id,
            display_name as title,
            jsonb_build_object(
              'type', 'primary',
              'display_name', display_name,
              'server', server
            ) as properties
          from
            public.mastodon_recent_toots()
        EOQ
      }

      -- reblog person
      node {
        sql = <<EOQ
          select
            reblog_username as id,
            reblog_username as title,
            jsonb_build_object(
              'type', 'reblog',
              'server', reblog_server,
              'display_name', reblog -> 'account' ->> display_name,
              'followers', reblog -> 'account' ->> 'followers_count',
              'following', reblog -> 'account' ->> 'following_count'
            ) as properties
          from 
            public.mastodon_recent_toots()
          where 
            reblog is not null
        EOQ
      }

      -- primary person to server
      edge {
        sql = <<EOQ
          select
            username as from_id,
            server as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'account_url', account_url,
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots()
        EOQ
      }

      edge {
        -- reblog person to server
        sql = <<EOQ
          select
            reblog_username as from_id,
            reblog_server as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'account_url', account_url,
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots()
        EOQ
      }

      edge {
        -- reblog person to server
        sql = <<EOQ
          select
            reblog_username as from_id,
            reblog_server as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'account_url', account_url,
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots()
        EOQ
      }

      edge {
        -- person boost person
        sql = <<EOQ
          select
            username as from_id,
            reblog_username as to_id,
            'boosts as title,
            jsonb_build_object(
              'account_url', account_url,
              'display_name', display_name
            ) as properties
          from
            public.mastodon_recent_toots()
          where
            reblog is not null
        EOQ
      }

    }

  }

}

