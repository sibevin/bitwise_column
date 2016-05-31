class FakeCore
  attr_accessor :col
  def initialize
    @col = :core_name
  end
end

describe BitwiseColumn::CoreMap do
  describe "#<<" do
    it "should add a key-value with col as the key and the object as the value" do
      fc = FakeCore.new
      cm = BitwiseColumn::CoreMap.new
      cm << fc
      cm.include?(fc.col).must_equal true
      cm[fc.col].must_equal fc
    end
  end
end
