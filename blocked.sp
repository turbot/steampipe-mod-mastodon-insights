dashboard "Blocked" {

  tags = {
    service = "Mastodon"
  }

  container {

    table {
      width = 4
      query = query.connection
    }

  }

  container {

    container {
      width = 6

      text {
        title = "query 1: read 500 home timeline records, order blocked domains by number of blockers"
        value = <<EOQ
        with servers as (
          select distinct
            server as domain,
            'https://' || server as server
          from
            mastodon_toot
          where
            timeline = 'home'
          limit 500
        ),
        blocked_domains as (
          select
            s.domain,
            s.server,
            d.domain as "blocked domain"
          from
            servers s
          join
            mastodon_domain_block d
          on
            s.server = d.server
        ),
        data as (
          select
            'https://' || "blocked domain" as "blocked server",
            count(domain) as "blocking server count",
            array_to_string(array_agg(domain order by domain), ', ') as "blocking servers"
          from
            blocked_domains
          group by
            "blocked server"
          order by
            "blocking server count" desc,
            "blocked server"
        )
        select
          d.*,
          ( select array_to_string(array_agg(rule), ' ') from mastodon_rule where server = d."blocked server" ) as rules
        from 
          data d
        where
          d."blocking server count" > 2
        EOQ
      }

      text {
        title = "query 2: read 500 home timeline records, order by servers blocking the most domains"
        value = <<EOQ
          with servers as (
            select
              server as domain,
              'https://' || server as server
            from
              mastodon_toot
            where
              timeline = 'home'
            limit 500
          )
          select
            s.server,
            count(d.domain) as "blocked domains",
            ( select array_to_string(array_agg(rule), ' ') from mastodon_rule where server = s.server ) as rules
          from
            servers s
          join
            mastodon_domain_block d
          using
            (server)
          group by
            s.server
          order by
            "blocked domains" desc
        EOQ
      }

      table {
        title = "query 2 results"
        sql = <<EOQ
          with servers as (
            select
              server as domain,
              'https://' || server as server
            from
              mastodon_toot
            where
              timeline = 'home'
            limit 500
          )
          select
            s.server,
            count(d.domain) as "blocked domains",
            ( select array_to_string(array_agg(rule), ' ') from mastodon_rule where server = s.server ) as rules
          from
            servers s
          join
            mastodon_domain_block d
          using
            (server)
          group by
            s.server
          order by
            "blocked domains" desc
        EOQ
        column "blocking servers" {
          wrap = "all"
        }
        column "rules" {
          wrap = "all"
        }

      }

    }

    table {
      width = 6
      title = "query 1 results"
      sql = <<EOQ
        with servers as (
          select distinct
            server as domain,
            'https://' || server as server
          from
            mastodon_toot
          where
            timeline = 'home'
          limit 500
        ),
        blocked_domains as (
          select
            s.domain,
            s.server,
            d.domain as "blocked domain"
          from
            servers s
          join
            mastodon_domain_block d
          on
            s.server = d.server
        ),
        data as (
          select
            'https://' || "blocked domain" as "blocked server",
            count(domain) as "blocking server count",
            array_to_string(array_agg(domain order by domain), ', ') as "blocking servers"
          from
            blocked_domains
          group by
            "blocked server"
          order by
            "blocking server count" desc,
            "blocked server"
        )
        select
          d.*,
          ( select array_to_string(array_agg(rule), ' ') from mastodon_rule where server = d."blocked server" ) as rules
        from 
          data d
        where
          d."blocking server count" > 2
        EOQ
      column "blocking servers" {
        wrap = "all"
      }
      column "rules" {
        wrap = "all"
      }

    }

  }

  container {
    

  }


}