mod "mastodon" {
}

locals {
  //host = "https://cloud.steampipe.io/org/acme/workspace/jon/dashboard"
  host = "http://localhost:9194"
  server = "mastodon.social"
  limit = 80
  timeline_exclude = "press.coop"
  menu = <<EOT
[Blocked](__HOST__/mastodon.dashboard.Blocked)
•
[BoostsFromServer](__HOST__/mastodon.dashboard.BoostsFromServer)
•
[BoostsFederated](__HOST__/mastodon.dashboard.BoostsFederated)
•
[Direct](__HOST__/mastodon.dashboard.Direct)
•
[Favorites](__HOST__/mastodon.dashboard.Favorites)
•
[Followers](__HOST__/mastodon.dashboard.Followers)
•
[Following](__HOST__/mastodon.dashboard.Following)
•
[Home](__HOST__/mastodon.dashboard.Home)
•
[List](__HOST__/mastodon.dashboard.List)
•
[Local](__HOST__/mastodon.dashboard.Local)
•
[Me](__HOST__/mastodon.dashboard.Me)
•
[Notification](__HOST__/mastodon.dashboard.Notification)
•
[PeopleSearch](__HOST__/mastodon.dashboard.PeopleSearch)
•
[Rate](__HOST__/mastodon.dashboard.Rate)
•
[Relationships](__HOST__/mastodon.dashboard.Relationships)
•
[Remote](__HOST__/mastodon.dashboard.Remote)
•
[Server](__HOST__/mastodon.dashboard.Server)
•
[StatusSearch](__HOST__/mastodon.dashboard.StatusSearch)
•
[TagExplore](__HOST__/mastodon.dashboard.TagExplore)
•
[TagSearch](__HOST__/mastodon.dashboard.TagSearch)  
EOT
}
