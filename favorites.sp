dashboard "Favorites" {

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
Favorites
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
      args = [ self.input.limit.value ]
      width = 6
      title = "favorites by day"
      sql = <<EOQ
        select
          to_char(created_at, 'YY-MM-DD') as day,
          count(*)
        from
          mastodon_favorite
        group by
          day
        limit $1
      EOQ
    }

    chart {
      args = [ self.input.limit.value ]
      type = "donut"
      width = 6
      title = "favorites by person"
      sql = <<EOQ
        with data as (
          select
            case when display_name = '' then username else display_name end as person
          from
            mastodon_favorite
          limit $1
          )
        select
          person,
          count(*)
        from
          data
        group by
          person
        order by
          count desc
      EOQ
    }


  }


  container {

    table {
      args = [ self.input.limit.value ]
      title = "favorites"
      query = query.favorite
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

