dashboard "Direct" {

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
        "[Direct](${local.host}/mastodon.dashboard.Direct)",
        "Direct"
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

    table {
      title = "direct: recent toots"
       query = query.timeline_direct
      args = [ self.input.limit.value, "n/a" ]
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

