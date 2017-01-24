module BitwiseColumn
  class NullI18nHandler
    def initialize(_klass, _col_name)
    end

    def translate(value)
      value.to_s.split('_').map(&:capitalize).join(' ') # user_admin -> User Admin
    end
  end
end
