dashboard "PeopleSearch" {

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
        "[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)",
        "PeopleSearch"
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
      width = 4
      title = "search for people (use '' for ' e.g. O''Reilly)"
    }

  }

  container {

    table {
      args = [ self.input.search_term.value ]
      query = query.search_people
      column "note" {
        wrap = "all"
      }
    }

  }

}

