require "./src/devclose_checker"

config_file_path = File.dirname(Process.executable_path.not_nil!) + "/config/devclose_config.yml"
dc_checker = DevcloseChecker.new(config_file_path)

bitbar_input = dc_checker.bitbar
puts bitbar_input
