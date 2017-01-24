ROLE_LOCALE = {
  bitwise_column: {
    user3: {
      role: {
        member: 'User Member'
      }
    }
  },
  activerecord: {
    attributes: {
      user3: {
        'role/manager': 'User Manager'
      }
    }
  },
  activemodel: {
    attributes: {
      user3: {
        'role/admin': 'User Admin'
      }
    }
  }
}

class User3
  attr_accessor :role
  def initialize(role:0)
    @role = role
  end
end

describe BitwiseColumn::I18nHandler do
  before do
    I18n.backend.store_translations(:en, ROLE_LOCALE)
    I18n.default_locale = :en
  end

  describe '#translate' do
    it 'should find the locale with given column name' do
      test_cases = {
        member: 'User Member',
        manager: 'User Manager',
        admin: 'User Admin',
        customer_service: 'Customer Service'
      }
      handler = BitwiseColumn::I18nHandler.new(User3, 'role')
      test_cases.each do |role, result|
        handler.translate(role).must_equal(result)
      end
    end
  end
end
