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

        -- node

        with server as (
          with data as (
            select * from mastodon_toot where timeline = 'home' limit 50
          ),
          server_data as (
            select
              (regexp_match(account_url, 'https://([^/]+)'))[1] as server
            from
                data
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

        -- node

        person as (
          with data as (
            select * from mastodon_toot where timeline = 'home' limit 50
          ),
          primary_person as (
            select distinct
              (regexp_match(account_url, '@(.+)'))[1] as id,
              null as from_id,
              null as to_id,
              display_name as title,
              jsonb_build_object(
                'display_name', display_name,
                'account_url', account_url
              ) as properties
            from
              data
          ),
          reblog_person as (
            select
              case when reblog -> 'account' ->> 'acct' ~ '@' then (regexp_match(reblog -> 'account' ->> 'acct', '^(.+)@'))[1]
              else reblog -> 'account' ->> 'acct'
              end as id,
              null as from_id,
              null as to_id,
              reblog -> 'account' ->> display_name as title,
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
          select  * from primary_person
          union
          select * from reblog_person
        ),

        -- edge

        person_server as (
          with data as (
            select * from mastodon_toot where timeline = 'home' limit 50
          )
          select distinct
            null as id,
            (regexp_match(account_url, '@(.+)'))[1] as from_id,
            (regexp_match(account_url, 'https://([^/]+)'))[1] as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'account_url', account_url,
              'display_name', display_name
            ) as properties
          from
            data
        ),

        -- edge

        person_boost_person as (
          with data as (
            select * from mastodon_toot where timeline = 'home' limit 50
          )
          select distinct
            null as id,
            (regexp_match(account_url, '@(.+)'))[1] as from_id,
            (regexp_match(account_url, 'https://([^/]+)'))[1] as to_id,
            'belongs to' as title,
            jsonb_build_object(
              'account_url', account_url,
              'display_name', display_name
            ) as properties
          from
            data
          where
              reblog is not null
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
              10
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


        select * from server
        union
        select * from person_server
        union
        select * from person

    EOQ
    }

  }

}

