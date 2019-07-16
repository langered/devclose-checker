require "./config"
require "http/client"
require "json"

struct Information

  property dev_close, repo_url, status_code, config_file_path

  def initialize(dev_close : String, repo_url : String, status_code : Int32, config_file_path : String)
    @dev_close = dev_close
    @repo_url = repo_url
    @status_code = status_code
    @config_file_path = config_file_path
  end

  def to_json(json : JSON::Builder)
    json.object do
      json.field "dev_close", self.dev_close
      json.field "repo_url", self.repo_url
      json.field "status_code", self.status_code
      json.field "config_file_path", self.config_file_path
    end
  end
end

class DevcloseChecker
  @config : Config

  def initialize(config_file_path : String)
    @config = Config.new(config_file_path)
  end

  def info : String
    begin
      response = HTTP::Client.get @config.repo_api
    rescue
      return Information.new("unavailable", @config.repo_api, 503, @config.file_path).to_json
    end

    if response.status_code != 200
      return Information.new("unavailable", @config.repo_api, response.status_code, @config.file_path).to_json
    end

    parse_github_response(response)
  end

  def devclose
    response_json = JSON.parse(info)
    response_json["dev_close"]
  end

  def bitbar
    repo_info_json = JSON.parse(info)
    emoji = @config.emojis["unknown"]

    case repo_info_json["dev_close"]
    when "open"
      emoji = @config.emojis["open"]
    when "closed"
      emoji = @config.emojis["closed"]
    when "unknown"
      emoji = @config.emojis["unknown"]
    when "unavailable"
      emoji = @config.emojis["unavailable"]
    end

    build_bitbar_output(emoji, repo_info_json["repo_url"].to_s)
  end

  private def build_bitbar_output(emoji : String, repo_url : String) : String
    <<-STRING
    #{emoji}
    ---
    Repository|href=#{repo_url}
    Edit config …|bash=\"vi #{@config.file_path}\"
    STRING
  end

  private def parse_github_response(response : HTTP::Client::Response) : String
    body_json = JSON.parse(response.body)

    dev_close = parse_description(body_json)
    repo_url = body_json["html_url"].to_s

    Information.new(dev_close, repo_url, response.status_code, @config.file_path).to_json
  end

  private def parse_description(body_json : JSON::Any) : String
    description = body_json["description"].to_s
    if description.downcase.includes?(@config.open_indicator)
      return "open"
    elsif description.downcase.includes?(@config.closed_indicator)
      return "closed"
    else
      return "unknown"
    end
  end
end
