require "net/telnet"
require "ping"
module DBModel
	module NetUtils
		DB_TRY_TIMEOUT = 3
		def telnet_error?(config)
			host = config[:host]
			if config[:adapter] =~ /mysql/i
				if host.blank?
					return "host_empty"
				else
					port = config[:port].blank? ? 3306 : Integer(config[:port])
					begin
						puts 
						Net::Telnet::new("Host"=>host, "Port" => port, "Timeout"=>DB_TRY_TIMEOUT).inspect
						return false
					rescue Exception => e
						return "telnet error: "+e.message
					end
				end
			end
			return false
		end
	end
end