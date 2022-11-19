dashboard "Direct" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 4
      value = <<EOT
Direct
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
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
      title = "direct: recent toots"
      query = query.direct_timeline
      column "toot" {
        wrap = "all"
      }
    }

  }

}

