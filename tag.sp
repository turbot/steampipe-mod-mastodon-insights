dashboard "Tag" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 4
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
Tag
      EOT
    }
  }

  container {
    table {
      width = 2
      sql = "select distinct _ctx ->> 'connection_name' as server from mastodon_weekly_activity"
    }
  }

  container {

    input "hashtag" {
      width = 2
      title = "hashtag"
      type = "combo"
      option "books" {}
      option "cycling" {}
      option "guitar" {}
      option "science" {}
      option "steampipe" {}
    }

  }

  container {
  
    table {
      args = [ self.input.hashtag.value ]
      query = query.hashtag_detail
      column "categories" {
        wrap = "all"
      }
    }

  }

}  

