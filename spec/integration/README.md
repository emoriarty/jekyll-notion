# Integration Tests

Integration tests validate the plugin's behavior during a full Jekyll
site build (`site.process`), ensuring components interact correctly.

## Classification Rule

A test belongs in `spec/integration/` if it:

- Calls `site.process`
- Exercises the plugin inside Jekyll's ecosystem
- Validates multiple components working together

> [!NOTE]
> Does it call `site.process`? → ✅ Integration.
> Otherwise → ❌ Unit.

## Examples

✅ **Integration**

``` ruby
site = Jekyll::Site.new(config)
site.process
expect(site.pages).not_to be_empty
expect(site.posts.first.content).to include("notion content")
```

❌ **Not Integration**

``` ruby
expect(JekyllNotion::Cacheable.cache_dir).to eq("/path")
instance.call(id: "test-123")
```

## VCR Caching

Integration tests use [VCR](https://relishapp.com/vcr/vcr/docs) to
record/replay Notion API calls for consistent, fast runs.

-   **Pages**: Cached automatically in\
    `.cache/jekyll-notion/vcr_cassettes/pages/[title]-[id].yml`

-   **Databases/others**: Must be wrapped in a cassette, e.g.:

    ``` ruby
    VCR.use_cassette("setup/deprecated_options") { site.process }
    ```

> [!TIP]
> Wrap `site.process` when the `databases` key is declared in `_config.yml`.

VCR config lives in `spec/spec_helper.rb` (fixtures in
`spec/fixtures/spec_cache/`, sensitive data filtered, mode:
`:new_episodes`).

> [!IMPORTANT]
> Pages rely on the plugin's built-in cache; other requests use
> RSpec-managed fixtures.

## Contributor Guidance

When adding tests: wrap non-page calls in cassettes; keep them minimal;
test offline to confirm completeness.

## Benefits

-   **Interaction coverage** across components\
-   **Realistic scenarios** matching user usage\
-   **Confidence** in overall correctness
