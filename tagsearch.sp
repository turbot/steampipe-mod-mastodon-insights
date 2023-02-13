dashboard "TagSearch" {

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
[List](${local.host}/mastodon.dashboard.List)
•
[Home](${local.host}/mastodon.dashboard.Home)
•
[Local](${local.host}/mastodon.dashboard.Local)
•
[Me](${local.host}/mastodon.dashboard.Me)
•
[Notification](${local.host}/mastodon.dashboard.Notification)
•
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
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
TagSearch
      EOT
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

