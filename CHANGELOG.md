# Changelog

## 3.1.0

* Introduce `.current_locale_column`, e.g. `Post.current_locale_column(:title)  # => :title_sv`.

## 3.0.0

* Backwards incompatible: `fallback: true` is now `fallback: :default`. Since this was the implicit default value, you shouldn't have a problem unless you explicitly declared this value.

## 2.2.0

* `fallback: :any` to fall back to any other locale if the text is blank in the current and default locales.

## 2.1.0

* Attribute readers can override the attribute's `fallback` setting, e.g. `item.title(fallback: false)`.

## 2.0.0

* Backwards incompatible: for dashed locales like `:"pt-BR"`, the column names are now expected to end in e.g. `_pt_br`, not `_pt-BR`.

## 1.3.0

Whatever we had before introducing this changelog.
