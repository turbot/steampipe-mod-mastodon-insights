# Mastodon Insights Mod for Steampipe

View Mastodon timelines, search hashtags, find interesting people, and check server stats.

## Overview

Mastodon dashboards answer questions like:

- Recent direct messages?
- Recent notifications?
- Recent toots on my home timeline?
- On the local timeline?
- On the federated timeline?
- Recent toots on my lists?
- Which toots are my favorites?
- How many toots have I posted? 
- Of toots have I posted, how many are original vs boosts vs replies?
- Who am I following (and which lists, if any, are they on)?
- Who are my followers (and which lists, if any, are they on) ?
- Which hashtags match `science`?
- Which toots on the home timeline match `federation`?
- Which accounts match `alice`?
- Which accounts matching `alice` am I following, and/or followed by?
- How many toots, logins, and registrations on my server in recent weeks?
- How many more API calls can I make during this 5-minute cycle?

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install and configure the [Mastodon plugin](https://github.com/turbot/steampipe-plugin-mastodon).

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-mastodon-insights
cd steampipe-mod-mastodon-insights
```

### Usage

Start your dashboard server:

```sh
steampipe dashboard
```

The dashboard launches at https://localhost:9194. 

### Credentials

This mod uses the credentials configured in the [Steampipe Mastodon  plugin](https://github.com/turbot/steampipe-plugin-mastodon).

## Contributing

If you have an idea for additional dashboards or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://steampipe.io/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-digitalocean-insights/blob/main/LICENSE).

