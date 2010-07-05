require 'sequel/adapters/mysql.rb'
module Sequel
  class Database
  	attr_accessor :db_key
  	
  	def inspect
  		"#<Database #{db_key}>"
  	end
  	
  	private  	
  	def server_opts_with_patch(server)
  		result = server_opts_without_patch(server)
  		result.delete(:database) if result[:database].blank?
  		result
  	end
  	alias_method_chain :server_opts, :patch
  	
	end
  module MySQL
		class Dataset
			private
			
			def convert_type(v, type)
        begin
        	super
        rescue Exception => e
        	v.to_s
        end
      end

		end	
	end
end
