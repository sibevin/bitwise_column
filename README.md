# BitwiseColumn

Using bitwise format to store multiple values in a single integer column.

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
user.role # nil
user.role_bitwise # []

# Assign bitwise values with the virtual column "role_bitwise", the role column is updated at the same time.
user.role_bitwise = :member
user.role # 1
user.role_bitwise # [:member]
user.role_bitwise = 'admin'
user.role # 4
user.role_bitwise # [:admin]

# You can use an array to assign bitwise values as well.
user.role_bitwise = [:member, :manager]
user.role # 3
user.role_bitwise # [:member, :manger]
user.role_bitwise = ['admin', 'member']
user.role # 5
user.role_bitwise # [:member, :admin]
user.role_bitwise = []
user.role # 0
user.role_bitwise # []

# You can change the original integer column directly, the role_bitwise is updated at the same time.
user.role = 7
user.role # 7
user.role_bitwise # [:member, :manager, :admin]
user.role = 0
user.role # 0
user.role_bitwise # []

# Use _bitwise_have? to check the given keys are included or not.
user.role_bitwise = [:member, :manger]
user.role_bitwise_have?(:member) # true
user.role_bitwise_have?('manager') # true
user.role_bitwise_have?(:admin) # false
user.role_bitwise_have?(['manager', 'member']) # true
user.role_bitwise_have?([:member, :admin]) # false

# Use _bitwise_append to append keys to the original bitwise values.
user.role_bitwise = []
user.role_bitwise_append(:member)
user.role_bitwise # [:member]
user.role_bitwise_append(['admin', 'member'])
user.role_bitwise # [:member, :admin]
```

Beside, some class methods are also provided:

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

You can use bitwise column in a pure ruby class, just setup betwise_column as follows:

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

Then you can use the bitwise column in your ruby object just like the above example.

### I18n

The i18n is supported by bitwise column, it would find the locales by symbols according to the following order:

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

When locale files are ready, you can use `_bitwise_text` to display the translated text:

```ruby
user.role_bitwise = :member
user.role_bitwise_text # ["成員"]
user.role_bitwise = [:member, :admin]
user.role_bitwise_text # ["成員", "系統管理員"]
```

If the locale is given, the class method `input_options` would use the translated text:

```ruby
User.bitwise_column.role.input_options # [["成員", "member"], ["管理人員", "manager"], ["系統管理員", "admin"]]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bitwise_column/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
