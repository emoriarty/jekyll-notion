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

After running `jekyll build` (or `serve`) command, the `posts` collection is loaded with pages of the notion database specified in the configuration. 

### Mutiple dabatases

You can also define multiple databases as follows.

```yml
collections:
  - recipes
  - films

notion:
  databases:
    - id: b0e688e1-99af-4295-ae80-b67eb52f2e2f
    - id: 2190450d-4cb3-4739-a5c8-340c4110fe21
      collection: recipes
    - id: e42383cd-4975-4897-b967-ce453760499f 
      collection: films
```

In this example, the notion database `b0e688e1-99af-4295-ae80-b67eb52f2e2f` pages are mapped into the posts collection. `recipes` and `films` will contain the database pages `2190450d-4cb3-4739-a5c8-340c4110fe21` and  `e42383cd-4975-4897-b967-ce453760499f`, respectively.

### data

Instead of storing notion pages in a collection, you can also map to the data object. Declare the data property as follows.

```yml
notion:
  database:
    id: e42383cd-4975-4897-b967-ce453760499f
    data: films
```

Unlike collections, only the properties of the notion page are assigned to the each data item. The body of the notion page is omitted.

### Database options

Each dabatase support the following options.

* `id`: the notion database unique identifier,
* `collection`: the collection each page belongs to (posts by default),
* `filter`: the database query filter,
* `sort`: the database query sort,

```yml
notion:
  database:
    id: e42383cd-4975-4897-b967-ce453760499f
    collection: posts
    filter: { "property": "Published", "checkbox": { "equals": true } }
    sort: { "property": "Last ordered", "direction": "ascending" }
```

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

Notion page properties are `id`, `title`, `created_time`, `last_edited_time`, `icon`, `cover` and `archived`.

```
---
id: e42383cd-4975-4897-b967-ce453760499f
title: An amazing post
cover: https://img.bank.sh/an_image.jpg
date: 2022-01-23T12:31:00.000Z
icon: 💥
archived: false
---
```

In addition to default properties, custom properties are also appended to front matter.

Please, refer to the [notion_to_md](https://github.com/emoriarty/notion_to_md/) gem to learn more.

## Page filename

There are two kinds of collections: posts and others.

When the collection is posts, the filename format contains the `created_time` property plus the page title as specified in [jekyll docs](https://jekyllrb.com/docs/posts/#creating-posts).

```
YEAR-MONTH-DAY-title.MARKUP
```

Any other collection, the filename is the page title.
