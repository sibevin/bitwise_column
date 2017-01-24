class User4
  attr_accessor :role
  def initialize(role:0)
    @role = role
  end
end

describe BitwiseColumn::NullI18nHandler do
  describe '#translate' do
    it 'should find the locale with given column name' do
      test_cases = {
        member: 'Member',
        manager: 'Manager',
        admin: 'Admin',
        customer_service: 'Customer Service'
      }
      handler = BitwiseColumn::NullI18nHandler.new(User4, 'role')
      test_cases.each do |role, result|
        handler.translate(role).must_equal(result)
      end
    end
  end
end
