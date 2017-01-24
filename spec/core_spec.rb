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
  marketing: 5
}

describe BitwiseColumn::Core do
  before do
    @i18n_handler = BitwiseColumn::I18nHandler.new(User2, :role)
    @core = BitwiseColumn::Core.new(col_name: :role, bitwise_map: ROLE_MAP, i18n_handler: @i18n_handler)
  end

  describe '#col' do
    it 'should return col name' do
      @core.col.must_equal :role
    end
  end

  describe '#have?' do
    it 'should check a single value is included' do
      @core.have?([:admin, :member], :admin).must_equal true
      @core.have?([:admin, :member], :manager).must_equal false
    end

    it 'should check given values are all included' do
      @core.have?([:admin, :member, :finance], [:admin, :finance]).must_equal true
      @core.have?([:admin, :member, :finance], [:manager, :admin]).must_equal false
    end
  end

  describe '#keys' do
    it 'should return the bitwise keys' do
      @core.keys.must_equal ROLE_MAP.keys
    end
  end

  describe '#mapping' do
    it 'should return the bitwise mapping' do
      @core.mapping.must_equal ROLE_MAP
    end
  end

  describe '#to_bitwise' do
    it 'should return the bitwise value with the given column value' do
      @core.to_bitwise(7).must_equal [:member, :manager, :admin]
      @core.to_bitwise(12).must_equal [:admin, :finance]
      @core.to_bitwise(0).must_equal []
      @core.to_bitwise(nil).must_equal []
    end
  end

  describe '#to_column' do
    it 'should return the column value with the given bitwise value' do
      @core.to_column([:member, :manager, :admin]).must_equal 7
      @core.to_column([:admin, :finance]).must_equal 12
      @core.to_column([]).must_equal 0
      @core.to_column(nil).must_equal 0
    end
  end

  describe '#input_options' do
    it 'should return the input options by given bitwise map' do
      @core.input_options.must_equal [
        %w(Member member),
        %w(Manager manager),
        %w(Admin admin),
        %w(Finance finance),
        %w(Marketing marketing)
      ]
    end
  end

  describe '#valid?' do
    it 'should check the given bitwise values are valid or not' do
      @core.valid?(:member).must_equal true
      @core.valid?(%w(admin member)).must_equal true
      @core.valid?(nil).must_equal true
      @core.valid?([]).must_equal true
      @core.valid?(:invalid_role).must_equal false
      @core.valid?('invalid_role').must_equal false
      @core.valid?([:member, :invalid_role]).must_equal false
    end
  end

  describe '#normalize' do
    it 'should transfer a string key to an symbol array' do
      @core.normalize('admin').must_equal [:admin]
    end

    it 'should transfer a single key to an array' do
      @core.normalize(:admin).must_equal [:admin]
    end

    it 'should return an array with unique values' do
      @core.normalize([:admin, :admin]).must_equal [:admin]
    end

    it 'should sort the given array by given mapping' do
      @core.normalize([:admin, :member]).must_equal [:member, :admin]
    end

    it 'should return an empty array if nil is given' do
      @core.normalize(nil).must_equal []
    end

    it 'should keep the invalid keys' do
      @core.normalize([:admin, :invalid_role]).must_equal [:admin, :invalid_role]
    end
  end
end
