#!/usr/bin/ruby

require 'rubygems'
require 'optparse'

Dir["commands/**/*.rb"].each {|file| require_relative file }

###########################################################
###########################################################
## Class and Method definition ############################
###########################################################


class Deploy
  attr_accessor :options, :git_root, :code_root, :files

  def initialize(options)
    @options = options
    find_git_root
    find_code_root
    find_files
  end


  def deploy
    # top = `git rev-parse --show-toplevel`

    # files = `git ls-files`

    # # files_n_folders = Dir.glob("#{top.strip}/**/*")
    # # gemfile_location_array = files_n_folders.select { |f| f.split('/').last == "Gemfile" }.first.split('/')
    # # gemfile_location_array.pop
    # # code_root = gemfile_location_array.join('/')
    # # files = Dir.glob("#{top.strip}/**/*").select { |f| File.file?(f) }
    # arr = files.split("\n")
    # p top
    # p arr
    # p arr.count
    # p files.count
    p @git_root
    p @code_root
    p @files.count
    p @files.take(3).inspect

  end

  private 

  def find_git_root
    @git_root = `git rev-parse --show-toplevel`
    @git_root.slice!("\n")
  end

  def find_code_root
    files = `git ls-files`.split("\n")
    gemfile_location_array = files.select { |f| f.split('/').last == "Gemfile" }.first.split('/')
    gemfile_location_array.pop
    @code_root = "#{@git_root}/#{gemfile_location_array.join('/')}"
  end

  def find_files
    files_string = `git ls-files`
    files = files_string.split("\n")
    trim = @code_root.gsub(@git_root, "")
    trim.sub!(/^\//,"") # remove the leading / char
    @files = files.map { |f| f.sub(trim,"") }
  end

end # Deploy End


class Jar
  attr_accessor :options, :code_root

  def initialize(options)
    @options = options
    find_code_root
  end

  def create_jar
    
  end

  private 

  def find_git_root
    @git_root = `git rev-parse --show-toplevel`
    @git_root.slice!("\n")
  end

  def find_code_root
    files = `git ls-files`.split("\n")
    gemfile_location_array = files.select { |f| f.split('/').last == "Gemfile" }.first.split('/')
    gemfile_location_array.pop
    @code_root = "#{@git_root}/#{gemfile_location_array.join('/')}"
  end


end



###########################################################
###########################################################
##          Main               ############################
###########################################################


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


