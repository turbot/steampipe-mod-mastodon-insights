dashboard "Local" {
  
  tags = {
    service = "Mastodon"
  }

  container {
    text {
      width = 4
      value = <<EOT
[Home](${local.host}/mastodon.dashboard.Home)
🞄
Local
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
      title = "local: newest 30 toots"
      sql = <<EOQ
        with toots as (
          select
            _ctx ->> 'connection_name' as connection,
            user_name || '.' || display_name as person,
            to_char(created_at, 'MM-DD HH24:mm') as timestamp,
            url,
            regexp_replace(content, '<[^>]+>', '', 'g') as toot
          from 
            mastodon_local_toot
          limit 30
        )
        select
          *
        from
          toots
        where 
          url != ''
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

