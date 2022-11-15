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
      title = "local: recent toots"
      sql = <<EOQ
        with toots as (
          select
            _ctx ->> 'connection_name' as connection,
            user_name || '.' || display_name as person,
            to_char(created_at, 'MM-DD HH24:MI') as timestamp,
            case 
              when reblog -> 'url' is not null then 'yes'
              else ''
            end as is_boost,
            case 
              when reblog -> 'url' is not null then reblog ->> 'url'
              else url
            end as url,
            case 
              when in_reply_to_account_id is not null then  ( select acct from mastodon_account where id = in_reply_to_account_id )
              else ''
            end as in_reply_to,
            case 
              when reblog -> 'url' is null then 
                sanitize_toot(content)
              else
                sanitize_toot(reblog ->> 'content')
            end as toot
          from 
            mastodon_local_toot
            limit ${local.limit}
        )
        select
          *
        from
          toots
        order by
          timestamp desc
      EOQ
      column "toot" {
        wrap = "all"
      }

    }

  }

}

