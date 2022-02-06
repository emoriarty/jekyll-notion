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

Once your notion database has been shared, specify the  database `id` in your `_config.yml` as follows.

```yml
notion:
  database:
    id: e42383cd-4975-4897-b967-ce453760499f
```

### Mutiple dabatases

You can also define multiple databases as follows.

```yml
notion:
  databases:
    - id: b0e688e1-99af-4295-ae80-b67eb52f2e2f
    - id: 2190450d-4cb3-4739-a5c8-340c4110fe21
      collection: recipes
    - id: e42383cd-4975-4897-b967-ce453760499f 
      collection: films
```

When no collection is defined, the `posts` collection is used by default.

### Database options

Each dabatase support the following options.

* `id`: the notion database unique identifier,
* `collection`: the collection each page belongs to (posts by default),
* `filter`: the database query filter,
* `sort`: the database query sort,
* `frontmatter`: additional front matter to append to each page in the collection.

```yml
notion:
  database:
    id: e42383cd-4975-4897-b967-ce453760499f
    collection: posts
    filter: { "property": "Published", "checkbox": { "equals": true } }
    sort: { "property": "Last ordered", "direction": "ascending" }
    frontmatter:
      layout: post
```

Note that you can also use [front matter defaults](https://jekyllrb.com/docs/configuration/front-matter-defaults/) to declare common key value pairs per collection.

### Watch

By default, databases are only requested during the first build. Subsequent builds use the results from the cache.

Set `fetch_on_watch` to true to allow request on each rebuild.

```yml
notion:
  fetch_on_watch: true
  database:
    id: e42383cd-4975-4897-b967-ce453760499f
```

And that's all. Each page in the notion database will be included in the selected collection.

## Notion properties

Below, default properties per notion page are set for each document front matter.

Notion properties include page `id`, `title`, `created_time`, `last_edited_time`, `icon` and `cover`.

```
---
id: e42383cd-4975-4897-b967-ce453760499f
title: An amazing post
cover: https://img.bank.sh/an_image.jpg
date: 2022-01-23T12:31:00.000Z
icon: \U0001F4A5
---
```

Default properties prevail over custom properties declared in the front matter config.

### Custom properties

In addition to default properties, custom properties are also supported.

Custom properties are appended to the page frontmatter by default. Every property name are downcased and snake-cased.
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

The supported property types are:

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
