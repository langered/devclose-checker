require "spec"
require "../src/config"

describe "Config" do
  tempfile = uninitialized File

  Spec.after_each do
    tempfile.delete
  end

  context "load config" do
    Spec.before_each do
      config_file_content = "
      repo_api: https://www.github.com/api
      open_indicator: opened
      closed_indicator: closed
      emojis:
        open: \":open:\"
        closed: \":close:\"
        unknown: \":unknown:\"
        unavailable: \":unavailable:\"
      "

      tempfile = File.tempfile("devclose", ".config") do |file|
        file.print(config_file_content)
      end
    end

    it "creates a new Config object from config content" do
      config = Config.new(tempfile.path)

      config.file_path.should eq(tempfile.path)
      config.repo_api.should eq("https://www.github.com/api")
      config.open_indicator.should eq("opened")
      config.closed_indicator.should eq("closed")

      config.emojis["open"].should eq(":open:")
      config.emojis["closed"].should eq(":close:")
      config.emojis["unknown"].should eq(":unknown:")
      config.emojis["unavailable"].should eq(":unavailable:")
    end
  end

  context "has missing values" do
    Spec.before_each do
      config_file_content = "
      repo_api: https://www.github.com/api
      "

      tempfile = File.tempfile("devclose", ".config") do |file|
        file.print(config_file_content)
      end
    end


    it "takes default values for optional parameters" do
      config = Config.new(tempfile.path)

      config.file_path.should eq(tempfile.path)
      config.open_indicator.should eq("open")
      config.closed_indicator.should eq("close")

      config.emojis["open"].should eq(":white_check_mark:")
      config.emojis["closed"].should eq(":no_entry_sign:")
      config.emojis["unknown"].should eq(":question:")
      config.emojis["unavailable"].should eq(":boom:")
    end
  end
end
