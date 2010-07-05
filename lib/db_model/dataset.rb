module Sequel
  class Dataset
    include DBModel::HttpLoader
    def websql_init(key,hash={})
      record = DBModel::Record.create_by_ds(self, 
                          web_get("dm_sql", {:id => key, :db => db.db_key, :table => table_name}))
      record.merge(hash)
      record
    end  
  
    def each(&block)
    	begin
	    	if @opts[:graph]
	        graph_each(&block)
	      elsif row_proc = @row_proc
	        fetch_rows(select_sql){|r| yield row_proc.call(DBModel::Record.create_by_ds(self, r))}
	      else
	        fetch_rows(select_sql){|r| yield DBModel::Record.create_by_ds(self, r)}
	      end
	      self
    	rescue Sequel::DatabaseError => e
    		raise DBModel::DmError, e.message
    	end
    end
  	
    def websql_create(key, overwrites={})
      a = websql_init(key, overwrites)
      a.create
    end 
    
    def websql_save(key, overwrites={})
      a = websql_init(key, overwrites)
      a.save
    end
    
    def websqls(options={})
    	raise "Not Implement"
    end
        
    def websql_save(key, overwrites={})
      a = websql_init(key, overwrites)
      a.save
    end
     
    def pk_filters(hash)
    	hash = hash.slice(*pk_columns)
    	if hash.keys.size < 1
    		raise DBModel::DmError, "should at least one primiry key"
    	end
    	result = unfiltered.filter(hash.symbolize_keys)
    	if !(seq = self.opts[:sequence]).blank?
  		 result = result.sequence(self.opts[:sequence])	
    	end
    	result
    end
    
    def table_name        
      begin
        first_source_alias
      rescue Sequel::Error => e
        match = (/from (\w+)/.match self.sql.downcase.gsub("`",""))
        match && match[1]
      end        
    end
    
    def pk_columns
    	@pk_columns ||= begin
    		r = web_get("table_info",{:db => db.db_key, :table => table_name})
    		if r.empty?
    			raise DBModel::DmError, "primery key not set for table#{db.db_key}/#{table}"
    		end
    		r.map(&:to_s)
    	end
    end  
   
  end
end