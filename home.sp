dashboard "Home" {
  
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
Home
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

    input "limit" {
      width = 2
      title = "limit"
      sql = <<EOQ
        with limits(label) as (
          values 
            ( '50' ),
            ( '100' ),
            ( '200' ),
            ( '500' )
        )
        select
          label,
          label::int as value
        from 
          limits
      EOQ
    }
    
    input "boosts" {
      width = 2
      title = "boosts"
      sql = <<EOQ
        with boosts(label, value) as (
          values
            ( 'include', 'include' ),
            ( 'hide', ' ' ),
            ( 'only', '🢁' )
        )
        select
          label,
          value
        from
          boosts
      EOQ
    }

  }
  
  container { 

    table {
      title = "home: recent toots"
      query = query.timeline
      args = [ "home", self.input.limit, self.input.boosts ]
      column "person" {
        wrap = "all"
      }
      column "toot" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }

    }

  }

}

