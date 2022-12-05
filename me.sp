dashboard "Me" {
  
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
[Following](${local.host}/mastodon.dashboard.Following)
🞄
[Home](${local.host}/mastodon.dashboard.Home)
🞄
[List](${local.host}/mastodon.dashboard.List)
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
Me
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
      
      width = 4
      sql = <<EOQ
        select count(*) as "my toots" from mastodon_toot where timeline = 'me'
      EOQ
    }

  }

    chart {
      width = 6
      title = "my toots by day"
      sql = <<EOQ
        select
          to_char(created_at, 'MM-DD') as day,
          count(*)
        from
          mastodon_toot
        where
          timeline = 'me'
        group by
          day
        order by day
      EOQ
    }

    chart {
      width = 6
      type = "donut"
      title = "my toots by type"
      sql = <<EOQ
        with data as (
          select
            case
              when reblog -> 'url' is not null then 'boosted'
              when in_reply_to_account_id is not null then 'in_reply_to'
              else 'original'
            end as type
          from
            mastodon_toot
          where
            timeline = 'me'
        )
        select
          type,
          count(*)
        from
          data
        group by
          type
        order by
          count desc
      EOQ
    }

  container { 

    table {
      query = query.my_toots
      column "toot" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }

    }

  }

}

