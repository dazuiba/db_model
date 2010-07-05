require "sequel"
require 'singleton'
module DBModel
	
	class DbNotFound < RuntimeError
	end
	
	class DBRepository
		include Singleton	
		include DBModel::HttpLoader	
	  include DBUtils
				
		def [](key)
			check_setup
			key = key.to_s
			@connection_cache[key]||= do_connect(key)
		end		
		
		def size
			check_setup
			@db_hash.values.size
		end
		
		def empty?
			check_setup
			@db_hash.empty?
		end
		
		def setuped?
			!!@db_hash
		end
		
		private
		def check_setup			
			if !setuped?
				setup(DBModel.db_config) 
			end
		end
		
				
		def setup(hash)
			assert !setuped?
			@db_hash = hash
			@connection_cache = {}
		end
		
		def do_connect(key)			
			require "db_model/sequel_patch"
			if uri = @db_hash[key]
				Database.parse(key, uri).connect(:loggers=>[DBModel.logger])
			else
				raise(DbNotFound) 
			end
		end
	end
end