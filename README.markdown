# Traco

Translatable columns for Rails 3, stored in the model table itself.

Inspired by Iain Hecker's [translatable_columns](https://github.com/iain/translatable_columns/).

To store translations outside the model, see Sven Fuchs' [globalize3](https://github.com/svenfuchs/globalize3).


## Installation

Add this to your `Gemfile`:

    gem 'traco', github: 'barsoom/traco'

Then run

    bundle

to install it.


## Usage

The columns to translate should exist in the database with locale suffixes, e.g. `title_sv` and `title_en`.

Declare these columns in the model:

    class Post < ActiveRecord::Base
      translates :title, :body
    end

You can still use the `title_sv` accessors in forms and other code, but you also get:

`#title`:  Show the title in the current locale. If blank, fall back to default locale, then to any locale.

`#title=`: Assign the title to the column for the current locale, if present. Raise if the column doesn't exist.

`.human_attribute_name(:title_sv)`: Returns "Title (Swedish)" if you have a translation key `i18n.languages.sv = "Swedish"` and "Title (SV)" otherwise.

`.locales_for_column(:title)`: Returns an array like `[:sv, :en]` sorted with default locale first and then alphabetically. Suitable for looping in forms.

And the equivalent methods for `body`, of course.

Note that ActiveRecord validations check against the reader method, so if you validate for presence of `title`, it will check in the current locale.
You can validate against the localized columns like `title_sv` if you want.


# Running the tests

Use Ruby 1.9. Do this once:

    gem install bundler
    bundle
    cd spec/dummy
    rake db:migrate db:test:prepare

Do this to run the tests:

    rake

Or:

    guard


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
