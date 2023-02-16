input "limit" {
  width = 2
  title = "limit"
  type = "combo"
  sql = <<EOQ
    with limits(label) as (
      values
        ( '20' ),
        ( '50' ),
        ( '100' ),
        ( '200' ),
        ( '500' ),
        ( '1000' )
    )
    select
      label,
      label::int as value
    from
      limits
  EOQ
}

input "server" {
  width = 2
  type = "select"
  sql = <<EOQ
    with data as (
      select
        server
      from
        mastodon_toot
      where
        timeline = 'home'
        and reblog_server is not null
      limit ${local.limit}
    ),
    counts as (
      select
        server,
        count(*)
      from
        data
      group by
        server
    )
    select
      server || ' (' || count || ')' as label,
      server as value
    from
      counts
    order by
      server
    EOQ
}
