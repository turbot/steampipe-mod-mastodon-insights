category "server" {
  color = "green"
  icon = "server"
  href  = "https://{{.properties.'server'}}"
}

category "selected_server" {
  color = "darkgreen"
  icon = "server"
  href  = "https://{{.properties.'server'}}"
}

category "blocked_server" {
  color = "darkred"
  icon = "server"
}

category "blocking_server" {
  color = "darkgreen"
  icon = "server"
}

category "blocked_and_blocking_server" {
  color = "orange"
  icon = "server"
}


category "boosted_server" {
  color = "brown"
  icon = "server"
  href  = "https://{{.properties.'server'}}"
}

category "person" {
  color = "green"
  icon = "user"
  href  = "{{.properties.'instance_qualified_account_url'}}"
}

category "boosted_person" {
  color = "brown"
  icon = "user"
  href  = "{{.properties.'instance_qualified_reblog_url'}}"
}

category "boost" {
  color = "gray"
}

category "tagger" {
  color = "green"
  icon = "user"
  href  = "{{.properties.'account_url'}}"
}

category "tag" {
  color = "black"
  icon = "tag"
  href  = "{{.properties.'url'}}"
}



