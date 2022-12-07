dashboard "Server" {
  
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
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
Server
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
