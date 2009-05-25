require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase
  
<% for attribute in (attributes.select {|att| att.name.ends_with?("_id")}) -%>
  <%= "# should_belong_to :#{attribute.name[0..-4]}" %>
<% end -%>
  
  def test_truth
    assert true
  end
end
