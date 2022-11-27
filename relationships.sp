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

      nodes = [
        node.person,
        node.server
      ]

      edges = [
        edge.person_to_person,
        edge.person_to_server,
      ]

    }

}

}

node "server" {
  sql = <<EOQ
    with data as (
      select 
        regexp_match(url, 'https://([^/]+)') as server
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
      server as title
    from 
      data
  EOQ
}

node "person" {
  sql = <<EOQ

    with direct as (
      with data as (
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
        user_name as title,
        jsonb_build_object(
          'display_name', display_name,
          'followers', account ->> 'followers_count',
          'following', account ->> 'following_count'
        ) as properties
      from 
        data
      where
        server is not null
    ),
    
    indirect as (
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
        reblog -> 'account' ->> 'username' as user_name,
        reblog -> 'account' ->> 'username' as title,
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

    select * from direct
    union
    select * from indirect

  EOQ
}

edge "person_to_server" {
  title = "belongs to"

  sql = <<EOQ
    select
      user_name as from_id,
      (regexp_match(url, 'https://([^/]+)'))[1] as to_id
    from
      mastodon_toot 
    where
      timeline = 'home'
    limit
      50
  EOQ
}

edge "person_to_person" {
  title = "boosts"

  sql = <<EOQ
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
      user_name as from_id,
      reblog -> 'account' ->> 'username' as to_id
    from 
      data
    where
      reblog is not null
  EOQ
}



