dashboard "Me" {

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
        "[Me](${local.host}/mastodon.dashboard.Me)",
        "Me"
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
      width = 6
      title = "my toots by day"
      args = [ self.input.limit.value ]
      sql = <<EOQ
        with data as (
          select
            to_char(created_at, 'YY-MM-DD') as day
          from
            mastodon_my_toot
          limit $1
        )
        select
          day,
          count(*)
        from
          data
        group by
          day
        order by
          day
      EOQ
    }

    chart {
      width = 6
      type = "donut"
      title = "my toots by type"
      args = [ self.input.limit.value ]
      sql = <<EOQ
        with data as (
          select
            case
              when reblog -> 'url' is not null then 'boosted'
              when in_reply_to_account_id is not null then 'in_reply_to'
              else 'original'
            end as type
          from
            mastodon_my_toot
          limit $1
        )
        select
          type,
          count(*)
        from
          data
        group by
          type
        order by
          count desc
      EOQ
    }

  }

  container {

    table {
      args = [ self.input.limit.value, "include" ]
      query = query.timeline_me
      column "toot" {
        wrap = "all"
      }

    }

  }

}

