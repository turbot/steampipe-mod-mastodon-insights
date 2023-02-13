dashboard "PeopleSearch" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
[Blocked](${local.host}/mastodon.dashboard.Blocked)
•
[Direct](${local.host}/mastodon.dashboard.Direct)
•
[Favorites](${local.host}/mastodon.dashboard.Favorites)
•
[Followers](${local.host}/mastodon.dashboard.Followers)
•
[Following](${local.host}/mastodon.dashboard.Following)
•
[Home](${local.host}/mastodon.dashboard.Home)
•
[List](${local.host}/mastodon.dashboard.List)
•
[Local](${local.host}/mastodon.dashboard.Local)
•
[Me](${local.host}/mastodon.dashboard.Me)
•
[Notification](${local.host}/mastodon.dashboard.Notification)
•
PeopleSearch
•
[Rate](${local.host}/mastodon.dashboard.Rate)
•
[Relationships](${local.host}/mastodon.dashboard.Relationships)
•
[Remote](${local.host}/mastodon.dashboard.Remote)
•
[Server](${local.host}/mastodon.dashboard.Server)
•
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
•
[TagExplore](${local.host}/mastodon.dashboard.TagExplore)
•
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
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

