class EmailDayPreference < ActiveRecord::Base
  belongs_to :user
    
  Monday = "Monday"
  Tuesday = "Tuesday"
  Wednesday = "Wednesday"
  Thursday = "Thursday"
  Friday = "Friday"
  Saturday = "Saturday"
  Sunday = "Sunday"
  
  DaysOfWeek = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
  
  validates_inclusion_of :day_of_week, :in => DaysOfWeek
  
end