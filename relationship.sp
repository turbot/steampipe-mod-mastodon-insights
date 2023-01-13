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

  container {

    input "server" {
      base = input.server
    }


    graph {

      title = "boosts from selected server"

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
        href  = "{{.properties.'instance_qualified_account_url'}}"
      }

      category "reblog_user_edge" {
        color = "green"
        href = "https://{{.properties.'server'}}/@{{.properties.'reblog_username'}}@{{.properties.'reblog_server'}}/{{.properties.'id'}}"
      }

      category "reblogged_user_node" {
        color = "green"
        icon = "user"
        href  = "{{.properties.'instance_qualified_reblog_url'}}"
      }

      node {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_primary_server
      }

      node {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_reblog_server
      }

      node {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_primary_person
      }

      node {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_person_reblog_person
      }

      edge {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_primary_person_to_server
      }

      edge {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_reblog_person_to_server
      }

      edge {
        args = [ self.input.server.value ]
        query = query.mastodon_recent_toots_person_boost_person
      }

    }
  }

  container {

    graph {

      title = "boosts from server to server"

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

      node {
        query = query.mastodon_recent_toots_primary_server_all
      }

      node {
        query = query.mastodon_recent_toots_reblog_server_all
      }

      edge {
        query = query.mastodon_recent_toots_server_reblog_server
      }

    }
  } 

}

// for graph 1

query "mastodon_recent_toots_primary_server" {
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
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
  EOQ
}

query "mastodon_recent_toots_reblog_server" {
  sql = <<EOQ
    select distinct
      reblog_server as id,
      reblog_server as title,
      case when $1 = reblog_server then 'server' else 'reblog_server' end as category,
      jsonb_build_object(
        'server', server,
        'reblog_server', reblog_server
      ) as properties
    from 
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
  EOQ
}

query "mastodon_recent_toots_primary_person" {
  sql = <<EOQ
    select
      username as id,
      display_name as title,
      'user' as category,
      jsonb_build_object(
        'username', username,
        'instance_qualified_account_url', instance_qualified_account_url,
        'type', 'primary',
        'display_name', display_name,
        'server', server
      ) as properties
    from
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
  EOQ
}

query "mastodon_recent_toots_person_reblog_person" {
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
        'instance_qualified_reblog_url', instance_qualified_reblog_url,
        'display_name', reblog -> 'account' ->> display_name,
        'followers', reblog -> 'account' ->> 'followers_count',
        'following', reblog -> 'account' ->> 'following_count',
        'content', reblog ->> 'content'
      ) as properties
    from
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
  EOQ
}

query "mastodon_recent_toots_primary_person_to_server" {
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
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
  EOQ
}

query "mastodon_recent_toots_reblog_person_to_server" {
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
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
  EOQ
}

query "mastodon_recent_toots_person_boost_person" {
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
      mastodon_toot
    where
      timeline = 'home'
      and server = $1
      and reblog is not null
    limit ${local.limit}
  EOQ
}

// for graph 2

query "mastodon_recent_toots_primary_server_all" {
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
      mastodon_toot
    where
      timeline = 'home'
    limit ${local.limit}
EOQ
}

query "mastodon_recent_toots_reblog_server_all" {
  sql = <<EOQ
    select distinct
      reblog_server as id,
      reblog_server as title,
      'reblog_server' as category,
      jsonb_build_object(
          'server', server,
          'reblog_server', reblog_server
      ) as properties
    from 
      mastodon_toot
    where
      timeline = 'home'
    limit ${local.limit}
EOQ
}


query "mastodon_recent_toots_server_reblog_server" {
  sql = <<EOQ
    select distinct
      server as from_id,
      reblog_server as to_id,
      'boosts' as title
    from 
      mastodon_toot
    where
      timeline = 'home'
EOQ
}

