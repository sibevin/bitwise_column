require 'active_record'

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.integer :role, null: false, default: 0
    t.integer :part, null: false, default: 0
  end
end

class User < ActiveRecord::Base
  include BitwiseColumn
  ROLES = {
    member: 1,
    manager: 2,
    admin: 3,
    finance: 4,
    marketing: 5
  }
  bitwise_column :role, ROLES

  PARTS = {
    it: 1,
    hr: 2,
    mk: 3
  }
  bitwise_column :part, PARTS
end

describe BitwiseColumn do
  describe '#append' do
    it 'should append multiple values' do
      u = User.new(role: 8)
      u.role_bitwise_append [:member, 'marketing', :admin]
      u.role.must_equal 29
      u.role_bitwise_append [:manager, 'admin']
      u.role.must_equal 31
    end

    it 'should append a single value' do
      u = User.new(role: 1)
      u.role_bitwise_append :admin
      u.role.must_equal 5
      u.role_bitwise_append :member
      u.role.must_equal 5
      u.role_bitwise_append 'finance'
      u.role.must_equal 13
    end

    it 'should return original col value if given bitwise value is invalid' do
      u = User.new(role: 8)
      u.role_bitwise_append :invalid_role
      u.role.must_equal 8
      u.role_bitwise_append 'invalid_role'
      u.role.must_equal 8
    end
  end

  describe '#=' do
    it 'should assign mulitple values' do
      u = User.new(role: 8)
      u.role_bitwise = [:admin, 'member', :admin]
      u.role.must_equal 5
      u.role_bitwise = [:member]
      u.role.must_equal 1
      u.role_bitwise = [:admin, 'finance']
      u.role.must_equal 12
    end

    it 'should assign a single value' do
      u = User.new(role: 1)
      u.role_bitwise = :admin
      u.role.must_equal 4
      u.role_bitwise = :member
      u.role.must_equal 1
      u.role_bitwise = 'finance'
      u.role.must_equal 8
    end

    it 'should return original col value if given bitwise value is invalid' do
      u = User.new(role: 8)
      u.role_bitwise = :invalid_role
      u.role.must_equal 8
      u.role_bitwise = 'invalid_role'
      u.role.must_equal 8
    end

    it 'should assign 0 to col value if given bitwise value is nil' do
      u = User.new(role: 1)
      u.role_bitwise = nil
      u.role.must_equal 0
    end

    it 'should return 0 to col value if given bitwise value is an empty array' do
      u = User.new(role: 1)
      u.role_bitwise = []
      u.role.must_equal 0
    end
  end

  describe '#have?' do
    it 'should check a single value is included' do
      u = User.new(role: 5) # [:admin, :member]
      u.role_bitwise_have?(:admin).must_equal true
      u.role_bitwise_have?('member').must_equal true
      u.role_bitwise_have?(:manager).must_equal false
    end

    it 'should check given values are all included' do
      u = User.new(role: 13) # [:admin, :member, :finance]
      u.role_bitwise_have?([:admin, :finance]).must_equal true
      u.role_bitwise_have?(%w(member admin)).must_equal true
      u.role_bitwise_have?([:manager, :admin]).must_equal false
    end
  end

  describe '#role_bitwise' do
    it 'should return bitwise value' do
      u = User.new
      u.role = 7
      u.role_bitwise.must_equal [:member, :manager, :admin]
      u.role = 12
      u.role_bitwise.must_equal [:admin, :finance]
    end

    it 'should return empty array if column value is nil' do
      u = User.new
      u.role = nil
      u.role_bitwise.must_equal []
    end

    it 'should return empty array if column value is 0' do
      u = User.new
      u.role = 0
      u.role_bitwise.must_equal []
    end
  end

  describe '.role_bitwise.keys' do
    it 'should return the bitwise keys' do
      User.role_bitwise.keys.must_equal User::ROLES.keys
    end
  end

  describe '.role_bitwise.mapping' do
    it 'should return the bitwise mapping' do
      User.role_bitwise.mapping.must_equal User::ROLES
    end
  end

  describe '.role_bitwise.to_bitwise' do
    it 'should return the bitwise value with the given column value' do
      User.role_bitwise.to_bitwise(7).must_equal [:member, :manager, :admin]
      User.role_bitwise.to_bitwise(12).must_equal [:admin, :finance]
      User.role_bitwise.to_bitwise(0).must_equal []
      User.role_bitwise.to_bitwise(nil).must_equal []
    end
  end

  describe '.role_bitwise.to_column' do
    it 'should return the column value with the given bitwise value' do
      User.role_bitwise.to_column([:member, :manager, :admin]).must_equal 7
      User.role_bitwise.to_column([:admin, :finance]).must_equal 12
      User.role_bitwise.to_column([]).must_equal 0
      User.role_bitwise.to_column(nil).must_equal 0
    end
  end

  describe '.role_bitwise.input_options' do
    it 'should return the input options by given bitwise map' do
      User.role_bitwise.input_options.must_equal [
        %w(Member member),
        %w(Manager manager),
        %w(Admin admin),
        %w(Finance finance),
        %w(Marketing marketing)
      ]
    end

    it 'should return the input options which are selected with the "only" option' do
      User.role_bitwise.input_options(only: [:admin, :marketing]).must_equal [
        %w(Admin admin),
        %w(Marketing marketing)
      ]
    end

    it 'should return the input options which are filtered with the "except" option' do
      User.role_bitwise.input_options(except: [:admin, :marketing]).must_equal [
        %w(Member member),
        %w(Manager manager),
        %w(Finance finance)
      ]
    end
  end
end
