# Mastodon Insights Mod for Steampipe

View Mastodon timelines, search hashtags, find interesting people, and check server stats.

## Overview

Mastodon dashboards answer questions like:

- Recent direct messages?
- Recent notifications?
- Recent toots on my home timeline?
- On the local timeline?
- On the federated timeline?
- Which toots are hashtagged `science`?
- Which toots on the home timeline match `federation`?
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

