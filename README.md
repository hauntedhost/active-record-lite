ActiveRecord Lite
=================

Demo:
-----
1. Clone me
2. Run ``rake db:create``
3. ``$ ruby demo.rb``
4. Open ``demo.rb`` and break all the things

[![Screenshot](/doc/screenshot.png)](//github.com/somlor/active-record-lite/)

Summary:
--------
ActiveRecord Lite is an experiment in building my own _very_ stripped down version of ActiveRecord.

The purpose was to understand more deeply how ActiveRecord actually works, particularly how ActiveRecord translates associations and queries into SQL.

Usage:
------
```ruby
require_relative 'lib/active_record_lite'

# open database connection
# run rake db:create to auto-generate a seeded db/cats.sqlite3
DBConnection.open('db/cats.sqlite3')
```

Next, define a model:
```ruby
class Human < SQLObject
  my_attr_accessor :id, :fname, :lname, :house_id

  has_many :cats, foreign_key: :owner_id
  belongs_to :house
end
```

By specifying ``my_attr_accessor``, we allow mass-assignment:
```ruby
dude = Human.new(fname: 'Alan', lname: 'Watts', house_id: 1)
```

The ``foreign_key`` for ``has_many :cats`` would have been guessed to be ``:human_id``. This is wrong in the case of our seed data.

For this reason ``has_many`` and ``belongs_to`` associations accept overrides for ``:class_name``, ``:foreign_key``, and `:primary_key`:
```ruby
has_many :cats,
  foreign_key: :owner_id,
  class_name: 'Cat',
  primary_key: :id
```

In this example, the table name ``"humans"`` will be inferred. To override the default, call ``set_table_name "new_name"``:
```ruby
# define house model
class House < SQLObject
  set_table_name 'houses'
  my_attr_accessor :id, :address

  has_many :humans
end
```

Last, there is support for ``has_one_through``:
```ruby
class Cat < SQLObject
  set_table_name 'cats'
  my_attr_accessor :id, :name, :owner_id

  belongs_to :human, foreign_key: :owner_id
  has_one_through :house, :human, :house
end
```

---
Developed by [Sean Omlor](http://seanomlor.com)
