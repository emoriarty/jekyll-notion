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
expect(JekyllNotion::Cacheable.enabled?).to be true
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

## VCR Configuration

The plugin uses [VCR](https://benoittgt.github.io/vcr) to record/replay Notion API calls with environment-specific configurations.

### Environment-Aware VCR Setup

VCR configuration automatically adapts based on test type:

- **Integration Tests** (`spec/integration/`): Use webmock + shared cassettes in `spec/fixtures/spec_cache/`
- **Unit Tests** (`spec/unit/`): Use faraday + isolated temporary directories for complete isolation

The system detects test type by file path and applies appropriate configuration automatically.

### How VCR Works

#### Database/Other API Calls
Must be wrapped in a cassette:

```ruby
# For database requests and other non-page API calls
VCR.use_cassette("notion_database") { site.process }
```

> [!TIP]
> Wrap `site.process` when the `databases` key is declared in `_config.yml`.

