dashboard "Remote" {
  
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
Remote
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
    card {
      width = 4
      sql = "select distinct _ctx ->> 'connection_name' as connection from mastodon_weekly_activity"
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

  }

  container { 

    table {
      title = "remote: recent toots"
      query = query.timeline
      args = [ "remote", self.input.limit ]
      column "toot" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }
    }

  }

}

