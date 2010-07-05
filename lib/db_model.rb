# 
# 供客户端初始化使用
#
require 'active_support'         
require 'cgi'
require 'open-uri'                  
require 'ostruct'         
require 'sequel'
require 'db_model/db_utils'
require 'db_model/core'
require 'db_model/db_repository'
require 'db_model/database'
require 'db_model/dataset'
require 'db_model/record'
module DBModel
    Base = Sequel::Model
    DB   = DBModel::DBRepository.instance
		
	 class <<self
	  include DBModel::HttpLoader
	  attr_accessor :logger, :db_config
	  
    def set_tam_host(host)
      self[:api] = "http://#{host}/api/websql/"
    end

	  def Base(source)
	  	if source.is_a?(String)
				db, table = source.split("/")
				Sequel::Model(DB[db][table.to_sym])
			else
				Sequel::Model(source)
			end
	  end	  
	 	
	 	def logger
	 		@logger||=Logger.new(STDOUT)
	 	end
	 	
		def []=(key,value)
		  @globle||={}
		  @globle[key] = value
	  end
	  
	  def db_config	  	
			@db_config||=web_get("config")
	  end
	  
		def setup(url)			
			self[:api] = url
		end
		
		def [](key)
			@globle||={}
			result = @globle[key]
			if result.nil?
				raise DmError, "you should setup DBModel[:#{key.to_s}] first!" 
			end
			result
		end
  end
  
  class Base
		include DBModel
		class_inheritable_accessor :table_name
		
		def self.db_meta(options)
			self.table_name = options[:table].to_sym
			self.db = DB[options[:db]]
		end
	end
end

