input "limit" {
  width = 2
  title = "limit"
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
        server,
        count(*)
      from
        mastodon_boosts()
      group by
        server
      limit ${local.limit}
    )
    select
      server || ' (' || count || ')' as label,
      server as value
    from
      data
    order by
      server
    EOQ
}
