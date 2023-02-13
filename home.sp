dashboard "Home" {

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
Home
•
[List](${local.host}/mastodon.dashboard.List)
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
      query = query.timeline
      args = [ "home", self.input.limit.value, self.input.boosts.value ]
      column "person" {
        wrap = "all"
      }
      column "toot" {
        wrap = "all"
      }

    }

  }

}

