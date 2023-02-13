dashboard "List" {

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
[Home](${local.host}/mastodon.dashboard.Home)
•
List
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

    input "list" {
      type = "select"
      width = 2
      sql = <<EOQ
        with list_account as (
          select
            l.title
          from
            mastodon_list l
          join
              mastodon_list_account a
          on
            l.id = a.list_id
        ),
        counted as (
          select
            title,
            count(*)
          from
            list_account
          group by
            title
          order by
            title
        )
        select
          title || ' (' || count || ')' as label,
          title as value
        from
          counted
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

