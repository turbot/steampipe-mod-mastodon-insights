dashboard "Rate" {

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
        "[Rate](${local.host}/mastodon.dashboard.Rate)",
        "Rate"
      )
    }
  }

  container {
    table {
      title = "rate limit"
      width = 6
      sql = <<EOQ
        select
          _ctx ->> 'connection_name' as connection,
          ( select name from mastodon_server),
          max_limit as max,
          remaining,
          to_char(reset, 'HH24:MI') as reset
        from
          mastodon_rate
      EOQ
    }
  }


}

