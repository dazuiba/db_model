module Common
 
  #���ݿ��������
  class DataOperate < ActiveRecord::Base    
  	
     class << self
     	 #������ ��ֹ��tcommon�ĸ���
     	 @@encoding = "GBK"
       def set_connection_with_patch(connection,adapter = nil,encoding = nil)
          @dbm_current_db = connection['name']          
          @@encoding = encoding if encoding
        end
        alias_method_chain :set_connection, :patch
        
        def execute(sql,commit = true)
          clean_sql_exception(sql){dbm_db.execute(sql)}
        end
        
        def get_one(sql)
          sql = sql.to_s
          clean_sql_exception(sql){         
          	if DBModel::SQL::SelectSQL.new(sql).count?          		
          		conv_record dbm_db.sum_all(sql)
        		else
        	  	conv_record dbm_db.find_first(sql)
      	  	end
        	}
        end
        
        def get_all(sql)
          sql = sql.to_s
          conv_record clean_sql_exception(sql){dbm_db.find_all(sql)}
        end
        
        private
        
        def clean_sql_exception(sql,&block)
          begin 
             yield
          rescue Sequel::DatabaseError => e
            puts "[SQL����]���ݿ⣺#{@dbm_current_db}\nSQL: \t#{sql}"
            raise e
          end
        end
        
        def dbm_db
          DB[@dbm_current_db]
        end  	
     end
   end
end

class Dbconfig < ActiveRecord::Base    
   class << self
      def find_by_dbname(*arg)
        dbname = *arg[0]
        if dbname=~/^group_/
        	return {"name" => dbname}
      	end
        rs = self.find(:first,:select => "name, user username,adapter,host,db 'database',pwd password,port",:conditions => ["name = '#{dbname}'"])
        if rs.nil?
        	raise "�Ҳ������ݿ���Ϊ#{dbname}�����ݣ��뵽�������excel�ļ���DataMachine"
        else
        	rs.attributes
        end
      end
    end
  end