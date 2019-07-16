require "yaml"

class Config
  @file_path : String
  @repo_api : String
  @open_indicator = "open"
  @closed_indicator = "close"
  @emojis = Hash{
      "open" => ":white_check_mark:",
      "closed" => ":no_entry_sign:",
      "unknown" => ":question:",
      "unavailable" => ":boom:"
  }

  def initialize(config_file_path : String)
    config_file_content = File.read(config_file_path)
    config_content = YAML.parse config_file_content
    @file_path = config_file_path
    @repo_api = config_content["repo_api"].as_s
    @open_indicator = config_content["open_indicator"].as_s if config_content.["open_indicator"]?
    @closed_indicator = config_content["closed_indicator"].as_s if config_content.["closed_indicator"]?

    if config_content["emojis"]?
      emoji_config = config_content["emojis"]
      @emojis["open"] = emoji_config["open"].as_s if emoji_config["open"]?
      @emojis["closed"] = emoji_config["closed"].as_s if emoji_config["closed"]?
      @emojis["unknown"] = emoji_config["unknown"].as_s if emoji_config["unknown"]?
      @emojis["unavailable"] = emoji_config["unavailable"].as_s if emoji_config["unavailable"]?
    end
  end

  def file_path
    @file_path
  end

  def repo_api
    @repo_api
  end

  def open_indicator
    @open_indicator
  end

  def closed_indicator
    @closed_indicator
  end

  def emojis
    @emojis
  end
end
