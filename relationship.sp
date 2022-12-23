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
          from server_data
        ),

        -- person nodes

        person as (
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
            url,
            user_name || '@' || server as id,
            null as from_id,
            null as to_id,
            user_name as title,
            jsonb_build_object(
              'type', 'person_author',
              'server', server,
              'display_name', display_name
            ) as properties
          from 
            person_data
          where
            url != ''
        ),

        -- person-server edges
        
        person_server as (
          select distinct
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
            and (regexp_match(url, 'https://([^/]+)'))[1] is not null
          limit
            50          
        ),

        -- person-person edges

        person_boost_person as (
          with toot_data as (
            select
              *,
              (regexp_match(url, 'https://([^/]+)'))[1] as server
            from
              mastodon_toot
            where
              timeline = 'home'
            limit
              50
          ),
          person_data as (
            select
              null as id,
              user_name || '@' || server as from_id,
              reblog -> 'account' ->> 'acct' as to_id,
              'boosts' as title,
              jsonb_build_object(
                'reblog', reblog
              ) as properties
            from 
              toot_data
            where
              reblog is not null
          )
          select
            *
          from
            person_data
          where
            from_id is not null
            and to_id is not null
        ),

        person_reply_person as (
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
            ( select acct from mastodon_account where id = in_reply_to_account_id )  as to_id,
            'replies to' as title,
            jsonb_build_object(
              'user_name', user_name,
              'reply_to_user_name', ( select acct from mastodon_account where id = in_reply_to_account_id )
            ) as properties
          from 
            data
          where
            in_reply_to_account_id is not null
        )


        select * from person
        union
        select * from person_reply_person

    EOQ
    }

  }

}

