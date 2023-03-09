dashboard "Remote" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = replace(
        replace(
          "${local.menu}",
          "__HOST__",
          "${local.host}"
        ),
        "[Remote](${local.host}/mastodon.dashboard.Remote)",
        "Remote"
      )
    }
  }

  container {

    table {
      width = 4
      sql = <<EOQ
      select
        _ctx ->> 'connection_name' as connection,
        name as server
      from
        mastodon_server
      EOQ
    }

    input "limit" {
      base = input.limit
    }

  }

  container {

    table {
      title = "remote: recent toots"
      query = query.timeline_federated
      args = [ self.input.limit.value, "n/a" ]
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

