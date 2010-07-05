module DBModel
	class Record
			attr_accessor :dataset, :hash, :db, :table, :inner_dataset
			
			def self.create_by_ds(ds, hash)
				result = self.new(ds.db, ds.table_name, hash)
				result.inner_dataset = ds
				result
			end
			
			def initialize(db,table, hash)
				@db = db
				@table = table
				@hash = hash.stringify_keys
			end
			
			def [](key)
				check_column(key)
				@hash[key.to_s]
			end
			
			def []=(key, value)
				check_column(key)
				@hash[key.to_s] = value
			end
			
			
			def save
				trans_and_error{
					if pk_hash.values.any?{|e|e.is_a?(Sequel::LiteralString)}
						#发现有LiteralString, 直接执行create
						create
					else
						create_or_update
					end
				}
			end
			
			def reload
				pk_filter.first
			end
			
			def update				
				trans_and_error{pk_filter.update(web_sql_attributes)}
			end
			
			def create
				trans_and_error{
					inserted = false
					if pk_hash.keys.size == 1 
						pk, pk_value = pk_hash.to_a.first
						puts "#{pk}, #{pk_value}, #{seq = inner_dataset.opts[:sequence]}"
						if pk_value.blank? && !(seq = inner_dataset.opts[:sequence]).blank?
							iid = pk_filter.insert(web_sql_attributes.merge(pk => "#{seq}.nextval".lit))
					  	self.merge(pk => iid)
					  	inserted = true
						end						
					end	
					
					if !inserted
						pk_filter.insert(web_sql_attributes)
					end	
					self
				}
			end
			
			def delete
				trans_and_error{pk_filter.delete}
			end
			
			def inspect
				"#<Record " + @hash.inspect + ">"
			end
			
			def id
				if hash_include?("id")
					@hash["id"]
				else
					super
				end
			end
			
			def exsit?
				pk_filter.count > 0
			end
			
	    def merge(overwrites)
	    	@hash.merge!(overwrites.stringify_keys)
	    	self
	    end
	    
	    def class
	      DBModel::Record
	    end	    
			private		
			
			def trans_and_error(options={}, &block)
				inner_dataset.db.transaction do
					begin
						yield
					rescue Sequel::Error => e
							raise DBModel::DmError, "Error when save a record. Message is : \t"+ e.message
					end
				end
			end
			
			def create_or_update
				exsit? ? update : create 
			end
			
			def check_column(col)
				if !@hash.include?(col.to_s)
					raise ColumnNotFound, "#{col} not found in table #{table}"
				end
			end
			
	    def pk_filter
	    	inner_dataset.pk_filters(web_sql_attributes)
	    end
	    
	    def pk_hash
	    	inner_dataset.pk_columns.build_hash{|e|[e, web_sql_attributes[e]]}
	    end
	    
			def web_sql_attributes
				@hash
			end
			
			def inner_dataset
				@inner_dataset ||= DBModel::DB[@db.db_key][@table.to_sym]
			end
			
			def method_missing(name, *args, &block)       
				if hash_include?(name)
				  attr_name = name.to_s.chomp("=")			
					(name.to_s =~ /=$/) ? (@hash[attr_name] = *args) :  @hash[attr_name]  
				elsif @hash.respond_to?(name)
					@hash.send(name, *args,&block)
				else
					super
				end
			end
			
			def hash_include?(name)
				@hash.include? name.to_s.chomp("=")
			end
			
		end
end