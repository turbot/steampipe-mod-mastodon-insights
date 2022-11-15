dashboard "Tag" {
  
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
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
Tag
      EOT
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

