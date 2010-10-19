module DBModel
	module SQL
		SQLNotValid = Class.new(RuntimeError)
		ColumnNotExist= Class.new(RuntimeError)
		
		class << self
	    attr_accessor :global_table_processors
	    def set_table_default(table, defaults={})
	    	table = table.to_s.upcase
	    	found = table_processors.find{|e| e.table == table}
	    	if found
	    		#replace
	    		found.defaults = defaults
    		else
    			table_processors << TableProcessor.new(table, defaults)
  			end
	    end
	    	    
			def process(sql)				
				((global_table_processors||[])+table_processors).each do|e|					
					sql = e.process(sql)
				end
				sql
			end
			
			private
			def table_processors
				@table_processors||=[]
			end
	  end
	  
	  class TableProcessor
	  	def initialize(table, options)
	  		@table = table
	  		@defaults = options
	  	end
	  	
	  	def process(sql)	  		
	  		s = if sql.strip =~ /^\s*insert\s*into\s*#{@table}/i
					sql_obj = InsertSQL.new(sql.strip)
					sql_obj.set_default(@defaults)
					sql_obj.to_sql
				else
					sql
				end
				s
	  	end
  	end
  	
  	class SelectSQL
      PATTERN = /\s*select\s*(.+)\s*from/i
      attr_reader :select, :from, :where
      def initialize(sql)
      	@sql = sql      	
      	@valid = @sql =~ PATTERN
      	if @valid
      		set_select $1
      	end
      end
      
      def valid?
      	@valid
      end
                  
      def count?
      	self.select =~/^count\(?/
      end
      
      private      
      def set_select(select)
      	@select = select.strip
      end
		end

		
		class InsertSQL
			PATTERN = /\s*insert\s*into\s*(\w+)\s*\((.+?)\)\s*values\s*\((.+)\)/i
			SQL_PT = "insert into :table (:columns) values (:values)"
			VALUE_REG = /(\w+?\([^\(\)]*\)|'[^']*'|[^,\(\)']+?),/
			attr_reader :table, :columns, :values
		
			def initialize(sql)
				sql = sql.gsub("\n","")
				PATTERN =~ sql				
				set_table $1
				set_columns $2
				set_values $3
			end
			
			def set_default(hash={})
				check_attrs!
				hash.each{|k,v|
					begin						
				  	value,i = self.value_of(k,:with_index)
				  	if(value&&(value.to_s.blank?||value.to_s=~/null/i))
				 		 	self.values[i] = v
					  end
					rescue ColumnNotExist => e
						next
					end
				}
			end
			
			def value_of(key, options={})
				key = key.to_s.upcase
				i = columns.index(key)
				raise(ColumnNotExist, "key: #{key} not found" )if i.nil?
				v = self.values[i]
				if options[:with_index]
					 [v,i]
				else
					v
				end
			end
			
			def to_sql
				sql = SQL_PT.sub(":table", table)
				sql = sql.sub(":columns", columns.join(","))
				sql = sql.sub(":values", values.join(","))
				sql
			end
				
			def check_attrs!
				unless table&&values&&columns
					raise "attrs of #{inspect} is not valid"
				end
				if columns.size!=values.size
					raise "columns length vs values length should be equal"
				end
			end
			
			private
			def set_table(tb)
				@table = tb
			end
			
			def set_values(vl)
				if vl				
					@values = (vl+",").scan(VALUE_REG).map{|e|e.join("").strip}					  
				end
			end
			
			def set_columns(cl)				
				if cl
					@columns = cl.upcase.split(",").map{|e|e.strip}
				end
			end
			
		end
	end
end