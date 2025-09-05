# Unit Tests

Unit tests validate individual classes, modules, and methods in isolation without invoking the full Jekyll site generation process.

## Classification Rule

**A test belongs in `spec/unit/` if:**
- It does **NOT** call `site.process`
- It tests individual methods, classes, or modules directly
- It uses mocking/stubbing to isolate the system under test
- It focuses on specific functionality without framework dependencies

## Examples

✅ **Unit Test Examples:**
```ruby
# Testing a module method directly
expect(JekyllNotion::Cacheable.cache_dir).to eq("/path/to/cache")

# Testing class behavior with mocks
allow(NotionToMd::Page).to receive(:call).and_return(mock_response)
instance.call(id: "test-123")

# Testing utility methods
expect(instance.sanitize_id("abc-123-def")).to eq("abc123def")
```

❌ **Not Unit Tests (belong in integration/):**
```ruby
# This involves full Jekyll site generation
site = Jekyll::Site.new(config)
site.process  # ← This makes it an integration test
```

## Benefits

- **Fast execution** - No Jekyll site generation overhead
- **Isolated testing** - Tests specific functionality without dependencies
- **Clear failures** - Failures point to specific components
- **Easy debugging** - Focused scope makes issues easier to track down
