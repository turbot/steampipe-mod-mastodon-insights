dashboard "Home" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 4
      value = <<EOT
Home
🞄
[Local](${local.host}/mastodon.dashboard.Local)
🞄
[Remote](${local.host}/mastodon.dashboard.Remote)
🞄
[Server](${local.host}/mastodon.dashboard.Server)
🞄
[Tag](${local.host}/mastodon.dashboard.Tag)
      EOT
    }
  }


  container { 

    table {
      title = "home: recent toots"
      sql = <<EOQ
        with toots as (
          select
            _ctx ->> 'connection_name' as connection,
            user_name || '.' || display_name as person,
            to_char(created_at, 'MM-DD HH24:MI') as timestamp,
            url,
            replace (
              replace (
                regexp_replace(content, '<[^>]+>', '', 'g'),
                '&#39;', 
                ''''
              ),
              '&quot;', 
              '"'
            ) as toot
          from 
            mastodon_home_toot
          limit 100
        )
        select
          *
        from
          toots
        where 
          url != ''
          and toot != ''
        order by
          timestamp desc
      EOQ
      column "toot" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }
    }

  }

}

