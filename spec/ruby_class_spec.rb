class Admin
  include BitwiseColumn
  bitwise_column :role, {
    member: 1,
    manager: 2,
    admin: 3,
    finance: 4,
    marketing: 5
  }
  attr_accessor :role
  def initialize(role:0)
    @role = role
  end
end

describe BitwiseColumn do
  describe "#append" do
    it "should append multiple values" do
      a = Admin.new(role: 8)
      a.role_bitwise_append [:member, "marketing", :admin]
      a.role.must_equal 29
      a.role_bitwise_append [:manager, "admin"]
      a.role.must_equal 31
    end

    it "should append a single value" do
      a = Admin.new(role: 1)
      a.role_bitwise_append :admin
      a.role.must_equal 5
      a.role_bitwise_append :member
      a.role.must_equal 5
      a.role_bitwise_append "finance"
      a.role.must_equal 13
    end

    it "should return original col value if given bitwise value is invalid" do
      a = Admin.new(role: 8)
      a.role_bitwise_append :invalid_role
      a.role.must_equal 8
      a.role_bitwise_append "invalid_role"
      a.role.must_equal 8
    end
  end

  describe "#=" do
    it "should assign mulitple values" do
      a = Admin.new(role: 8)
      a.role_bitwise = [:admin, "member", :admin]
      a.role.must_equal 5
      a.role_bitwise = [:member]
      a.role.must_equal 1
      a.role_bitwise = [:admin, "finance"]
      a.role.must_equal 12
    end

    it "should assign a single value" do
      a = Admin.new(role: 1)
      a.role_bitwise = :admin
      a.role.must_equal 4
      a.role_bitwise = :member
      a.role.must_equal 1
      a.role_bitwise = "finance"
      a.role.must_equal 8
    end

    it "should return original col value if given bitwise value is invalid" do
      a = Admin.new(role: 8)
      a.role_bitwise = :invalid_role
      a.role.must_equal 8
      a.role_bitwise = "invalid_role"
      a.role.must_equal 8
    end
  end

  describe "#have?" do
    it "should check a single value is included" do
      a = Admin.new(role: 5) # [:admin, :member]
      a.role_bitwise_have?(:admin).must_equal true
      a.role_bitwise_have?(:manager).must_equal false
    end

    it "should check given values are all included" do
      a = Admin.new(role: 13) # [:admin, :member, :finance]
      a.role_bitwise_have?([:admin, :finance]).must_equal true
      a.role_bitwise_have?([:manager, :admin]).must_equal false
    end
  end

  describe "#role_bitwise" do
    it "should return bitwise value" do
      a = Admin.new
      a.role = 7
      a.role_bitwise.must_equal [:member, :manager, :admin]
      a.role = 12
      a.role_bitwise.must_equal [:admin, :finance]
    end
  end
end
