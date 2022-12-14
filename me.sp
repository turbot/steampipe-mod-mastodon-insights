dashboard "Me" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
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
      width = 2
      title = "limit"
      sql = <<EOQ
        with limits(label, value) as (
          values 
            ( '50', 50),
            ( '100', 100),
            ( '200', 200),
            ( '500', 500)
        )
        select
          label,
          value
        from 
          limits
        order by 
          value
      EOQ
    }    


  }

    chart {
      width = 6
      title = "my toots by day"
      args = [ self.input.limit ]
      sql = <<EOQ
        with data as (
          select
            to_char(created_at, 'MM-DD') as day
          from
            mastodon_toot
          where
            timeline = 'me'
          order by
            day desc
          limit $1
        )
        select 
          day,
          count(*)    
        from
          data
        group by
          day
        order by
          day
      EOQ
    }

    chart {
      width = 6
      type = "donut"
      title = "my toots by type"
      args = [ self.input.limit ]
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
        limit $1
      EOQ
    }

  container { 

    table {
      args = [ self.input.limit ]
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

