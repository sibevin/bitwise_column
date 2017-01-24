module BitwiseColumn
  class I18nHandler
    def initialize(klass, col_name)
      @klass_name = klass.name.gsub(/(.)([A-Z])/, '\1_\2').downcase # UserAdmin -> user_admin
      @col_name = col_name
    end

    def translate(value)
      if Object.const_defined?(:I18n)
        i18n_keys = ["bitwise_column.#{@klass_name}.#{@col_name}.#{value}"]
        i18n_keys << "activerecord.attributes.#{@klass_name}.#{@col_name}/#{value}"
        i18n_keys << "activemodel.attributes.#{@klass_name}.#{@col_name}/#{value}"
        i18n_keys.each do |key|
          begin
            return I18n.t!(key)
          rescue I18n::MissingTranslationData
            next
          end
        end
      end
      value.to_s.split('_').map(&:capitalize).join(' ') # user_admin -> User Admin
    end
  end
end
