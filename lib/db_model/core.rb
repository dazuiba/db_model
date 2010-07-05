module DBModel
	 class DmError < RuntimeError
 	 end
 	 class SQLError < RuntimeError
 	 end
 	 
 	 class HttpError< DmError
 	 end
 	 
	 class ColumnNotFound < DmError
   end
	 module HttpLoader
	 	def web_get(uri, params={})
	 		query = ""
	 		unless params.blank?
	 			query = "?"+params.to_query
 			end
	 		result = YAML.load(http_get(DBModel[:api]+uri+"#{query}"))
	 		if result.error
	 			raise HttpError, result.error
 			else
 				result.result
 			end
	 	end
	 	
	 	private
	 	def http_get(url)
	 		begin
	 			open(url).read	
	 		rescue StandardError => e
	 			raise DmError, "Error raised when reading url: #{url}, message is : \n\t#{e.message}"	
	 		end
	 	end
 	 end
end