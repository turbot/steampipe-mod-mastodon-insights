dashboard "Relationships" {

  tags = {
    service = "Mastodon"
  }

  container {
    card {
      width = 4
      sql = "select distinct _ctx ->> 'connection_name' as server from mastodon_weekly_activity"
    }
  }

  container {

    graph {
      title     = "People belonging to servers + people boosting people"
      type      = "graph"
      sql = <<EOQ

        -- server nodes

        with server as (
          with server_data as (
            select
              (regexp_match(url, 'https://([^/]+)'))[1] as server
            from
                mastodon_toot
            where
                timeline = 'home'
                and url != ''
            limit
              50
          )
          select distinct
            server as id,
            null as from_id,
            null as to_id,
            server as title,
            jsonb_build_object(
              'server', server
            ) as properties
          from
            server_data
        ),

        -- person nodes

        person as (

          with person_direct_data as (
            with person_data as (
              select
                *,
                (regexp_match(url, 'https://([^/]+)'))[1] as server
              from
                mastodon_toot
              where
                timeline = 'home'
              limit
                50
            )
            select distinct
              user_name as id,
              null as from_id,
              null as to_id,
              user_name as title,
              jsonb_build_object(
                'display_name', display_name,
                'followers', account ->> 'followers_count',
                'following', account ->> 'following_count'
              ) as properties
            from 
              person_data
            where
              server is not null
          ),

          person_indirect_data as (
            with data as (
              select
                *
              from
                mastodon_toot
              where
                timeline = 'home'
              limit
                50
            )
            select
              reblog -> 'account' ->> 'username' as id,
              null as from_id,
              null as to_id,
              user_name as title,
              jsonb_build_object(
                'display_name', reblog -> 'account' ->> display_name,
                'followers', reblog -> 'account' ->> 'followers_count',
                'following', reblog -> 'account' ->> 'following_count'
              ) as properties
            from
              data
            where
              reblog is not null            
          )

          select * from person_direct_data
          union
          select * from person_indirect_data

        ),

        -- person-server edges
        
        person_server as (
          select
            null as id,
            user_name as from_id,
            (regexp_match(url, 'https://([^/]+)'))[1] as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'user_name', user_name
            ) as properties
          from
            mastodon_toot 
          where
            timeline = 'home'
          limit
            50          
        ),

        -- person-person edges

        person_person as (
          with data as (
            select
              *
            from
              mastodon_toot 
            where
              timeline = 'home'
            limit
              50
          )
          select
            null as id,
            user_name as from_id,
            reblog -> 'account' ->> 'username' as to_id,
            'boosts' as title,
            jsonb_build_object(
              'user_name', user_name
            ) as properties
          from 
            data
          where
            reblog is not null          
        )

        select * from server
        union
        select * from person
        union
        select * from person_server
        union
        select * from person_person

    EOQ
    }

  }

}

