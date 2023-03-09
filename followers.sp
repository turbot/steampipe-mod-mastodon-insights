dashboard "Followers" {

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
        "[Followers](${local.host}/mastodon.dashboard.Followers)",
        "Followers"
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
      sql = "select count(*) as followers from mastodon_my_follower"
    }

  }

  container {

    chart {
      width = 6
      title = "followers by month of account creation"
      sql = <<EOQ
        select
          to_char(created_at, 'YYYY-MM') as month,
          count(*)
        from
          mastodon_my_follower
        group by
          month
      EOQ
    }

    chart {
      width = 6
      type = "donut"
      title = "followers by server"
      sql = <<EOQ
        with domains as (
          select
            (regexp_match(acct, '@(.+)'))[1] as domain
          from
            mastodon_my_follower
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



  }

  container {

    table {
      query = query.followers
      column "note" {
        wrap = "all"
      }

    }
  }

}

