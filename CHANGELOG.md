# Changelog

## 3.2.0

* Introduce e.g. `fallback: [:sv]` to explicitly specify fallbacks.

## 3.1.6

Make [license (MIT)](LICENSE.txt) easier to autodetect.

## 3.1.5

* Bugfix: don't raise error loading models before the DB is created. Thanks to PikachuEXE and Andrii Malyshko.

## 3.1.4

* Bugfix: restore sorting of `locale_columns` and `locales_for_attribute` to put default locale first, not current locale. Thanks to PikachuEXE.

## 3.1.3

 * ~20 time speedup thanks to optimizations by Andrii Malyshko.

   Reading a Traco translated attribute used to be ~250x slower than an untranslated attribute; now it's down to ~10x slower.

## 3.1.2

* Bugfix: `.current_locale_column` handles dashed locales like "pt-BR" correctly. Thanks to PikachuEXE.

## 3.1.1

* Bugfix around fallbacks and memoization. Thanks to PikachuEXE.

## 3.1.0

* Introduce `.current_locale_column`, e.g. `Post.current_locale_column(:title)  # => :title_sv`.

## 3.0.0

* Backwards incompatible: `fallback: true` is now `fallback: :default`. Since this was the implicit default value, you shouldn't have a problem unless you explicitly declared this value.

## 2.2.0

* `fallback: :any` to fall back to any other locale if the text is blank in the current and default locales.

## 2.1.0

* Attribute readers can override the attribute's `fallback` setting, e.g. `item.title(fallback: false)`.

## 2.0.0

* Backwards incompatible: for dashed locales like "pt-BR", the column names are now expected to end in e.g. `_pt_br`, not `_pt-BR`.

## 1.3.0

Whatever we had before introducing this changelog.
