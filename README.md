# jekyll-notion

Import notion pages to jekyll.

You can learn more about how to use jekyll-notion with the following links:

* [Load notion pages in jekyll](https://enrq.me/dev/2022/03/20/load-notion-pages-in-jekyll/)
* [Managing Jekyll posts in Notion](https://enrq.me/dev/2022/03/24/managing-jekyll-posts-in-notion/)
* [Embedding videos with jekyll-notion](https://enrq.me/dev/2023/03/31/embedding-videos-with-jekyll-notion/)

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

> [!IMPORTANT]  
> When using jekyll-archives, make sure that jekyll-notion is placed before jekyll-archives in the gemfile. Otherwise pages imported by jekyll-notion won't be collected by jekyll-archives. More info [here](https://github.com/emoriarty/jekyll-notion/issues/95#issuecomment-2732112458).

And update your jekyll plugins property in `_config.yml`.

```yml
plugins:
  - jekyll-notion
```

## Usage

Before using the gem, create an integration and generate a secret token. For more in-depth instructions, refer to the Notion "Getting Started" [guide](https://developers.notion.com/docs/getting-started).

Once you have your secret token, make sure to export it into an environment variable named `NOTION_TOKEN`.

```bash
$ export NOTION_TOKEN=<secret_...>
```

### Databases

Once the [notion database](https://developers.notion.com/docs/working-with-databases) has been shared, specify the database `id` in the `_config.yml` file as follows.

```yml
notion:
  databases:
    - id: 5cfed4de3bdc4f43ae8ba653a7a2219b
```

By default, the notion pages in the database will be loaded into the `posts` collection.

We can also define __multiple databases__ as follows.

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
* `filter`: the database [filter property](https://developers.notion.com/reference/post-database-query-filter),
* `sorts`: the database [sorts criteria](https://developers.notion.com/reference/post-database-query-sort),

```yml
notion:
  databases:
    - id: e42383cd49754897b967ce453760499f
      collection: posts
      filter: { "property": "Published", "checkbox": { "equals": true } }
      sorts: [{ "timestamp": "created_time", "direction": "ascending" }]
```

#### Posts date

The `created_time` property of a notion page is used to set the date in the post filename. This is the date used for the `date` variable of the [predefined variables for posts](https://jekyllrb.com/docs/front-matter/#predefined-variables-for-posts).

It's important to note that the `created_time` cannot be modifed. However, if you wish to change the date of a post, you can create a new page property named "date" (or "Date"). This way, the posts collection will use the `date` property for the post date variable instead of the `created_time`.

### Pages

Individual Notion pages can also be loaded into Jekyll. Just define the `page` property as follows.

```yml
notion:
  pages:
    - id: 5cfed4de3bdc4f43ae8ba653a7a2219b
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

All properties assigned to a notion page will be interpreted by jekyll as front matter. For example, if the [permalink](https://jekyllrb.com/docs/permalinks/#front-matter) property is set to `/about/` in the notion page, jekyll will use it to create the corresponding path at the output directory at `/about/index.html`.

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

Data objects can be accessed as follows.

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

### Watch (Deprecated)

_Use the cache mechanism instead._

By default, databases are only requested during the first build. Subsequent builds use the results from the cache.

Set `fetch_on_watch` to true to allow request on each rebuild.

```yml
notion:
  fetch_on_watch: true
  databases:
    - id: e42383cd49754897b967ce453760499f
```

And that's all. Each page in the notion database will be included in the selected collection.

### Cache

Starting from version 2.4.0, every request to Notion is cached locally. The cache enables the retrieval of Notion resources only during the first request. Subsequent requests are fetched from the cache, which can significantly reduce build times.

The cache mechanism is based on the [vcr](https://github.com/vcr/vcr) gem, which records HTTP requests. Every Notion resource, whether it is a database or page, is stored in an independent file using the document ID as the filename. For example, a database ID e42383cd49754897b967ce453760499f will be stored in the following path:

```bash
.cache/jekyll-notion/vcr_cassetes/e42383cd49754897b967ce453760499f.yml
```

**Note: The `cache` option invalidates the fetch_on_watch feature.**

#### Cache folder

By default, the cache folder is `.cache/jekyll-notion/vcr_cassetes`, but you can change this folder by setting the `cache_dir` property in the `_config.yml` file as follows.

```yaml
notion:
  cache_dir: another/folder
```

The path must be relative to the working folder.

#### Cleaning cache

To clear the cache, delete the cache folder. If you want to remove a specific cache file, locate the file that matches the Notion resource ID and delete it.

#### Disabling cache

If you're not interested in the cache or you just want to disable it, set the ˋcache` option to false.

```yaml
notion:
  cache: false
```

## Notion properties

Notion page properties are set for each document in the front matter.

Please, refer to the [notion_to_md](https://github.com/emoriarty/notion_to_md/) gem to learn more.

## Page filename

There are two kinds of documents in Jekyll: posts and others.

When the document is a post, the filename format contains the `created_time` property plus the page title as specified in [jekyll docs](https://jekyllrb.com/docs/posts/#creating-posts).

```
YEAR-MONTH-DAY-title.MARKUP
```

The filename for any other document is the page title.
