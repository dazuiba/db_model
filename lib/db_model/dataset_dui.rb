module DBModel
	
	module DatasetDui
		def self.included(ds)
			ds.send :include, InstanceMethods
			ds.class_eval do
			  alias_method_chain :delete, :sqlcheck
			  alias_method_chain :update, :sqlcheck
		  end
		end
		
		module InstanceMethods
			def delete_with_sqlcheck
				sql_check{delete_without_sqlcheck}
			end
			
			def update_with_sqlcheck(values={})
				sql_check{update_without_sqlcheck(values)}
			end
			
			def truncate
				raise SQLCheckError, "Could not execute truncate"
			end
			
			private
			def sql_check(&block)
				if self.opts[:where].nil?
					raise(SQLCheckError, "Cannot Find where clause in your SQL expression") 
				end
				
				if DBModel[:sqlcheck_level] && count > DBModel[:sqlcheck_level]
					raise(SQLCheckError, "result count is #{count}, greater than #{DBModel[:sqlcheck_level]}") 
				end
				yield
			end
		end
	end
end 