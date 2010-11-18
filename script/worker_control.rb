#!/usr/bin/env ruby
require 'optparse'
require 'yaml'
require 'erb'

def parse_command_line
  # parse the command line args into a hash of options
  script_name = File.basename($0)
  options = { :force => false }
      
  ARGV.options do |o|
    o.banner = "Usage: #{script_name} [options]"
    o.define_head "Controls worker process life cycle."
    
    # TODO: add a -i for info on which workers are running  
    o.on("-s","--start", "Start workers") {|v| options[:cmd] = :start  }
    o.on("-k","--kill", "Kill workers") {|v| options[:cmd] = :kill }
    o.on("-i","--info", "Show worker info") {|v| options[:cmd] = :info }
    o.on("-e","--env RAILS_ENV", String, "Rails environment") {|v| options[:env] = v }
    o.on("-w","--worker WORKER ID", String, "Choose a specific worker to start or kill") {|v| options[:worker] = v }
    o.on("-c", "--config CONF FILE", String, "Config file") {|v| options[:config] = v }
    o.on("-r", "--restart", "Restart workers") {|v| options[:cmd] = :restart }
    o.on("-f", "--force", "Force kill the worker after timeout." ) { |v| options[:force] = true }
    o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
    o.parse!
    
    if options[:cmd] == nil
      puts "Invalid usage: -s, -k, -r or -i must be specified"
      puts o
      exit
    end
    
    if options[:config] == nil
      puts "Invalid usage: A config file must be specified using -c"
      puts o
      exit
    end
    
  end
  
  return options  
end


def main
  # process command line args
  options = parse_command_line
  
  # load the rails environment
  env = options[:env]
  ENV['RAILS_ENV'] = env if env
  
  rails_root = File.join(File.dirname(__FILE__),'..')
  
  # read the config file
  config = nil
  File.open(options[:config]) {|f| config = YAML::load(ERB.new(f.read).result(binding)) }
  
  # we don't need the defaults section
  config.delete('defaults')
  
  # check to see the worker id passed in is valid
  if options[:worker] && !config.key?(options[:worker])
    raise Exception, "Worker ID #{options[:worker]} was not found in #{options[:config]}"
  end
        
  # generate the log and pid filenames if necessary
  config.each do |worker,worker_config|
    if !worker_config[:log_file]
      worker_config[:log_file] = File.join(worker_config[:log_dir], "#{worker}.log")
    end
    if !worker_config[:pid_file]
      worker_config[:pid_file] = File.join(worker_config[:pid_dir], "#{worker}.pid")
    end
  end
  
  # execute the command
  if options[:cmd] == :kill || options[:cmd] == :restart
    if options[:worker]
      kill_worker(options[:worker], config[options[:worker]], options[:force])
    else
      config.each {|worker,worker_config| kill_worker(worker, worker_config, options[:force])}
    end
  end
    
  if options[:cmd] == :start || options[:cmd] == :restart
    if options[:worker]
      start_worker(options[:worker], config[options[:worker]], options[:env])
    else
      config.each {|worker,worker_config| start_worker(worker, worker_config, options[:env])}
    end
  end

  if options[:cmd] == :info
    print_info(config)
  end
end


def print_info(config)
  config.each do |worker, worker_config|
    running = File.exist? worker_config[:pid_file]
    puts "#{worker}:\t#{worker_config[:enabled] ? 'enabled' : 'disabled'}\t#{running ? 'running' : 'stopped'}"
  end
  
end


def start_worker(worker_id, config, env)
  if !config[:enabled]
    puts "Not starting #{worker_id} because it is disabled"
    return
  end
  
  if File.exist? config[:pid_file]
    puts "Worker #{worker_id} is currently running (see #{config[:pid_file]})"
    return
  end
  
  child_id = fork
  if child_id
    puts "Created process #{child_id} for worker #{worker_id}"
  else
    # create the pid
    File.open(config[:pid_file], 'w') {|f| f << Process.pid }
    status_logger = nil
    begin
      # reopen standard I/O to unbind ourselves from the console
      STDIN.reopen "/dev/null"
      STDOUT.reopen "/dev/null", "a"
      STDERR.reopen STDOUT

      $LOG_FILE_NAME = worker_id

      # set up the rails environment
      ENV['RAILS_ENV'] = env if env
      require File.dirname(__FILE__) + '/../config/environment'
      
      # create the worker class and start working
      worker_class = config[:worker_class].constantize      
      worker = worker_class.new(worker_id, config)
      RAILS_DEFAULT_LOGGER.info("Starting worker with class: #{worker_class.to_s}.")
      worker.start
      RAILS_DEFAULT_LOGGER.info("Worker exited gracefully.")
    
    rescue SignalException => ex
      RAILS_DEFAULT_LOGGER.info("Shutting down.")
      status_logger.info("Stopped.")
    rescue Exception => ex
      # catch-all logging of exceptions
      RAILS_DEFAULT_LOGGER.exception(ex)
      RAILS_DEFAULT_LOGGER.error("Worker terminated unexpectedly.")      
      exit 1
    ensure
      File.delete(config[:pid_file])
    end
    exit 0
  end
  
end


def kill_worker(worker_id, config, force = false)
  if !File.exist? config[:pid_file]
    puts "Worker #{worker_id} is not currently running (see #{config[:pid_file]})"
    return
  end
  
  puts "Sending normal kill signal to worker #{worker_id} (#{config[:pid_file]})"
  system("kill `cat #{config[:pid_file]}`")
  
  count = 0
  while count < config[:kill_timeout]
    break unless File.exist? config[:pid_file]
    putc('.')
    sleep(1)    
    count+=1
  end
    
  if File.exist? config[:pid_file]
    # TODO: we could kill -9 here automatically
    puts "\nATTENTION! Normal killing timed out (#{config[:kill_timeout]} seconds).  Please kill #{worker_id} manually\n"
    if force
      puts "\nForcing killing of the worker process..."
      system("kill -9 `cat #{config[:pid_file]}`")
      system("rm #{config[:pid_file]}")
      puts "Done.\n"
    end
  else
    puts "Killed."
  end
  
end


class DummyWorker
  # This class implements the minimal interface for a worker class
  
  def initialize(id, config)
    @config = config
    @id = id
  end
  
  def start
    RAILS_DEFAULT_LOGGER.info("Duh.. I'm the DummyWorker, here's my config")
    @config.each {|k,v| RAILS_DEFAULT_LOGGER.info("#{k} => #{v}")}
    while true
      sleep 10
      RAILS_DEFAULT_LOGGER.info("Hello, I'm #{@id}")
    end


  end
end

if $0 == __FILE__
  main
end