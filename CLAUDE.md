# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Jekyll-notion is a Jekyll plugin that imports Notion pages and databases into Jekyll sites. It converts Notion content to Jekyll posts, pages, and data using the notion-ruby-client and notion_to_md gems.

## Commands

### Testing
```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path/to/test  # Run specific test file
UPDATE_GOLDEN=1 bundle exec rspec    # Update golden files/snapshots
```

### Development
```bash
bundle install                       # Install dependencies
```

## Architecture

### Core Components

- **JekyllNotion::Generator** (`lib/jekyll-notion/generator.rb`): Main Jekyll generator that orchestrates the import process
- **Generators namespace** (`lib/jekyll-notion/generators/`): Contains specialized generators:
  - `Collection`: Imports database entries into Jekyll collections
  - `Page`: Imports individual Notion pages 
  - `Data`: Imports content into Jekyll data files
  - `Generator`: Base class for all generators
- **Cacheable** (`lib/jekyll-notion/cacheable.rb`): Provides VCR-based caching for Notion API responses
- **Document/Page Without A File**: Custom Jekyll classes for content not backed by filesystem files

### Generator Pattern

The plugin uses a generator pattern where:
1. Main `JekyllNotion::Generator` validates config and sets up caching
2. Delegates to specialized generators (`Collection`, `Page`, `Data`) based on configuration
3. Each generator processes Notion content and creates appropriate Jekyll objects

### Configuration Structure

Configuration is read from `_config.yml` under the `notion` key:
- `databases`: Array of database configurations with id, collection, filter, sorts
- `pages`: Array of page configurations with id and optional data target
- `cache`: Boolean to enable/disable caching (default: true)
- `cache_dir`: Custom cache directory (default: `.cache/jekyll-notion/vcr_cassettes`)

### Caching System

Uses VCR gem to cache Notion API responses:
- Each resource cached in separate YAML file named by Notion ID
- Sensitive data (auth tokens, cookies) automatically redacted
- Cache can be disabled via config or `JEKYLL_NOTION_CACHE` env var

## Environment Variables

- `NOTION_TOKEN`: Required Notion integration token
- `JEKYLL_NOTION_CACHE`: Override cache setting ("1"/"true"/"yes" to enable, "0"/"false"/"no" to disable)
- `JEKYLL_NOTION_CACHE_DIR`: Override cache directory path

## Testing Framework

- Uses RSpec with VCR for API mocking
- Golden files pattern for output validation (`spec/support/golden_helper.rb`)
- Sensitive data automatically redacted in VCR cassettes
- Test fixtures in `spec/fixtures/`
- Integration tests for full import workflows
- Unit tests for individual components

## Key Dependencies

- `jekyll`: >= 3.7, < 5.0
- `notion-ruby-client`: ~> 1.2.0 (Notion API client)
- `notion_to_md`: 3.0.0.beta1 (Notion to Markdown conversion)
- `vcr`: ~> 6.3.1 (HTTP interaction recording/caching)
- `zeitwerk`: ~> 2.6 (autoloading)