dashboard "Remote" {
  
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
Remote
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[Tag](${local.host}/mastodon.dashboard.Tag)
      EOT
    }
  }


  container { 

    table {
      title = "remote: recent toots"
      query = query.federated_timeline
      column "toot" {
        wrap = "all"
      }

    }

  }

}

