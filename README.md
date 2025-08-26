<img src="https://ik.imagekit.io/gxidvqvc9/jekyll_notion_logo_Thmlxy7GZ.png?updatedAt=1756230501479" width="200">

# jekyll-notion

Import [Notion](https://www.notion.so) pages into
[Jekyll](https://jekyllrb.com/).

📚 Learn more with these guides: 
- [Load Notion pages in
Jekyll](https://enrq.me/dev/2022/03/20/load-notion-pages-in-jekyll/) 
-[Managing Jekyll posts in
Notion](https://enrq.me/dev/2022/03/24/managing-jekyll-posts-in-notion/) 
-[Embedding videos with
jekyll-notion](https://enrq.me/dev/2023/03/31/embedding-videos-with-jekyll-notion/)

## Installation

Install via RubyGems:

``` bash
gem install jekyll-notion
```

Or add it to your `Gemfile`:

``` ruby
# Gemfile
gem 'jekyll-notion'
```

> \[!IMPORTANT\]\
> If you are using **jekyll-archives**, list `jekyll-notion` *before*
> `jekyll-archives` in the Gemfile. Otherwise, imported pages will not
> be picked up.\
> See the discussion
> [here](https://github.com/emoriarty/jekyll-notion/issues/95#issuecomment-2732112458).

Then enable the plugin in `_config.yml`:

``` yaml
plugins:
  - jekyll-notion
```
## Usage

Before using the gem, [create a Notion
integration](https://developers.notion.com/docs/getting-started) and
generate a secret token.

Export the token as an environment variable:

``` bash
export NOTION_TOKEN=<secret_...>
```

### Databases

Share a [Notion
database](https://developers.notion.com/docs/working-with-databases),
then specify its `id` in `_config.yml`:

``` yaml
notion:
  databases:
    - id: 5cfed4de3bdc4f43ae8ba653a7a2219b
```

By default, entries will be added to the `posts` collection.

You can also define **multiple databases**:

``` yaml
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

After running `jekyll build` or `jekyll serve`, the `posts`, `recipes`,
and `films` collections will contain pages from the specified databases.

#### Database options

Each database supports the following options:

-   `id`: the unique Notion database ID
-   `collection`: which collection to assign pages to (`posts` by
    default)
-   `filter`: a database
    [filter](https://developers.notion.com/reference/post-database-query-filter)
-   `sorts`: database [sorting
    criteria](https://developers.notion.com/reference/post-database-query-sort)

``` yaml
notion:
  databases:
    - id: e42383cd49754897b967ce453760499f
      collection: posts
      filter: { "property": "Published", "checkbox": { "equals": true } }
      sorts: [{ "timestamp": "created_time", "direction": "ascending" }]
```

#### Post dates

By default, the Notion page `created_time` property sets the post
filename date. This value is used for Jekyll's [`date`
variable\`](https://jekyllrb.com/docs/front-matter/#predefined-variables-for-posts).

Since `created_time` cannot be modified, you can override it by adding a
custom Notion property named `date` (or `Date`). That property will be
used instead.

### Pages

You can also load individual Notion pages:

``` yaml
notion:
  pages:
    - id: 5cfed4de3bdc4f43ae8ba653a7a2219b
```

Multiple pages are supported:

``` yaml
notion:
  pages:
    - id: e42383cd49754897b967ce453760499f
    - id: b0e688e199af4295ae80b67eb52f2e2f
    - id: 2190450d4cb34739a5c8340c4110fe21
```

The generated filename is based on the Notion page title (see [Page
filename](#page-filename)).

All page properties are exposed as Jekyll front matter. For example, if
a page has a `permalink` property set to `/about/`, Jekyll will generate
`/about/index.html`.

### Data

Instead of adding Notion pages to collections or `pages`, you can store
them under the Jekyll **data object** using the `data` option:

``` yaml
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

Each page is stored as a hash. The page body is available under the
`content` key.

Example:

``` html
<ul>
  {% for film in site.data.films %}
    <li>{{ film.title }}</li>
  {% endfor %}
</ul>

{{ site.data.about.content }}
```

Other properties are mapped normally (see [Notion
properties](#notion-properties)).

### Cache

Since version **2.4.0**, all Notion requests are cached locally. Only
the first request fetches from Notion; subsequent builds use the cache,
greatly reducing build times.

The cache uses the [vcr](https://github.com/vcr/vcr) gem. Each resource
(page or database) is stored in a file named after its Notion ID, e.g.:

    .cache/jekyll-notion/vcr_cassettes/e42383cd49754897b967ce453760499f.yml

> **Note:** enabling `cache` disables the deprecated `fetch_on_watch`
> option.

#### Cache folder

Default: `.cache/jekyll-notion/vcr_cassettes`\
You can override it in `_config.yml`:

``` yaml
notion:
  cache_dir: another/folder
```

The path must be relative to the project root.

#### Cleaning the cache

Delete the cache folder to clear everything, or remove an individual
file matching the Notion resource ID.

#### Disabling the cache

To disable caching entirely:

``` yaml
notion:
  cache: false
```

## Notion properties

Notion page properties are mapped into each Jekyll document's front
matter.

See the companion gem
[notion_to_md](https://github.com/emoriarty/notion_to_md/) for details.

## Page filename

Jekyll distinguishes between **posts** and **other documents**:

-   **Posts**: filenames follow the format
    `YEAR-MONTH-DAY-title.MARKUP`, where the date comes from the Notion
    `created_time` (or the `date` property if present).\
-   **Other documents**: filenames are derived from the Notion page
    title.

