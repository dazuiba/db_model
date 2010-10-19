require File.dirname(__FILE__)+"/dm_test_helper"
class MySqlInvalidValueTest < Test::Unit::TestCase
  def test_invalid_time
		assert_nothing_raised do
		 puts DB['bbc'][:bbc_user].first(:user_id => 10).gmt_modified
		end
  end
end