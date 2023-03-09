dashboard "TagSearch" {

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
        "[TagSearch](${local.host}/mastodon.dashboard.TagSearch)",
        "TagSearch"
      )
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    input "search_term" {
      width = 2
      type = "text"
      title = "search hashtags"
    }

  }

  container {

    table {
      args = [ self.input.search_term.value ]
      query = query.search_hashtag
      column "categories" {
        wrap = "all"
      }
      column "content" {
        wrap = "all"
      }
    }

  }

}

