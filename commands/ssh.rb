require 'yaml'
require 'net/ssh'

class SSH

  attr_accessor :config, :argv, :options, :opt_parse

  def initialize(argv)
    @config = YAML.load(File.open("#{File.dirname(__FILE__)}/../conf/ssh_config.yml"))['config']
    @argv = argv
    @options = set_default_options(@config, @argv)

    @opt_parser = get_parser(@options)
    parse_options!(@opt_parser) # Override config file options if any options are passed

    puts "SSH options being used: \n\t #{@options.inspect}"

    ssh_connect(@options) # The Magic

  rescue StandardError => e
    puts "Whoops... Somehing went wrong:  \n\t #{e.message} \n\n"
    puts @opt_parser
  end

  def get_parser(options)
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


      opt.on("-i","--ip IP_ADDRESS","which IP address do you want to communicate with") do |ip|
        options[:ip] = ip
      end

      opt.on("-c","--cert Certificate","Certificate pem file") do |cert|
        options[:cert] = cert
      end

      opt.on("-k", "--key Key", "Key pem file") do |key|
        options[:key] = key
      end

      opt.on("-u", "--user User", "Username") do |user|
        options[:user] = user
      end

      opt.on("-h","--help","help") do
        puts opt_parser
      end
    end

    opt_parser
  end

  def parse_options!(opt_parser)
    opt_parser.parse!
  end

  private 

  def set_default_options(config, argv)
    options = {}
    begin

      options[:cert_dir] = config["cert_dir"] if config["cert_dir"]
      # Make sure there is a trailing "/" and make sure we don't set it to root: ("/")
      options[:cert_dir] << "/" if !options[:cert_dir].empty? && options[:cert_dir].split("").last != "/" 

      servers = config["servers"]
      raise "No servers are defined in the ssh_config.yml file." unless servers.any?
      raise "No server alias was passed... Skipping..." unless  argv[0]

      server_alias = argv[0]
      target_server = servers[server_alias]

      options[:ip] = target_server["ip"]
      options[:cert] = target_server["cert"]
      options[:key] = target_server["cert_key"]

    rescue StandardError => e
      puts "#{e.message}"
      options
    end

    options
  end

  def ssh_connect(options)
    raise "No Server found in arguments or config file." unless options[:ip]
    puts "Connecting to #{options[:ip]}....\n\n"
    Net::SSH.start(options[:ip], options[:user], { key_data: "#{options[:cert_dir]}#{options[:key]}", keys_only: true, timeout: 10 } ) do |ssh|
      ssh.open_channel do |channel|
        channel.request_pty do |ch, success|
          if success
            puts "========================= CONNECTED TO #{options[:ip]} ==================================="
          else
            puts "=========================  CONNECTION TO #{options[:ip]} FAILED  ===================================="
            return
          end
        end
      end
      ssh.loop
    end
  end

end