require 'yaml'
require 'net/ssh'

class SSH

  attr_accessor :config, :argv, :options

  def initialize(argv)
    @config = YAML.load(File.open("#{File.expand_path('.')}/conf/ssh_config.yml"))['config']
    @argv = argv
    @options = {}
    parse_options!
    puts "OPTIONS:: #{@options.inspect}"
    puts "ARGV:: #{@argv.inspect}"
  end

  def parse_options!

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
        @options[:environment] = environment
      end

      opt.on("-i","--ip IP_ADDRESS","which IP address do you want to communicate with") do |ip|
        @options[:ip] = ip
      end

      opt.on("-c","--cert Certificate","Certificate pem file") do |cert|
        @options[:cert] = cert
      end

      opt.on("-k", "--key Key", "Key pem file") do |key|
        @options[:key] = key
      end

      opt.on("-h","--help","help") do
        puts opt_parser
      end
    end

    opt_parser.parse!

  end

end