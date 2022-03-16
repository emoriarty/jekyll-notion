# jekyll-notion

Import notion pages to a jekyll collection or data.

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

## Usage

Before using the gem create an integration and generate a secret token. Check [notion getting started guide](https://developers.notion.com/docs/getting-started) to learn more.

Once you have youe secret, export it in an environment variable named `NOTION_TOKEN`.

```bash
$ export NOTION_TOKEN=<secret_...>
```

### Databases

Once your [notion database](https://www.notion.so/help/intro-to-databases) has been shared, specify the database `id` in your `_config.yml` as follows.

```yml
notion:
  database:
    id: 5cfed4de3bdc4f43ae8ba653a7a2219b
```

By default, the notion pages contained in the database will be loaded into the `posts` collection.

You can also define __multiple databases__ as follows.

```yml
collections:
  - recipes
  - films

notion:
  databases:
    - id: b0e688e199af4295ae80b67eb52f2e2f
    - id: 2190450d4cb34739a5c8340c4110fe21
      collection: recipes
    - id: e42383cd49754897b967ce453760499f 
      collection: films
```

After running `jekyll build` (or `serve`) command, the `posts`, `recipes` and `films` collections will be loaded with pages from the notion databases. 

#### Database options

Each dabatase support the following options.

* `id`: the notion database unique identifier,
* `collection`: the collection each page belongs to (posts by default),
* `filter`: the database query filter,
* `sort`: the database query sort,

```yml
notion:
  database:
    id: e42383cd49754897b967ce453760499f
    collection: posts
    filter: { "property": "Published", "checkbox": { "equals": true } }
    sort: { "property": "Last ordered", "direction": "ascending" }
```

### Pages

Individual Notion pages can also be loaded into Jekyll. Just define the `page` property as follows.

```yml
notion:
  page:
    id: 5cfed4de3bdc4f43ae8ba653a7a2219b
```

As databases, we can set up multiple pages.

```yaml
notion:
  pages:
    - id: e42383cd49754897b967ce453760499f
    - id: b0e688e199af4295ae80b67eb52f2e2f
    - id: 2190450d4cb34739a5c8340c4110fe21
```

The filename of the generated page is the notion page title. Check [below](#page-filename) for more info.

All properties assigned to a notion page will be interpreted by jekyll as front matter. For example, if the permalink property is set to notion, jekyll will use it to create the proper path for that page as [expected](https://jekyllrb.com/docs/permalinks/#front-matter).

### Data

Instead of storing the notion pages in a collection or in the pages list, you can assign them to the data object.Just declare the `data` property next to the page or database id.

```yml
notion:
  databases:
    - id: b0e688e199af4295ae80b67eb52f2e2f
    - id: e42383cd49754897b967ce453760499f
      data: films
  pages:
    - id: e42383cd49754897b967ce453760499f
    - id: b0e688e199af4295ae80b67eb52f2e2f
      data: about
```

Page properties and body of the notion page are stored as a hash object.

In the previous example, data objects can be accesses as follows.

```html
<ul>
{% for film in site.data.films %}
  <li>{{ film.title }}</li>
{% endfor %}
</ul>
```

Notice, the page body is stored in the key `content`.

```html
{{ site.data.about.content }}
```

The rest of properties are mapped as expected. For more info go to [notion properties](#notion-properties).

### Watch

By default, databases are only requested during the first build. Subsequent builds use the results from the cache.

Set `fetch_on_watch` to true to allow request on each rebuild.

```yml
notion:
  fetch_on_watch: true
  database:
    id: e42383cd49754897b967ce453760499f
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

There are two kinds of documents in Jekyll: posts and others.

When the document is a post, the filename format contains the `created_time` property plus the page title as specified in [jekyll docs](https://jekyllrb.com/docs/posts/#creating-posts).

```
YEAR-MONTH-DAY-title.MARKUP
```

The filename for any other document is the page title.
