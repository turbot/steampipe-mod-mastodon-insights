dashboard "Followers" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
[Blocked](${local.host}/mastodon.dashboard.Blocked)
🞄
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Favorites](${local.host}/mastodon.dashboard.Favorites)
🞄
Followers
🞄
[Following](${local.host}/mastodon.dashboard.Following)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[List](${local.host}/mastodon.dashboard.List)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Me](${local.host}/mastodon.dashboard.Me)
🞄
[Notification](${local.host}/mastodon.dashboard.Notification)
🞄
[PeopleSearch](${local.host}/mastodon.dashboard.PeopleSearch)
🞄
[Rate](${local.host}/mastodon.dashboard.Rate)
🞄
[Relationships](${local.host}/mastodon.dashboard.Relationships)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[StatusSearch](${local.host}/mastodon.dashboard.StatusSearch)
🞄
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
    }
  }

  container {

    table {
      width = 4
      query = query.connection
    }

    card {
      width = 2
      sql = "select count(*) as followers from mastodon_followers"
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
          mastodon_followers
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
            mastodon_followers
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

