dashboard "Server" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
[Blocked](${local.host}/mastodon.dashboard.Blocked)
•
[Direct](${local.host}/mastodon.dashboard.Direct)
•
[Favorites](${local.host}/mastodon.dashboard.Favorites)
•
[Followers](${local.host}/mastodon.dashboard.Followers)
•
[Following](${local.host}/mastodon.dashboard.Following)
•
[Home](${local.host}/mastodon.dashboard.Home)
•
[List](${local.host}/mastodon.dashboard.List)
•
[Local](${local.host}/mastodon.dashboard.Local)
•
[Me](${local.host}/mastodon.dashboard.Me)
•
[Notification](${local.host}/mastodon.dashboard.Notification)
•
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
•
[Rate](${local.host}/mastodon.dashboard.Rate)
•
[Relationships](${local.host}/mastodon.dashboard.Relationships)
•
[Remote](${local.host}/mastodon.dashboard.Remote)
•
Server
•
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
•
[TagExplore](${local.host}/mastodon.dashboard.TagExplore)
•
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    input "server" {
      base = input.server
    }


  }

  container {

    chart {
      width = 6
      title = "toots by week"
      args = [ self.input.server.value ]
      sql = <<EOQ
        select
          to_char(week, 'YYYY-MM-DD') as week,
          statuses
        from
          mastodon_weekly_activity
        where
          server = 'https://' || $1
        order by
          week
      EOQ
    }

    chart {
      width = 6
      title = "registrations by week"
      args = [ self.input.server.value ]
      sql = <<EOQ
        select
          to_char(week, 'YYYY-MM-DD') as week,
          registrations,
          logins
        from
          mastodon_weekly_activity
        where
          server = 'https://' || $1
        order by
          week
      EOQ
    }
  }

  container {

    table {
      width = 6
      title = "rules"
      args = [ self.input.server.value ]
      sql = <<EOQ
        select
          id as "#",
          rule
        from
          mastodon_rule
        where
          server = 'https://' || $1
        order by
          id::int
      EOQ
    }
  }

}
