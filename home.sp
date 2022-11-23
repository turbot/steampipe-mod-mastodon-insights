dashboard "Home" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 5
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
Home
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[Rate](${local.host}/mastodon.dashboard.Rate)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[Tag](${local.host}/mastodon.dashboard.Tag)
      EOT
    }
  }

  container {
    table {
      width = 2
      sql = "select distinct _ctx ->> 'connection_name' as server from mastodon_weekly_activity"
    }
  }

  container { 

    table {
      title = "home: recent toots"
      query = query.timeline
      args = [ "home" ]
      column "toot" {
        wrap = "all"
      }

    }

  }

}

