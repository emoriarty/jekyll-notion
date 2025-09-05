# Integration Tests

Integration tests validate the jekyll-notion plugin's behavior within the full Jekyll site generation process, testing how components work together.

## Classification Rule

**A test belongs in `spec/integration/` if:**
- It calls `site.process` to trigger Jekyll site generation
- It tests the plugin's integration with Jekyll's ecosystem
- It validates end-to-end functionality
- It tests how multiple components interact together

## Examples

✅ **Integration Test Examples:**
```ruby
# Testing plugin behavior during Jekyll site generation
site = Jekyll::Site.new(config)
site.process  # ← This makes it an integration test

# Testing generated content after full site build
expect(site.pages).not_to be_empty
expect(site.posts.first.content).to include("notion content")
```

❌ **Not Integration Tests (belong in unit/):**
```ruby
# Testing individual methods without site.process
expect(JekyllNotion::Cacheable.cache_dir).to eq("/path")

# Testing class behavior with mocks
instance.call(id: "test-123")
```

## Benefits

- **End-to-end validation** - Tests real plugin behavior in Jekyll
- **Component interaction** - Validates how parts work together
- **Realistic scenarios** - Tests actual usage patterns
- **Confidence** - High-level assurance that the plugin works correctly
