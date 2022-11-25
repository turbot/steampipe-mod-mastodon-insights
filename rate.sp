dashboard "Rate" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 6
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
🞄
Rate
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
    table {
      title = "rate limit"
      width = 6
      sql = <<EOQ
        select
          _ctx ->> 'connection_name' as server,
          max,
          remaining,
          to_char(reset, 'HH24:MI') as reset
        from
          mastodon_rate
      EOQ
    }
  }


}

