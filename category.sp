category "server" {
  color = "yellow"
  icon = "server"
  href  = "https://{{.properties.'server'}}"
}

category "reblog_server" {
  color = "brown"
  icon = "server"
  href  = "https://{{.properties.'server'}}"
}

category "user" {
  color = "orange"
  icon = "user"
  href  = "{{.properties.'instance_qualified_account_url'}}"
}

category "reblog_user" {
  color = "green"
  icon = "user"
  href  = "{{.properties.'instance_qualified_reblog_url'}}"
}