dashboard "Following" {

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
        "[Following](${local.host}/mastodon.dashboard.Following)",
        "Following"
      )
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    card {
      width = 2
      sql = "select count(*) as following from mastodon_my_following"
    }

  }

  container {

    chart {
      title = "follows by month of account creation"
      width = 4
      sql = <<EOQ
        select
          to_char(created_at, 'YYYY-MM') as month,
          count(*)
        from
          mastodon_my_following
        group by
          month
      EOQ
    }

    chart {
      width = 4
      type = "donut"
      title = "follows by server domain"
      sql = <<EOQ
        with domains as (
          select
            (regexp_match(acct, '@(.+)'))[1] as domain
          from
            mastodon_my_following
        )
        select
          case
            when domain is null then '${local.server}'
            else domain
          end as domain,
          count(*)
        from
          domains
        group by
          domain
        order by
          count desc
        limit 15
      EOQ
    }

    table {
      width = 2
      query = query.list_account_follows
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

