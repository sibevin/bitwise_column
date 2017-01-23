
require 'active_model'
require 'action_controller'
require 'action_view'
ActionView::RoutingUrlFor.send(:include, ActionDispatch::Routing::UrlFor)
require 'action_view/template'
require 'action_view/test_case'
module Rails
  def self.env
    ActiveSupport::StringInquirer.new("test")
  end
end
if ActiveSupport::TestCase.respond_to?(:test_order=)
  ActiveSupport::TestCase.test_order = :random
end
require 'simple_form'


require 'active_record'
silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.integer :role, null: false, default: 0
  end
end

class User < ActiveRecord::Base
  include BitwiseColumn
  bitwise_column :role, {
    member: 1,
    manager: 2,
    admin: 3,
    finance: 4,
    marketing: 5
  }
end

describe BitwiseColumn do
  include SimpleForm::ActionViewExtensions::FormHelper

  describe "#<<" do
    it 'renders multiple select with selected enumerized value' do
      u = User.new
      u.role_bitwise = [:member, :admin]
      u.save
      concat(simple_form_for(u) do |f|
        f.input(:role_bitwise)
      end)
      assert_select 'select[multiple=multiple]'
      assert_select 'select option[value=member][selected=selected]'
      assert_select 'select option[value=admin][selected=selected]'
      assert_select 'select option[value=marketing][selected=selected]', count: 0
      assert_select 'select option[value=finance][selected=selected]', count: 0
      assert_select 'select option[value=manager][selected=selected]', count: 0
    end
  end
end
