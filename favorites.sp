dashboard "Favorites" {

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
        "[Favorites](${local.host}/mastodon.dashboard.Favorites)",
        "Favorites"
      )
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
          mastodon_toot_favourite
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
            mastodon_toot_favourite
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
      args = [ self.input.limit.value, "n/a" ]
      title = "favorites"
      query = query.timeline_favourite
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

