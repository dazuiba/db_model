module DBModel
	class Database		
		DEFAULT_LIMIT = 50
		MAX_LIMIT     = 300
		attr_accessor :uri, :options, :db_key
		
		
		def self.limit_num(num)			
	  	limit =  num.to_i
	  	limit = DEFAULT_LIMIT if limit < 1	 
	  	limit = MAX_LIMIT if limit > MAX_LIMIT
	  	limit
		end
		
		def self.parse(db_key, uri)
			clazz = if uri=~/^mysql/i
				MysqlDB
			else
				OracelDB
			end
			
			clazz.new(db_key, uri)
		end 
		
		def initialize(db_key, uri)
			@db_key = db_key
			@uri , @options = uri.split("?")
			@options = if @options
				CGI.parse(@options).build_hash{|k,v|[k.to_sym, v.first]}
			else
				{}
			end
		end
		
		def avaliable?
			test_connection
		end
		
		def connect(opt={})
			@db_impl = Sequel.connect(uri, options.merge(opt))
			@db_impl.db_key = db_key
			configure_connection
			self
		end
		
		def method_missing(name, *args)
			@db_impl.send(name, *args)
		end
		
		def user_tables
			tables
		end
		
		def pk_infos
			assert false, "Implement ME!!"
		end
		
		protected
		
		def db_impl
			@db_impl
		end

		# overwrite me!
		def configure_connection
			#empty method 	
		end
	end
	
	class MysqlDB < Database
		def configure_connection
		  execute("SET NAMES '#{options[:encoding]}'") if options[:encoding] 
		end
	end
	
	class OracelDB < Database
		
		def user_tables			
			@tables||=@db_impl[:user_tables].select(:table_name).order(:table_name).all.map{|e|e.table_name.downcase}
		end
		
		def pk_infos
			db_impl[%[select cons.table_name, cols.column_name 
			from user_constraints cons , tab, user_cons_columns cols
			where cons.table_name = tab.tname
			and   cons.constraint_name = cols.constraint_name
			and tab.tabtype = 'TABLE'
			and cons.constraint_type = 'P']]
		end
	end
end