# Changelog

The format of this document is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- This is a comment, you won't see it when GitHub renders the Markdown file.

When releasing a new version:

1. Remove any empty section (those with `_None._`)
2. Update the `## Unreleased` header to `## <version_number>`
3. Add a new "Unreleased" section for the next iteration, by copy/pasting the following template:

## Unreleased

### Breaking Changes

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

_None._

-->

## Unreleased

### Breaking Changes

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

_None._

## 1.14.1

### Bug Fixes

- Fix an issue with `downloadImage` failure callback being called on the background thread [#130]

## 1.14.0

### New Features

- Add a new `ImageCaching` protocol and an `ImageCache` class with a `shared` property to allow overriding the default image cache [#129]

## 1.13.1

### Bug Fixes

- Addresses a crash in the `BottomSheetViewController` that was occurring due to an incorrect usage of a selector. The crash was caused by trying to call the `buttonPressed` instance method as a class method on `BottomSheetViewController.self`.

## 1.13.0

### New Features

- `BottomSheetViewController` can now work modally, too [#126]
- Add Swift Package Manager support [#120]

### Internal Changes

- Add this changelog file [#119]
