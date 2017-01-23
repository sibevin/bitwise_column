class User2
  attr_accessor :role
  def initialize(role:0)
    @role = role
  end
end

ROLE_MAP = {
  member: 1,
  manager: 2,
  admin: 3,
  finance: 4,
  marketing: 5,
  tester: 7
}

describe BitwiseColumn::Core do
  describe "#col" do
    it "should return col name" do
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.col.must_equal :role
    end
  end

  describe "#append" do
    it "should append multiple values" do
      u = User2.new(role: 8)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.append(u, [:member, "marketing", :admin]).must_equal 29
      core.append(u, [:manager, "admin"]).must_equal 14
    end

    it "should append a single value" do
      u = User2.new(role: 1)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.append(u, :admin).must_equal 5
      core.append(u, :member).must_equal 1
      core.append(u, "finance").must_equal 9
    end

    it "should return original col value if given bitwise value is invalid" do
      u = User2.new(role: 8)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.append(u, :invalid_role).must_equal 8
      core.append(u, "invalid_role").must_equal 8
    end
  end

  describe "#assign" do
    it "should assign mulitple values" do
      u = User2.new(role: 8)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.assign(u, [:admin, "member", :admin]).must_equal 5
      core.assign(u, [:member]).must_equal 1
      core.assign(u, [:admin, "finance"]).must_equal 12
    end

    it "should assign a single value" do
      u = User2.new(role: 1)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.assign(u, :admin).must_equal 4
      core.assign(u, :member).must_equal 1
      core.assign(u, "finance").must_equal 8
    end

    it "should return original col value if given bitwise value is invalid" do
      u = User2.new(role: 8)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.assign(u, :invalid_role).must_equal 8
      core.assign(u, "invalid_role").must_equal 8
    end

    it "should return 0 if given bitwise value is nil" do
      u = User2.new(role: 8)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.assign(u, nil).must_equal 0
    end

    it "should return 0 if given bitwise value is an empty array" do
      u = User2.new(role: 8)
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.assign(u, []).must_equal 0
    end
  end

  describe "#have?" do
    it "should check a single value is included" do
      u = User2.new(role: 5) # [:admin, :member]
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.have?(u, :admin).must_equal true
      core.have?(u, :manager).must_equal false
    end

    it "should check given values are all included" do
      u = User2.new(role: 13) # [:admin, :member, :finance]
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      core.have?(u, [:admin, :finance]).must_equal true
      core.have?(u, [:manager, :admin]).must_equal false
    end
  end

  describe "#bitwise_value" do
    it "should return bitwise value" do
      u = User2.new
      core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP)
      u.role = 7
      core.bitwise_value(u).must_equal [:member, :manager, :admin]
      u.role = 12
      core.bitwise_value(u).must_equal [:admin, :finance]
    end
  end
end
