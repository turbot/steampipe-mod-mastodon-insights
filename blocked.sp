dashboard "Blocked" {

  tags = {
    service = "Mastodon"
  }

  container {
    text {
      value = <<EOT
Blocked
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
[List](${local.host}/mastodon.dashboard.List)
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
[TagSearch](${local.host}/mastodon.dashboard.TagSearch)
      EOT
    }
  }


  container {

    table {
      width = 4
      query = query.connection
    }

  }

  container {

    table {
      width = 4
      title = "blocking servers in the home timeline by count of servers they block"
      sql = <<EOQ
        with servers as (
          select distinct
            server as domain,
            'https://' || server as server
          from
            mastodon_toot
          where
            timeline = 'home'
          limit 300
        ),
        blocking_and_blocked as (
          select
            s.server as "blocking server",
            d.domain as "blocked server"
          from
            servers s
          join
            mastodon_domain_block d
          on
            s.server = d.server
        )
        select
          "blocking server",
          count(*) as "count of blocked servers"
        from
          blocking_and_blocked
        group by
          "blocking server"
        order by
          "count of blocked servers" desc
      EOQ
    }

    table {
      width = 8
      title = "blocked servers by count of blocking servers in the home timeline"
      sql = <<EOQ
        with servers as (
          select distinct
            server as domain,
            'https://' || server as server
          from
            mastodon_toot
          where
            timeline = 'home'
          limit 300
        ),
        blocking_and_blocked as (
          select
            s.domain as "blocking domain",
            s.server as "blocking server",
            d.domain as "blocked server"
          from
            servers s
          join
            mastodon_domain_block d
          on
            s.server = d.server
        )
        select
          'https://' || "blocked server" as "blocked server",
          count("blocking server") as "blocking server count",
          array_to_string(array_agg("blocking domain" order by "blocking domain"), ', ') as "blocking server list"
        from
          blocking_and_blocked b
        group by
          "blocked server"
        order by
          "blocking server count" desc
    EOQ
    column "blocking server list" {
      wrap = "all"
    }
  }

}

}