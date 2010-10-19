require "automan"
class BmwShop < Dm::Base("dev_ark_tbshop/bmw_shops")
	
	def find_feature(key)
		@feature_hash ||= self[:feature].split(";").build_hash{|e|
			k,v = e.split(":")
			if !v.blank?
				[k,v]
			else
				[nil,nil]
			end
		}

		@feature_hash[key]
	end
end

shop = BmwShop.find(:SHOP_ID=>45212478)
puts shop.find_feature("shopStats")# 1