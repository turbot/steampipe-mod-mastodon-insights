dashboard "List" {

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
        "[List](${local.host}/mastodon.dashboard.List)",
        "List"
      )
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    input "list" {
      type = "select"
      width = 2
      sql = <<EOQ
        select
           l.title as label,
           l.title as value
         from
           mastodon_my_list l
         order by
           title
      EOQ
    }

  }

  container {

    table {
      width = 8
      query = query.list
      args = [ self.input.list.value ]
      column "toot" {
        wrap = "all"
      }
    }

    container {
      width = 4

      table {
        width = 6
        query = query.list_account_follows
      }

      table {
        query = query.list_account
        column "people" {
          wrap = "all"
        }
      }

    }


  }

}

