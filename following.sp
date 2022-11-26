dashboard "Following" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 8
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Followers](${local.host}/mastodon.dashboard.Followers)
🞄
Following
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
🞄
[Rate](${local.host}/mastodon.dashboard.Rate)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
🞄
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
    }
  }

  container {

    card {
      width = 4
      sql = "select distinct _ctx ->> 'connection_name' as server from mastodon_weekly_activity"
    }

    card {
      width = 2
      sql = "select count(*) as following from mastodon_following"
    }

  }

  container {

    table {
      query = query.following
      column "note" {
        wrap = "all"
      }

    }
  }

}

