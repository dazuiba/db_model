module DBUtils		
	#thanks to boyi
	def guid(seed="")
		require 'md5'
		str = seed.to_s
    str << "%.6f" % Time.now.to_f;
    str << srand.to_s
    MD5.hexdigest  str
	end	
end