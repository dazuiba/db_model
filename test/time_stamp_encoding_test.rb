require File.dirname(__FILE__)+"/dm_test_helper"
class TimeStampEncodingTest < Test::Unit::TestCase
  def test_encoding_oci8
    a=DB['dev_crm_crm2'][:knowledge_base].first
    a.bulletin_type = 999
    a.subject = 'ÔõÃ´ÐÞ¸Äµê±ê2'.to_gbk
    a.save
  end
end