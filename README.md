# jekyll-notion
Import pages from notion.

## Installation

Use gem to install.
```bash
$ gem install 'jekyll-notion'
```

Or add it to the `Gemfile`.
```ruby
# Gemfile
gem 'jekyll-notion'
```

And update your jekyll plugins property in `_config.yml`.

```yml
plugins:
  - jekyll-notion
```

## Setup

Before using the gem create an integration and generate a secret token. Check [notion getting started guide](https://developers.notion.com/docs/getting-started) to learn more.

Export the notion secret token in an environment variable named `NOTION_TOKEN`.

```bash
$ export NOTION_TOKEN=<secret_...>
```

Once your notion database has been shared, specify the `id` in your `_config.yml` as follows.

```yml
notion:
  database:
    id: b91d5...
    collection: posts
    layout: post
    filter: { "property": "Published", "checkbox": { "equals": true } }
    sort: { "propery": "Last ordered", "direction": "ascending" }
    frontmatter:
      prop_1: blabla
      prop_2: albalb
```

The other properties are:
* `collection`: what collection each page belongs to,
* `layout`: the layout for each page,
* `filter`: the database query filter,
* `sort`: the database query sort,
* `frontmatter`: additonal frontmatter to append to each page in the collection.

Note: Only one database is available.

And that's all. Each page in the notion database will be included in the selected collection.
