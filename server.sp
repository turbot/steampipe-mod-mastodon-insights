dashboard "Server" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 4
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Rate](${local.host}/mastodon.dashboard.Rate)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
Server
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

    chart {
      width = 6
      title = "toots by week"
      sql = <<EOQ
        select
          to_char(week, 'MM-DD') as week,
          statuses
        from
          mastodon_weekly_activity
        order by 
          week
      EOQ
    }

    chart {
      width = 6
      title = "registrations by week"
      sql = <<EOQ
        select
          to_char(week, 'MM-DD') as week,
          registrations,
          logins
        from
          mastodon_weekly_activity
        order by 
          week
      EOQ
    }



  
  }

}
