describe BitwiseColumn::I18nHandler do
  describe '#translate' do
    it 'should find the locale with given column name' do
      role_locale = {
        bitwise_column: {
          user3: {
            role: {
              member: 'BitwiseColumn User Member'
            }
          }
        },
        activerecord: {
          attributes: {
            user3: {
              'role/member': 'ActiveRecord User Manager',
              'role/manager': 'ActiveRecord User Manager'
            }
          }
        },
        activemodel: {
          attributes: {
            user3: {
              'role/member': 'ActiveModel User Manager',
              'role/manager': 'ActiveModel User Manager',
              'role/admin': 'ActiveModel User Admin'
            }
          }
        }
      }
      I18n.backend.store_translations(:en, role_locale)
      I18n.default_locale = :en
      test_cases = {
        member: 'BitwiseColumn User Member',
        manager: 'ActiveRecord User Manager',
        admin: 'ActiveModel User Admin',
        customer_service: 'Customer Service'
      }
      User3 = Class.new
      handler = BitwiseColumn::I18nHandler.new(User3, 'role')
      test_cases.each do |role, result|
        handler.translate(role).must_equal(result)
      end
    end

    it 'should use default locale with given column name if locale is not found' do
      test_cases = {
        member: 'Member',
        manager: 'Manager',
        admin: 'Admin',
        customer_service: 'Customer Service'
      }
      User4 = Class.new
      handler = BitwiseColumn::I18nHandler.new(User4, 'role')
      test_cases.each do |role, result|
        handler.translate(role).must_equal(result)
      end
    end

    it 'should use customized i18n scope if i18n_scope options is given' do
      role_locale = {
        my: {
          role: {
            member: 'My Role Member'
          }
        },
        app: {
          role: {
            member: 'App Role Member',
            manager: 'App Role Manager'
          }
        },
        role: {
          member: 'Role Member',
          manager: 'Role Manager',
          admin: 'Role Admin'
        },
        bitwise_column: {
          user5: {
            role: {
              member: 'Default Member',
              manager: 'Default Manager',
              admin: 'Default Admin',
              customer_service: 'Default Customer Service'
            }
          }
        }
      }
      I18n.backend.store_translations(:en, role_locale)
      I18n.default_locale = :en
      test_cases = {
        member: 'My Role Member',
        manager: 'App Role Manager',
        admin: 'Role Admin',
        customer_service: 'Default Customer Service'
      }
      User5 = Class.new
      handler = BitwiseColumn::I18nHandler.new(User5, 'role', i18n_scope: ['my.role', 'app.role', 'role'])
      test_cases.each do |role, result|
        handler.translate(role).must_equal(result)
      end
    end
  end
end
