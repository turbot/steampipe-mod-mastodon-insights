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
          primary_server as (
            select distinct
              (regexp_match(account_url, 'https://([^/]+)'))[1] as id,
              null as from_id,
              null as to_id,
              (regexp_match(account_url, 'https://([^/]+)'))[1] as title,
              jsonb_build_object(
              'server', (regexp_match(account_url, 'https://([^/]+)'))[1]
              ) as properties
            from data
          )
          select * from primary_server
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
                'type', 'primary',
                'display_name', display_name,
                'account_url', account_url
              ) as properties
            from
              data
          ),
          reblog_person as (
            select
              case 
                when reblog -> 'account' ->> 'acct' ~ '@' then (regexp_match(reblog -> 'account' ->> 'acct', '^(.+)@'))[1]
                else reblog -> 'account' ->> 'acct'
              end as id,
              null as from_id,
              null as to_id,
              reblog -> 'account' ->> 'acct' as title,
              jsonb_build_object(
                'type', 'reblog',
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
          ),
          primary_person_server as (
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
          reblog_person_server as (
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
          )
          select * from primary_person_server
          union 
          select * from reblog_person_server
        ),

        -- edge

        person_boost_person as (
          with data as (
            select * from mastodon_toot where timeline = 'home' limit 50
          )
          select distinct
            null as id,
              case 
                when reblog -> 'account' ->> 'acct' ~ '@' then (regexp_match(reblog -> 'account' ->> 'acct', '^(.+)@'))[1]
                else reblog -> 'account' ->> 'acct'
              end as from_id,
              (regexp_match(account_url, '@(.+)'))[1] as to_id,
            'boosts' as title,
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
            username as from_id,
            ( select acct from mastodon_account where id = in_reply_to_account_id )  as to_id,
            'replies to' as title,
            jsonb_build_object(
              'username', username,
              'reply_to_username', ( select acct from mastodon_account where id = in_reply_to_account_id )
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
        union
        select * from person_boost_person

    EOQ
    }

  }

}

