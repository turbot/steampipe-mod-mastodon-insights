dashboard "Following" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 8
      value = <<EOT
[Direct](${local.host}/mastodon.dashboard.Direct)
🞄
[Favorites](${local.host}/mastodon.dashboard.Favorites)
🞄
[Followers](${local.host}/mastodon.dashboard.Followers)
🞄
Following
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

    card {
      width = 4
      sql = "select distinct _ctx ->> 'connection_name' as server from mastodon_weekly_activity"
    }

    card {
      width = 2
      sql = "select count(*) as following from mastodon_following"
    }

  }

  container {

    chart {
      title = "follows by month of account creation"
      width = 6
      sql = <<EOQ
        select
          to_char(created_at, 'YYYY-MM') as month,
          count(*)
        from
          mastodon_following
        group by
          month
      EOQ
    }

    chart {
      width = 6
      type = "donut"
      title = "follows by server domain"
      sql = <<EOQ
        with domains as (
          select
            (regexp_match(acct, '@(.+)'))[1] as domain
          from
            mastodon_following
        )
        select
          case
            when domain is null then $1
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
      param "server" {
        default = local.server
      }
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

