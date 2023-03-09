dashboard "Server" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = replace(
        replace(
          "${local.menu}",
          "__HOST__",
          "${local.host}"
        ),
        "[Server](${local.host}/mastodon.dashboard.Server)",
        "Server"
      )
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
