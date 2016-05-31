require 'active_record'
require 'logger'

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.integer :role, null: false, default: 0
  end
end

class User < ActiveRecord::Base
  include BitwiseColumn
  bitwise_column :role, {
    member: 1,
    manager: 2,
    admin: 3,
    finance: 4,
    marketing: 5
  }
end

describe BitwiseColumn do
  describe "#append" do
    it "should append multiple values" do
      u = User.new(role: 8)
      u.role_bitwise_append [:member, "marketing", :admin]
      u.role.must_equal 29
      u.role_bitwise_append [:manager, "admin"]
      u.role.must_equal 31
    end

    it "should append a single value" do
      u = User.new(role: 1)
      u.role_bitwise_append :admin
      u.role.must_equal 5
      u.role_bitwise_append :member
      u.role.must_equal 5
      u.role_bitwise_append "finance"
      u.role.must_equal 13
    end

    it "should return original col value if given bitwise value is invalid" do
      u = User.new(role: 8)
      u.role_bitwise_append :invalid_role
      u.role.must_equal 8
      u.role_bitwise_append "invalid_role"
      u.role.must_equal 8
    end
  end

  describe "#=" do
    it "should assign mulitple values" do
      u = User.new(role: 8)
      u.role_bitwise = [:admin, "member", :admin]
      u.role.must_equal 5
      u.role_bitwise = [:member]
      u.role.must_equal 1
      u.role_bitwise = [:admin, "finance"]
      u.role.must_equal 12
    end

    it "should assign a single value" do
      u = User.new(role: 1)
      u.role_bitwise = :admin
      u.role.must_equal 4
      u.role_bitwise = :member
      u.role.must_equal 1
      u.role_bitwise = "finance"
      u.role.must_equal 8
    end

    it "should return original col value if given bitwise value is invalid" do
      u = User.new(role: 8)
      u.role_bitwise = :invalid_role
      u.role.must_equal 8
      u.role_bitwise = "invalid_role"
      u.role.must_equal 8
    end
  end

  describe "#have?" do
    it "should check a single value is included" do
      u = User.new(role: 5) # [:admin, :member]
      u.role_bitwise_have?(:admin).must_equal true
      u.role_bitwise_have?(:manager).must_equal false
    end

    it "should check given values are all included" do
      u = User.new(role: 13) # [:admin, :member, :finance]
      u.role_bitwise_have?([:admin, :finance]).must_equal true
      u.role_bitwise_have?([:manager, :admin]).must_equal false
    end
  end

  describe "#role_bitwise" do
    it "should return bitwise value" do
      u = User.new
      u.role = 7
      u.role_bitwise.must_equal [:member, :manager, :admin]
      u.role = 12
      u.role_bitwise.must_equal [:admin, :finance]
    end
  end
end
