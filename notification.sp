dashboard "Notification" {
  
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
Notification
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
    card {
      width = 4
      sql = "select distinct _ctx ->> 'connection_name' as connection from mastodon_weekly_activity"
    }

    input "limit" {
      width = 2
      title = "limit"
      sql = <<EOQ
        with limits(label, value) as (
          values 
            ( '20', 20),
            ( '50', 50),
            ( '100', 100),
            ( '200', 200),
            ( '500', 500)
        )
        select
          label,
          value
        from 
          limits
        order by 
          value
      EOQ
    }    


  }

  container { 

    table {
      args = [ self.input.limit ]
      title = "notifications"
      query = query.notification
      column "status_url" {
        wrap = "all"
      }
      column "account_url" {
        wrap = "all"
      }
      column "toot" {
        wrap = "all"
      }
    }

  }

}

