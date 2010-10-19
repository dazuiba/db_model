module DBModel
	module DatasetWebsql
    def websql_init(key,hash={})
      record = DBModel::Record.create_by_ds(self, 
                          web_get("dm_sql", {:id => key, :db => db.db_key, :table => table_name}))
      record.merge(hash)
      record
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
  
	end
end