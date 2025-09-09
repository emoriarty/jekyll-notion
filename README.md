<img src="https://ik.imagekit.io/gxidvqvc9/jekyll_notion_logo_Thmlxy7GZ.png?updatedAt=1756230501479" width="200">

# jekyll-notion

> [!WARNING]
> The **main branch** is under active development for version 3.
> For the current **stable release**, please check out the [v2.x.x branch](https://github.com/emoriarty/jekyll-notion/tree/v2.x.x).

Import [Notion](https://www.notion.so) pages into
[Jekyll](https://jekyllrb.com/).

📚 Learn more with these guides:
- [Load Notion pages in
Jekyll](https://enrq.me/dev/2022/03/20/load-notion-pages-in-jekyll/)
- [Managing Jekyll posts in
Notion](https://enrq.me/dev/2022/03/24/managing-jekyll-posts-in-notion/)
- [Embedding videos with
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

### Beta version

Learn about the new changes in the following [post](https://enrq.me/dev/2025/09/09/jekyll-notion-notion-to-md-3-0-0-beta/).

If you want to try the **beta release**, install with the `--pre` flag:

```bash
gem install jekyll-notion --pre
```

Or pin the beta in your Gemfile:

```ruby
gem "jekyll-notion", "3.0.0.beta1"
```

⚠️ This version is under active development. For stable usage, prefer the latest `2.x.x` release.


## Usage

Before using the gem, [create a Notion
integration](https://developers.notion.com/docs/getting-started) and
generate a secret token.

Export the token as an environment variable:

``` bash
export NOTION_TOKEN=<secret_...>
```

### Environment Variables

The plugin supports the following environment variables for configuration:

- **`NOTION_TOKEN`** (required): Your Notion integration secret token
- **`JEKYLL_NOTION_CACHE`**: Fallback cache setting when not specified in `_config.yml` (`1`, `true`, `yes` to enable; `0`, `false`, `no` to disable)
- **`JEKYLL_NOTION_CACHE_DIR`**: Fallback cache directory when not specified in `_config.yml` (defaults to `.cache/jekyll-notion/vcr_cassettes`)

Example usage:
``` bash
export NOTION_TOKEN=secret_abc123...
export JEKYLL_NOTION_CACHE=false
export JEKYLL_NOTION_CACHE_DIR=/tmp/my-custom-cache
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

All Notion requests are cached locally with the [VCR](https://github.com/vcr/vcr) gem to speed up rebuilds.
The first build fetches from the Notion API; subsequent builds reuse the cache.

The cache mechanism provides:

- Per-page cache files that include the Notion page title + ID, making them easy to identify.
- Page-level deletion: remove a single cached page without affecting others.
- Databases fetched on every rebuild: new content in Notion is always discovered, while cached pages prevent unnecessary re-fetches.

**Example cached file (title + ID):**
```bash
.cache/jekyll-notion/vcr_cassettes/my-page-title-e42383cd49754897b967ce453760499f.yml
```

#### Cache folder

Default: `.cache/jekyll-notion/vcr_cassettes`

You can override the cache directory in two ways:

**Option 1: Configuration file** (in `_config.yml`):
``` yaml
notion:
  cache_dir: another/folder
```

**Option 2: Environment variable**:
``` bash
export JEKYLL_NOTION_CACHE_DIR=/path/to/custom/cache
```

The `_config.yml` setting takes precedence over the environment variable.
Both relative and absolute paths are supported - relative paths are resolved
from the project root.

#### Cleaning the cache

- Delete the entire cache folder to reset everything.
- Or delete a single cached page file to refresh only that page.

#### Disabling the cache

To disable caching entirely:

``` yaml
notion:
  cache: false
```

Or use the `JEKYLL_NOTION_CACHE` environment variable:

```bash
export JEKYLL_NOTION_CACHE=false  # or 0, no
```

## Sensitive data

The cache stores full request and response payloads from the Notion API.
This may include sensitive information such as authentication tokens, URLs, or private content.

If you intend to store cached files in version control or share them with others, be mindful of what they contain.
By default, jekyll-notion automatically redacts the `NOTION_TOKEN` from all cache files.
If you need to mask additional values, you can configure [VCR filters](https://benoittgt.github.io/vcr/#/configuration/filter_sensitive_data?id=filter-sensitive-data).

For example, add a file `_plugins/vcr_config.rb`:

```ruby
VCR.configure do |config|
  # Already handled by jekyll-notion: NOTION_TOKEN
  # Example of masking a custom header or property:
  config.filter_sensitive_data("[MASKED]") do |interaction|
    interaction.request.headers["User-Agent"]&.first
  end
end
```

This file will be automatically picked up by Jekyll and merged into the VCR configuration provided by jekyll-notion.

You can add filters for headers, query parameters, or any other values you don’t want exposed in the cache.

## Notion properties

Notion page properties are mapped into each Jekyll document's front
matter.

See the companion gem
[notion_to_md](https://github.com/emoriarty/notion_to_md/) for details.

## Page filename

Jekyll distinguishes between **posts** and **other documents**:

-   **Posts**: filenames follow the format
    `YEAR-MONTH-DAY-title.MARKUP`, where the date comes from the Notion
    `created_time` (or the `date` property if present).
-   **Other documents**: filenames are derived from the Notion page
    title.

## Testing

Run the test suite:

```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path/to/test  # Run specific test file
```

### Golden Files

Tests use golden files to validate generated output against known-good snapshots. Update snapshots when expected output changes:

```bash
UPDATE_GOLDEN=1 bundle exec rspec
```

