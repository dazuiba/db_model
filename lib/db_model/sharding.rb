class DBModel::Sharding
	DEV_DB = (0..7).map{|e|"dev_db1_icuser#{e}"}
	DEV_DB += (8..15).map{|e|"dev_db2_icuser#{e}"}
	
	def self.db(auction_id)
		if auction_id.is_a?(Integer)
			auction_id.strip!
			raise "输入非法, auction_id应为全数字， 例如：1498124127" unless auction_id=~/^\d+$/
		end
		num = auction_id.to_i%16
		db = num > 7 ? 2 : 1 
		DmConfig.database("dev_db#{db}_icuser#{num}")
	end
	
	def self.execute_on_all(sql, options={})
		dev_dbs.map{|db|db.execute sql}
	end
	
	def self.search_auction_id(key, value)
		result = nil
		result_db   = nil
		dev_dbs.each{|db|		
			result_db = db
			result = db[:auction_auctions].first(key => value)
			break if result
		}		
		result&&result.auction_id
	end	
	
	def self.dev_dbs
		@dev_dbs ||= begin
			DEV_DB.map{|str|DBModel::DB[str]}
		end
	end
end