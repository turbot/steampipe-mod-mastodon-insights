dashboard "Home" {

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
        "[Home](${local.host}/mastodon.dashboard.Home)",
        "Home"
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

    input "boosts" {
      width = 2
      title = "boosts"
      sql = <<EOQ
        with boosts(label, value) as (
          values
            ( 'include', 'include' ),
            ( 'hide', ' ' ),
            ( 'only', '▲' )
        )
        select
          label,
          value
        from
          boosts
      EOQ
    }

  }

  container {

    table {
      title = "home: recent toots"
      args = [ self.input.limit.value, self.input.boosts.value ]
      query = query.timeline_home
      column "person" {
        wrap = "all"
      }
      column "toot" {
        wrap = "all"
      }

    }

  }

}



