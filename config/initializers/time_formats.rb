Time::DATE_FORMATS[:date_start] = Proc.new { |time| 
  time.strftime("#{time.strftime("%Y-%m-%d")} 00:00:00")
}

Time::DATE_FORMATS[:date_end] = Proc.new { |time| 
  time.strftime("#{time.strftime("%Y-%m-%d")} 23:59:59")
}
