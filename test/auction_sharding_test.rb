require File.dirname(__FILE__)+"/dm_test_helper"
class ShardingTest < Test::Unit::TestCase
  
	def test_db_sharding
		require 'tb/model/auction'
		Auction.first
  end
  
  def test_table_sharding
  	
  end
end