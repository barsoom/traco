# Traco

[![Build Status](https://secure.travis-ci.org/barsoom/traco.svg)](http://travis-ci.org/barsoom/traco)

Translatable attributes for Ruby on Rails 4.2+, stored in the model table itself.

Inspired by Iain Hecker's [translatable_columns](https://github.com/iain/translatable_columns/).

To store translations outside the model, see Sven Fuchs' [Globalize](https://github.com/globalize/globalize).


## Usage

Say you want `Post#title` and `Post#body` to support both English and Swedish values.

Write a migration to get database columns with locale suffixes, e.g. `title_sv` and `title_en`, like:

```ruby
class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title_sv, :title_en
      t.text :body_sv, :body_en

      t.timestamps
    end
  end
end
```

Don't create a database column named `title` without a suffix, since Traco will define a method with that name.

If you use a locale format like `pt-BR`, the column name would be `title_pt_br`.

Declare the attributes in the model:

```ruby
class Post < ActiveRecord::Base
  translates :title, :body
end
```

You can still use your accessors like `title_sv` and `title_sv=` in forms, validations and other code, but you also get:

`#title`: Shows the title in the current locale. If blank, [falls back](#fallbacks) to default locale. Otherwise nil.

`#title(locale: :en)`: Shows the English title, without falling back. (To fall back, do `I18n.with_locale(:en) { post.title }` instead.)

`#title=`: Assigns the title to the column for the current locale, if present. Raises if the column doesn't exist.

`#title?`: Is the title present? Respects the [fallback](#fallbacks) setting.

`#title?(locale: :en)`: Is the title present in English, without falling back. (To fall back, do `I18n.with_locale(:en) { post.title? }` instead.)

`.human_attribute_name(:title_sv)`: Extends this standard method to return "Title (Swedish)" if you have a translation key `i18n.languages.sv = "Swedish"` and "Title (SV)" otherwise. Rails uses this method to build validation error messages and form labels.

`.translatable_attributes`: Returns an array like `[:title, :body]`.

`.locale_columns(:title)`: Returns an array like `[:title_sv, :title_en]` sorted with current locale first, then default locale, and then alphabetically. Suitable for looping in forms:

```erb
<% Post.locale_columns(:title).each do |column| %>
  <p>
    <%= form.label column %>
    <%= form.text_field column %>
  </p>
<% end %>
```

Or perhaps for things like:

```ruby
attr_accessible *locale_columns(:title)

validates *locale_columns(:title), :uniqueness => true
```

You can also pass multiple attributes if you like:

```ruby
attr_accessible *locale_columns(:title, :body)
```

The return value will be sorted like `[:title_sv, :title_en, :body_sv, :body_en]`.

`.current_locale_column(:title)`: Returns `:title_sv` if `:sv` is the current locale. Suitable for some SQL queries, such as sorting.

`.locales_for_attribute(:title)`: Returns an array like `[:sv, :en]` sorted with current locale first, then default locale, and then alphabetically.

And the equivalent methods for `body`, of course.

Please note that your `translates :title, :body` declaration must be called before you call `locale_columns`. Otherwise you will get an error like "NoMethodError: undefined method `locale\_columns' for #\<Class:0x00000003f69188\>".


### Fallbacks

By default, Traco will fall back to the default locale if there is no translation in the current locale.

You can specify e.g. `translates :title, fallback: false` to never fall back and instead return `nil`.

You can specify e.g. `translates :title, fallback: :any` to fall back first to the default locale, then to any other locale.

You can specify e.g. `translates :title, fallback: [:sv]` to explicitly declare fallbacks as an array of any length.

You can specify e.g. `translates :title, fallback: :i18n` to use the fallbacks from `I18n.fallbacks`.

You can override the default fallback strategy with a parameter passed to the reader: `post.title(fallback: :any)`.

If you need to declare the default locale fallback, do `post.title(fallback: :default)`.


### Overriding methods

Methods are defined in an included module, so you can just override them and call Traco's implementation with `super`:

```ruby
class Post < ActiveRecord::Base
  translates :title

  def title
    super.reverse
  end
end
```

## Installation

Add this to your `Gemfile`:

```ruby
gem "traco"
```

Then run

    bundle

to install it.


## Running the tests

    bundle
    rake


## Benchmark

    ruby benchmarks/overhead.rb


<!-- Keeping this a hidden brain dump for now.

## TODO

We've intentionally kept this simple with no features we do not need.
We'd be happy to merge additional features that others contribute.

Possible improvements to make:

  * Validation that checks that at least one translation for a column exists.
  * Validation that checks that every translation for a column exists.
  * Scopes like `translated`, `translated_to(locale)`.
  * Support for region locales, like `en-US` and `en-GB`.

-->

## Contributors

* [Henrik Nyh](http://henrik.nyh.se)
* Andrii Malyshko
* Tobias Bohwalli
* Mario Alberto Chavez
* Philip Arndt
* [PikachuEXE](https://github.com/PikachuEXE)
* Fernando Morgenstern
* Tomáš Horáček
* Joakim Kolsjö

## License

[MIT](LICENSE.txt)
