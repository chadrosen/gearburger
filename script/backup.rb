#!/usr/bin/env ruby
require 'aws/s3'
require File.dirname(__FILE__) + '/../config/environment.rb' # Include rails environment
require 'optparse'

module DailyBackup

  class S3Handler
  
    def initialize(secret_key, secret_key_access, bucket_name)
    
      AWS::S3::Base.establish_connection!(
        :access_key_id => secret_key,
        :secret_access_key => secret_key_access
      )

      @bucket_name = bucket_name
      @bucket = nil   
      set_bucket()
    end
  
    def set_bucket()
      # Takes a bucket name and either gets the bucket from S3 or creates it
      begin
        @bucket = AWS::S3::Bucket.find(@bucket_name)
      rescue AWS::S3::NoSuchBucket => nsb
        AWS::S3::Bucket.create(@bucket_name)
        @bucket = AWS::S3::Bucket.find(@bucket_name)        
      end      
    end
  
    def item_exists?(item_name)
      # Does the item exist on S3
      AWS::S3::S3Object.exists?(item_name, @bucket_name)
    end
  
    def save_file(item_name, file)
      
      # TODO: Verify file is a file object
      
      if !item_exists?(item_name)
        AWS::S3::S3Object.store(item, file, @bucket_name)
      end
    end
    
  end

  class Backup
  
    def initialize(secret_key, secret_key_access, bucket, file_location)
      @s3 = S3Handler.new(secret_key, secret_key_access, bucket)
      @file_location = file_location
    end
  
    def backup_today
      # Take a backup of today
      today =  Time.today.strftime("%Y%m%d")
      file = self.get_file_by_date(today)
      return false unless file
      self.backup_file(today, file)
    end
  
    def get_file_by_date(date)
      # Check if the file exists for today
    
      full_file_name = nil

      # Get all of the entries in the directory
      Dir.new(@file_location).entries.each do |f|

        if File.fnmatch("#{date}*", f)
          full_file_name = f
          break
        end
      end
    
      return full_file_name
    end
  
    def backup_file(file_name, file)
      @s3.save_item(file_name, file)
    end
  end
end

def main
  b = Backup.initialize(OPTIONS[:access_key_id], OPTIONS[:secret_access_key], OPTIONS[:backup_location], 
    options[:bucket_name])
  b.backup_today()
end

if $0 == __FILE__
  main
end