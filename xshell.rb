#!/usr/bin/ruby

require 'rubygems'
require 'optparse'

Dir["#{File.dirname(__FILE__)}/commands/**/*.rb"].each {|file| require_relative file }


options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: mojo COMMAND [OPTIONS]"
  opt.separator ""
  opt.separator "Commands should be run from within a git repository. "
  opt.separator "This utility calls 'git rev-parse --show-toplevel' to find the repo root directory"
  opt.separator ""
  opt.separator "Commands"
  opt.separator "     deploy: deploy local code to server(s) and restart nginx"
  opt.separator "     restart: restart nginx on targeted server(s)"
  opt.separator "     run: runs the passed command on the targeted server(s) eg. run 'ls /opt/Mojo' "
  opt.separator ""
  opt.separator "Options"

  opt.on("-e","--environment ENVIRONMENT","which environment do you want to communicate with (**Config must be set. Run 'mojo config')") do |environment|
    options[:environment] = environment
  end

  opt.on("-i","--ip IP_ADDRESS","which IP address do you want to communicate with") do |ip|
    options[:ip] = ip
  end

  opt.on("-c","--cert Certificate","Certificate pem file") do |cert|
    options[:cert] = cert
  end

  opt.on("-k", "--key Key", "Key pem file") do |key|
    options[:key] = key
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

# opt_parser.parse!

case ARGV[0]
  when "deploy"
    puts "Deploy started with options #{options.inspect}"
    d = Deploy.new(options)
    d.deploy
  when "jar"
    puts "Deploy started with options #{options.inspect}"
    puts "ARGV:: #{ARGV.inspect}"
    # jar = Jar.new(options)
    # jar.create_jar
  when "stop"
    puts "call stop on options #{options.inspect}"
  when "restart"
    puts "call restart on options #{options.inspect}"
  when "copy"
    puts "call copy on options #{options.inspect}"
  when "ssh"
    argv = ARGV
    argv.shift
    ssh = SSH.new(argv)
    puts "DONE"
  else
    puts "
          Usage: mojo COMMAND [OPTIONS]
          \t Commands should be run from within a git repository. 
          \t This utility calls 'git rev-parse --show-toplevel' to find the repo root directory \n
          Commands
          \t deploy: deploy local code to server(s) and restart nginx
          \t\t options:
          \t\t\t
          \t restart: restart nginx on targeted server(s)
          \t\t options:
          \t\t\t
         "

end


