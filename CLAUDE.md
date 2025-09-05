# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

jekyll-notion is a Jekyll plugin that imports Notion pages and databases into Jekyll sites. The plugin transforms Notion content into Jekyll collections, pages, or data objects using the Notion API and the notion_to_md gem.

## Development Commands

### Testing
```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path/to/test  # Run specific test file
```

### Code Quality
```bash
bundle exec rubocop                  # Run linter
bundle exec rubocop -a               # Auto-fix linting issues
```

### Setup
```bash
bundle install                       # Install dependencies
```

## Architecture

### Core Components
- **Generator** (`lib/jekyll-notion/generator.rb`): Main Jekyll generator that orchestrates the import process
- **Generators Module** (`lib/jekyll-notion/generators/`): Specialized generators for different content types:
  - `Collection`: Creates Jekyll collection documents from Notion databases
  - `Page`: Creates Jekyll pages from individual Notion pages
  - `Data`: Stores Notion content in Jekyll's data object
  - `Support`: Shared utilities for generators
- **Document/Page Without File**: Jekyll document/page classes that don't require physical files
- **Cacheable**: Mixin for caching Notion API responses using VCR

### Key Dependencies
- **jekyll**: The static site generator framework
- **notion-ruby-client**: Unofficial Notion API client
- **notion_to_md**: Converts Notion blocks to Markdown (companion gem)
- **vcr**: HTTP interaction recording for caching
- **zeitwerk**: Code loading and autoloading

### Configuration
The plugin is configured in Jekyll's `_config.yml`:
```yaml
plugins:
  - jekyll-notion

notion:
  databases:
    - id: database_id
      collection: posts  # optional, defaults to posts
      filter: {...}      # optional Notion API filter
      sorts: [...]       # optional Notion API sorts
  pages:
    - id: page_id
      data: key_name     # optional, stores in site.data instead
  cache_dir: .cache/jekyll-notion/vcr_cassettes  # optional
  cache: true           # optional, defaults to true
```

### Environment Variables
- `NOTION_TOKEN`: Required Notion integration secret token
- `JEKYLL_NOTION_CACHE`: Override cache setting (defaults to true)
- `JEKYLL_NOTION_CACHE_DIR`: Override cache directory location (defaults to `.cache/jekyll-notion/vcr_cassettes`)

### Import Process
1. Generator checks for configuration and NOTION_TOKEN
2. Sets up caching if enabled (VCR + local file storage)
3. Processes each configured database:
   - Fetches database pages via Notion API
   - Converts to Markdown using notion_to_md
   - Creates Jekyll documents in specified collection
4. Processes each configured page:
   - Fetches page content via Notion API
   - Converts to Markdown
   - Creates Jekyll page or stores in data object

### Caching System
- Uses VCR to cache HTTP responses to `.cache/jekyll-notion/vcr_cassettes/`
- Each Notion resource gets its own cache file named by ID
- Dramatically reduces build times by avoiding repeated API calls
- Can be disabled by setting `cache: false` in config

### Testing
- Uses RSpec with VCR for HTTP mocking
- SimpleCov for coverage reporting
- Test fixtures in `spec/fixtures/` with sample sites and cached responses
- Golden file testing for comparing generated output
