require "./src/devclose_checker"
require "admiral"

class Devclose < Admiral::Command
  define_help description: "CLI for checking dev close"
  define_version "1.0.0",
              short: v
  define_flag json : Bool,
              description: "Return full dev close information as json",
              default: false,
              short: j
  define_flag bitbar : Bool,
              description: "Return dev close information in bitbar format",
              default: false,
              short: b
  define_flag config : Bool,
              description: "Show the current config properties",
              default: false,
              short: c

  def run
    config_file_path = File.dirname(Process.executable_path.not_nil!) + "/config/devclose_config.yml"
    dc_checker = DevcloseChecker.new(config_file_path)

    if flags.json
      puts dc_checker.info
    elsif flags.bitbar
      puts dc_checker.bitbar
    elsif flags.config
      puts "Config file path: #{config_file_path}"
      puts "---Config---"
      puts File.read(config_file_path)
    else
      puts dc_checker.devclose
    end
  end
end

Devclose.run
