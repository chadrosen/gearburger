# Configure logging.
# We use various outputters, so require them, otherwise config chokes
require 'rubygems'
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/fileoutputter'
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/emailoutputter'

cfg = Log4r::YamlConfigurator
cfg['RAILS_ROOT'] = Rails.root.to_s
cfg['RAILS_ENV']  = Rails.env.to_s

# re-open the logger class to add a method to log exceptions and their stack traces
Log4r::Logger.class_eval do
 def exception(ex, msg = nil)
   self.error(msg) if msg
   self.error("#{ex.class}: #{ex.message}")
   ex.backtrace.each {|frame| self.error("\t#{frame}")}
 end
end

# load the YAML file with this
cfg.load_yaml_file("#{Rails.root.to_s}/config/log4r.yaml")

# CHAD: 11/17/10 Not sure I want to replace this....
#RAILS_DEFAULT_LOGGER = Log4r::Logger['default']
#RAILS_DEFAULT_LOGGER.level = (Rails.env == 'development' ? Log4r::DEBUG : Log4r::INFO)

if Rails.env == 'test'
  Log4r::Outputter['datefilelog'].level = Log4r::OFF
  Log4r::Outputter['stderr'].level = Log4r::OFF    
elsif Rails.env == "production"
  Log4r::Outputter['stderr'].level = Log4r::OFF  
  #Log4r::Outputter['standardlog'].level = Log4r::OFF
end