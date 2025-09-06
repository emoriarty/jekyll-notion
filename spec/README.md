# Testing Guide

This guide explains the testing structure for jekyll-notion plugin.

## Test Types

### Unit Tests (`spec/unit/`)

Unit tests validate individual classes, modules, and methods in isolation without invoking the full Jekyll site generation process.

**Classification Rule:**
- Does **NOT** call `site.process`
- Tests individual methods, classes, or modules directly
- Uses mocking/stubbing to isolate the system under test
- Focuses on specific functionality without framework dependencies

```ruby
# Testing individual methods without site.process
expect(JekyllNotion::Cacheable.cache_dir).to eq("/path")
instance.call(id: "test-123")
```

### Integration Tests (`spec/integration/`)

Integration tests validate the plugin's behavior during a full Jekyll site build (`site.process`), ensuring components interact correctly.

**Classification Rule:**
- Calls `site.process`
- Exercises the plugin inside Jekyll's ecosystem
- Validates multiple components working together

```ruby
# Testing plugin behavior during Jekyll site generation
site = Jekyll::Site.new(config)
site.process  # ← This makes it an integration test

# Testing generated content after full site build
expect(site.pages).not_to be_empty
expect(site.posts.first.content).to include("notion content")
```

> [!TIP]
> Does it call `site.process`? → ✅ Integration (`spec/integration/`)
> Otherwise → ✅ Unit (`spec/unit/`)

## VCR Caching (Integration Tests Only)

Integration tests use [VCR](https://relishapp.com/vcr/vcr/docs) to record/replay Notion API calls for consistent, fast runs.

### How VCR Works

- **Pages**: Cached automatically in `.cache/jekyll-notion/vcr_cassettes/pages/[title]-[id].yml`
- **Databases/others**: Must be wrapped in a cassette:

```ruby
# For database requests and other non-page API calls
VCR.use_cassette("setup/deprecated_options") { site.process }
```

> [!TIP]
> Wrap `site.process` when the `databases` key is declared in `_config.yml`.

### VCR Configuration

VCR is configured in `spec/spec_helper.rb` with:
- Cassette storage in `spec/fixtures/spec_cache/`
- Sensitive data filtering (Authorization tokens, cookies)
- New episodes recording mode

### Cassette Structure

- **Pages**: `.cache/jekyll-notion/vcr_cassettes/pages/[page-title]-[id].yml`
- **Other requests**: `spec/fixtures/spec_cache/[test-name].yml`

> [!IMPORTANT]
> Pages rely on the plugin's built-in cache; other requests use RSpec-managed fixtures.
