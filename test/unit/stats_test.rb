require File.dirname(__FILE__) + '/../test_helper'

class StatsTest < ActiveSupport::TestCase
  
  def test_get_date_from_nil
    
    sd, ed = Stats::get_date_range_from_strings()
    td = Date.today
    assert_equal sd, Time.local(td.year, td.month, td.day, 0,0,0)
    assert_equal ed, Time.local(td.year, td.month, td.day, 23,59,59)
  end
  
  def test_get_date_from_strings
    
    td = Date.today - 1
    
    sd, ed = Stats::get_date_range_from_strings(:start_date => td.to_s, :end_date => td.to_s)
    assert_equal sd, Time.local(td.year, td.month, td.day, 0,0,0)
    assert_equal ed, Time.local(td.year, td.month, td.day, 23,59,59)    
  end
  
end