#
#采用Composite模式， 将一组Database作为child_dbs封装起来
#
module DBModel
	class GroupDatabase < Sequel::Database
		attr_accessor :child_dbs, :db_key
		
		#taobao 主库
		def self.taobao_db(options={})
			@taobao_db||= begin
				db = (0..7).map{|e|"dev_db1_icuser#{e}"}
				db += (8..15).map{|e|"dev_db2_icuser#{e}"}			
				GroupDatabase.new("group_db", db.map{|e|DB[e]}, options)
			end		
		end
		
		def initialize(db_key, child_dbs, options={})
			@db_key = db_key
			assert child_dbs.size>1
			@child_dbs = child_dbs
			@main_db = child_dbs.first
			@loggers = options[:loggers]
		end
		
		def [](*args)
			raise "This method is not supported on Group DB, current db is #{self.db_key}"
		end
		
		def find_all(sql)
			@child_dbs.map{|db|db.find_all(sql)}.flatten
		end	
		
		
		def sum_all(sql)
			sum_all_records find_all(sql)
		end
		
		
		
		def find_first(sql)
			result = nil
			@child_dbs.each{|db|
				result = db.find_first(sql)
				break if result
			}
			result
		end	
		
		def execute(sql)		
			log_yield(sql){
				DBModel.logger.silence{
					@child_dbs.map{|db|
		        db.execute(sql)
		      }
				}
			}	
		end	
			
		private
		
		
        
    def sum_all_records(records)  	
  		result = records.first        		
  		records[1..-1].each do |rec|
  			result.keys.each do |k|
  				result[k] = result[k]+rec[k]
  			end
  		end
  		result
    end
		
		def method_missing(name, *args)
			@main_db.send(name, *args)
		end
	end
end