# Traco

[![Build Status](https://secure.travis-ci.org/barsoom/traco.png)](http://travis-ci.org/barsoom/traco)

Translatable attributes for Rails 3, stored in the model table itself.

Inspired by Iain Hecker's [translatable_columns](https://github.com/iain/translatable_columns/).

To store translations outside the model, see Sven Fuchs' [globalize3](https://github.com/svenfuchs/globalize3).


## Usage

Say you want `Post#title` and `Post#body` to support both English and Swedish values.

Write a migration to get database columns with locale suffixes, e.g. `title_sv` and `title_en`, like:

    class CreatePosts < ActiveRecord::Migration
      def change
        create_table :posts do |t|
          t.string :title_sv, :title_en
          t.text :body_sv, :body_en

          t.timestamps
        end
      end
    end

Don't create a database column named `title` without a suffix, since Traco will define a method with that name.

Declare the attributes in the model:

    class Post < ActiveRecord::Base
      translates :title, :body
    end

You can still use your accessors like `title_sv` and `title_sv=` in forms, validations and other code, but you also get:

`#title`: Shows the title in the current locale. If blank, falls back to default locale. Otherwise nil.

`#title=`: Assigns the title to the column for the current locale, if present. Raises if the column doesn't exist.

`.human_attribute_name(:title_sv)`: Extends this standard method to return "Title (Swedish)" if you have a translation key `i18n.languages.sv = "Swedish"` and "Title (SV)" otherwise. Rails uses this method to build validation error messages and form labels.

`.translatable_attributes`: Returns an array like `[:title, :body]`.

`.locales_for_attribute(:title)`: Returns an array like `[:sv, :en]` sorted with default locale first and then alphabetically. Suitable for looping in forms:

    <% Post.locales_for_attribute(:title).each do |locale| %>
      <p>
        <%= form.label "title_#{locale}" %>
        <%= form.text_field "title_#{locale}" %>
      </p>
    <% end %>

And the equivalent methods for `body`, of course.


### Disable fallback

if you specify

    class Post < ActiveRecord::Base
      translates :title, :body,
        fallback: false
    end

then `#title` will return `nil` if there is no translation in the current locale, instead of falling back to the default locale.


### Overriding methods

Methods are defined in an included module, so you can just override them and call Traco's implementation with `super`:

    class Post < ActiveRecord::Base
      translates :title

      def title
        super.reverse
      end
    end


## Installation

Add this to your `Gemfile` if you use Bundler 1.1+:

    gem 'traco'

Then run

    bundle

to install it.


## Running the tests

    bundle
    rake # or guard


<!-- Keeping this a hidden brain dump for now.

## TODO

We've intentionally kept this simple with no features we do not need.
We'd be happy to merge additional features that others contribute.

Possible improvements to make:

  * Validation that checks that at least one translation for a column exists.
  * Validation that checks that every translation for a column exists.
  * Option to disable fallback.
  * Scopes like `translated`, `translated_to(locale)`.
  * Support for region locales, like `en-US` and `en-GB`.

-->


## Credits and license

By [Barsoom](http://barsoom.se) under the MIT license:

>  Copyright (c) 2012 Barsoom AB
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
