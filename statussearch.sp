dashboard "StatusSearch" {

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
        "[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)",
        "StatusSearch"
      )
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    input "search_term" {
      type = "text"
      width = 2
      title = "search home timeline"
    }

  }

  container {

    table {
      args = [ local.limit, "n/a", self.input.search_term.value ]
      query = query.search_toot
      column "toot" {
        wrap = "all"
      }
    }
  }

}

