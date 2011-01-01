class EmailDayPreference < ActiveRecord::Base
  belongs_to :user
    
  Monday = "monday"
  Tuesday = "tuesday"
  Wednesday = "wednesday"
  Thursday = "thursday"
  Friday = "friday"
  Saturday = "saturday"
  Sunday = "sunday"
  
  DaysOfWeek = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
  
  validates_inclusion_of :day_of_week, :in => DaysOfWeek
end