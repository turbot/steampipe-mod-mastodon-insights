dashboard "Local" {

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
Local
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

    table {
      title = "local: recent toots"
      query = query.timeline
      args = [ "local", self.input.limit.value, "n/a" ]
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

