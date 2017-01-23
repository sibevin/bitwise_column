require 'i18n'

module BitwiseColumn
  class I18nHandler
    def initialize(klass, col_name)
      # UserAdmin -> user_admin
      @klass_name = klass.name.gsub(/(.)([A-Z])/, '\1_\2').downcase
      @col_name = col_name
    end

    def translate(value)
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
      value.to_s.capitalize
    end
  end
end
