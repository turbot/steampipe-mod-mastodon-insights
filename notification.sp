dashboard "Notification" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
[Blocked](${local.host}/mastodon.dashboard.Blocked)
🞄
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
[Relationships](${local.host}/mastodon.dashboard.Relationships)
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
      query = query.connection
    }

    input "limit" {
      base = input.limit
    }

  }

  container {

    chart {
      width = 4
      args = [ self.input.limit.value ]
      sql = <<EOQ
        with data as (
          select
            to_char(created_at, 'YY-MM-DD') as day
          from
            mastodon_notification
          limit
            $1
        )
        select
          day,
          count(*)
        from
          data
        group by
          day
      EOQ
    }

    chart {
      width = 4
      type = "donut"
      args = [ self.input.limit.value ]
      sql = <<EOQ
        with data as (
          select
            category
          from
            mastodon_notification
          limit
            $1
        )
        select
          category,
          count(*)
        from
          data
        group by
          category
        order by
          count desc
      EOQ
    }

    chart {
      width = 4
      type = "donut"
      args = [ self.input.limit.value ]
      sql = <<EOQ
        with data as (
          select
            regexp_match(account_url, 'https://([^/]+)') as server
          from
            mastodon_notification
          limit
            $1
        )
        select
          server,
          count(*)
        from
          data
        group by
          server
        order by
          count desc
      EOQ
    }



  }

  container {

    table {
      args = [ self.input.limit.value ]
      title = "notifications"
      query = query.notification
      column "status_url" {
        wrap = "all"
      }
      column "instance_qualified_account_url" {
        wrap = "all"
      }
      column "toot" {
        wrap = "all"
      }
    }

  }

}

