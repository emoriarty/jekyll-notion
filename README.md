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
  fetch_on_watch: false
  database:
    id: b91d5...
    collection: posts
    filter: { "property": "Published", "checkbox": { "equals": true } }
    sort: { "property": "Last ordered", "direction": "ascending" }
    frontmatter:
      layout: post
```

`fetch_on_watch` enables fetching notion pages in watch mode. By default is off, so only retrieves pages in the first build.

`database` properties are:
* `id`: the notion database unique identifier,
* `collection`: the collection each page belongs to (posts by default),
* `filter`: the database query filter,
* `sort`: the database query sort,
* `frontmatter`: additional frontmatter to append to each page in the collection.

Note: Only one database is available.

And that's all. Each page in the notion database will be included in the selected collection.

## Notion properties

Below, page notion default properties are set in each page frontmatter.

Default properties include  `title`, created_time`, `last_edited_time`, `icon` and `cover.

```
---
id: b2998...
title: A title
cover: https://img.bank.sh/an_image.jpg
date: 2022-01-23T12:31:00.000Z
icon: \U0001F4A5
---
```

Any property provided in the frontmatter config that matches a default property will be overwritten by the default value.

### Custom properties

In addition to default properties, custom properties are also supported.

Custom properties are appended to page frontmatter by default. Every property name is snake-cased.
For example, two properties named `Multiple Options` and `Tags` will be transformed to `multiple_options` and `tags`, respectively.

```
---
id: b2998...
title: A title
cover: https://img.bank.sh/an_image.jpg
date: 2022-01-23T12:31:00.000Z
icon: \U0001F4A5
tags: tag1, tag2, tag3
multiple_options: option1, option2
---
```

The supported properties are:

* `number`
* `select`
* `multi_select`
* `date`
* `people`
* `files`
* `checkbox`
* `url`
* `email`
* `phone_number`

`created_by`, `last_edited_by`, `rich_text` as advanced types like `formula`, `relation` and `rollup` are not supported.

Check notion documentation about [property values](https://developers.notion.com/reference/property-value-object#all-property-values).

## Page filename

There are two kinds of collections: posts and others.

When the collection is posts, the filename format contains the `created_time` property plus the page title as specified in [jekyll docs](https://jekyllrb.com/docs/posts/#creating-posts).

```
YEAR-MONTH-DAY-title.MARKUP
```

Any other collection, the filename is the page title.
