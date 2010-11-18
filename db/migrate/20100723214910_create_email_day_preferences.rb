class CreateEmailDayPreferences < ActiveRecord::Migration
  def self.up
    create_table :email_day_preferences do |t|
      t.integer :user_id, :null => false
      t.enum :day_of_week, :limit => [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
      t.boolean :receive_email, :default => true, :null => false
    end
        
    EmailDayPreference.reset_column_information
    
    User.find(:all).each do |u|
      EmailDayPreference.create!(:day_of_week => :monday, :user_id => u)
      EmailDayPreference.create!(:day_of_week => :tuesday, :user_id => u)
      EmailDayPreference.create!(:day_of_week => :wednesday, :user_id => u)
      EmailDayPreference.create!(:day_of_week => :thursday, :user_id => u)
      EmailDayPreference.create!(:day_of_week => :friday, :user_id => u)
      EmailDayPreference.create!(:day_of_week => :saturday, :user_id => u)
      EmailDayPreference.create!(:day_of_week => :sunday, :user_id => u)
    end
    
    add_index(:email_day_preferences, [:user_id, :day_of_week])
    add_index(:email_day_preferences, [:day_of_week])
  end

  def self.down
    drop_table :email_day_preferences
  end
end
