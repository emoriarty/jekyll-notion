# jekyll-notion

Import notion pages to a jekyll collection.

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
    filter: { "property": "Published", "checkbox": { "equals": true } }
    sort: { "propery": "Last ordered", "direction": "ascending" }
    frontmatter:
      layout: post
```

The other properties are:
* `collection`: what collection each page belongs to,
* `filter`: the database query filter,
* `sort`: the database query sort,
* `frontmatter`: additional frontmatter to append to each page in the collection.

Note: Only one database is available.

And that's all. Each page in the notion database will be included in the selected collection.

## Notion properties

Below, page notion default properties are set in each page frontmatter.

```
---
id: id
title: properties > Name > title > plain_text
cover: cover > external > url
date: created_time
---
```

## Page filename

There are two kinds of collections: posts and others.

When the collection is posts, the filename format contains the `created_time` property plus the page title as specified in [jekyll docs](https://jekyllrb.com/docs/posts/#creating-posts).

```
YEAR-MONTH-DAY-title.MARKUP
```

Any other collection, the filename is the page title.
