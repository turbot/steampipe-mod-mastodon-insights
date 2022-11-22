dashboard "Rate" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 4
      value = <<EOT
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
Rate
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[Tag](${local.host}/mastodon.dashboard.Tag)
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
          reset
        from
          mastodon_rate
      EOQ
    }
  }


}

