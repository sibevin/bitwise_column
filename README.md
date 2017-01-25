# BitwiseColumn

Using bitwise format to store multiple value combination in a single integer column.

You may see the [What is bitwise?](#what-is-bitwise) first if you are not familiar with it.

## What is bitwise?

Let's take the user role for example. Suppose there are three kinds of roles - member, manager and admin. An user may have multiple roles at the same time, and we need to record this information. If we want to use a single integer column to store the role information for each users, we can change an integer to the bitwise format first and define each bit to represent the corresponding role as below:

```
member ----------.
manager -------. |
admin -------. | |
             | | |
             V V V
             0 0 0 = bitwise format
             3 2 1
             ^ ^ ^
             | | |
             | | .---- the 1st lowest bit
             | .------ the 2nd lowest bit
             .-------- the 3rd lowest bit
```

Then we can store the integer value according to the bitwise result, for example:

```
.------------------------.----------------.---------------------------------------.
| roles                  | bitwise result | integer value                         |
.------------------------.----------------.---------------------------------------.
| none                   | 0 0 0          | 0*2^2 + 0*2^1 + 0*2^0 = 0 + 0 + 0 = 0 |
.------------------------.----------------.---------------------------------------.
| member                 | 0 0 1          | 0*2^2 + 0*2^1 + 1*2^0 = 0 + 0 + 1 = 1 |
.------------------------.----------------.---------------------------------------.
| member, manager        | 0 1 1          | 0*2^2 + 1*2^1 + 1*2^0 = 0 + 2 + 1 = 3 |
.------------------------.----------------.---------------------------------------.
| member, admin          | 1 0 1          | 1*2^2 + 0*2^1 + 1*2^0 = 4 + 0 + 1 = 5 |
.------------------------.----------------.---------------------------------------.
| member, manager, admin | 1 1 1          | 1*2^2 + 1*2^1 + 1*2^0 = 4 + 2 + 1 = 7 |
.------------------------.----------------.---------------------------------------.
```

## Why we use bitwise column?

Let's take the user role for example again. There are many ways to achieve the requirement mentioned before:

1. Use another Role model to store roles and build an many-to-many association between User and Role.
2. Add an serialized column to User model and store an role array in it.
3. Use bitwise to store the role information with a single integer column.

If you need to add new roles or remove existing roles dynamically, the first solution is the best way to implement this feature. But if roles are pre-defined and seldom changed, use another table to store roles may reduce the database efficiency, especially when the role information is used very often.

Use a serialized column to store role information is a solution to fix the efficiency problem. The serialized column allows us to store an array directly in the column, such as `['member', 'admin']`, but it brings other issues:

* We need to create a text column for the serialized column. Handling text columns are much slower than integer ones in database.
* It's very difficult to change a role's name if this role is already stored in many records.
* We need use text search to query users who have particular roles.

To avoid these issues, the bitwise column becomes a better solution compared with the serialized one. Because the bitwise column use an integer to store the data, we can use the bitwise operation provided by database to do queries. The problem is we need to handle the transaction between the bitwise and integer value. On the other hand, it is hard to understand what each bit means if we have no good way to record this information.

This is the reason we use the `bitwise_column` gem, it provides the following features:

1. It uses a mapping to name each bit. We can use these names directly, such as `user.role_bitwise = [:member, :admin]`, the corresponding integer value is calculated automatically.
2. Both ActiveRecord and pure ruby object are supported.
3. Support i18n.

Please reference [Usage](#usage) to get more details about how it works.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitwise_column'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitwise_column

## Usage

### ActiveRecord

First, add an integer column to your model with a migration:

```ruby
class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer
  end
end
```

Although bitwise column treats nil as 0, but we suggest using 0 for consistence. To do that, you may add `null: false` and `default: 0` options if needed.

Next, include BitwiseColumn module in your model and call bitwise_column to setup the bitwise mapping:

```ruby
class User < ActiveRecord::Base
  include BitwiseColumn
  bitwise_column :role, {
    member: 1,
    manager: 2,
    admin: 3,
  }
end
```

Then, you will have a virtual column `role_bitwise` to access the bitwise values:

```ruby
user = User.new
p user.role # nil
p user.role_bitwise # []

user.role_bitwise = :member
p user.role # 1
p user.role_bitwise # [:member]
user.role_bitwise = 'admin'
p user.role # 4
p user.role_bitwise # [:admin]
```

You can use an array to assign bitwise values as well.

```ruby
user.role_bitwise = [:member, :manager]
p user.role # 3
p user.role_bitwise # [:member, :manger]
user.role_bitwise = ['admin', 'member']
p user.role # 5
p user.role_bitwise # [:member, :admin]
user.role_bitwise = []
p user.role # 0
p user.role_bitwise # []
```

If you change the original integer column directly, the role_bitwise is updated at the same time.

```ruby
user.role = 7
p user.role # 7
p user.role_bitwise # [:member, :manager, :admin]
user.role = 0
p user.role # 0
p user.role_bitwise # []
```

Use `_bitwise_have?` to check the given keys are included or not.

```ruby
user.role_bitwise = [:member, :manger]
p user.role_bitwise_have?(:member) # true
p user.role_bitwise_have?('manager') # true
p user.role_bitwise_have?(:admin) # false
p user.role_bitwise_have?(['manager', 'member']) # true
p user.role_bitwise_have?([:member, :admin]) # false
```

Use `_bitwise_append` to append keys to the original bitwise values.

```ruby
user.role_bitwise = []
user.role_bitwise_append(:member)
p user.role_bitwise # [:member]
user.role_bitwise_append(['admin', 'member'])
p user.role_bitwise # [:member, :admin]
```

Moreover, some class methods are provided:

```ruby
User.role_bitwise.to_bitwise(3) # [:member, :manager]
User.role_bitwise.to_column(:admin) # 4
User.role_bitwise.to_column([:member, :admin]) # 5
User.role_bitwise.mapping # { member: 1, manager: 2, admin: 3 }
User.role_bitwise.keys # [:member, :manager, :admin]

User.role_bitwise.input_options # [["Member", "member"], ["Manager", "manager"], ["Admin", "admin"]]
User.role_bitwise.input_options(only: [:member, :admin]) # [["Member", "member"], ["Admin", "admin"]]
User.role_bitwise.input_options(except: [:member]) # [["Manager", "manager"], ["Admin", "admin"]]
```

### Pure ruby class

You can use bitwise column in a pure ruby class, just setup bitwise_column as follows:

```ruby
class Admin
  attr_accessor :role

  include BitwiseColumn
  bitwise_column :role, {
    member: 1,
    manager: 2,
    admin: 3,
    finance: 4,
    marketing: 5
  }
end
```

Then you can use the bitwise column in your ruby object just like above examples.

### I18n

You can use bitwise column with i18n, it will find locales according to the following lookup paths.

```ruby
bitwise_column.user.role.member
activerecord.attributes.user.role/member
activemodel.attributes.user.role/member
```

You can choose one of them to use. For example:

```ruby
zh-TW:
  bitwise_column:
    user:
      role:
        member: '成員'
        manager: '管理人員'
        admin: '系統管理員'
```

Moreover, you can use `i18n_scope` option in bitwise_column to change the locale lookup path, for example:

```ruby
class User < ActiveRecord::Base
  include BitwiseColumn
  bitwise_column :role, {
    member: 1,
    manager: 2,
    admin: 3,
  }, i18n_scope: ['my.role', 'app.role', 'role']
end
```
The locale lookup paths will be changed to the following ones:

```ruby
my.role.member
app.role.member
role.member
bitwise_column.user.role.member
activerecord.attributes.user.role/member
activemodel.attributes.user.role/member
```

When locale files are ready, you can use `_bitwise_text` to display the translated text.

```ruby
user.role_bitwise = :member
p user.role_bitwise_text # ["成員"]
user.role_bitwise = [:member, :admin]
p user.role_bitwise_text # ["成員", "系統管理員"]
```

The class method `input_options` will use the translated text as well.

```ruby
User.role_bitwise.input_options # [["成員", "member"], ["管理人員", "manager"], ["系統管理員", "admin"]]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Test

Just run

    ruby ./spec/all_spec.rb

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bitwise_column/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Authors

Sibevin Wang

## Copyright

Copyright (c) 2017 Sibevin Wang. Released under the MIT license.
