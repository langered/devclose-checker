require "spec"
require "webmock"
require "../src/devclose_checker"

REPO_INFO_ENDPOINT = "https://api.github.com/repos/langered/devclose-checker"
REPO_URL = "https://github.com/langered/devclose-checker"
INVALID_ENDPOINT = "https://github.com/langered/invalid-endpoint"

OPEN_RESPONSE_BODY = "{
  \"id\": 123,
  \"html_url\": \"#{REPO_URL}\",
  \"description\": \"Open for dev\"
}"
CLOSED_RESPONSE_BODY = "{
  \"id\": 124,
  \"html_url\": \"#{REPO_URL}\",
  \"description\": \"Dev Close\"
}"
NO_DESCRIPTION_RESPONSE_BODY = "{
  \"id\": 124,
  \"html_url\": \"#{REPO_URL}\",
  \"description\": null
}"

describe "Dev close" do
  tempfile = uninitialized File
  dc_checker = uninitialized DevcloseChecker

  Spec.before_each do
    tempfile = File.tempfile("devclose", ".config") do |file|
      file.print("repo_api: #{REPO_INFO_ENDPOINT}")
    end
    dc_checker = DevcloseChecker.new(tempfile.path)
  end

  Spec.after_each do
    tempfile.delete
  end

  context "when dev is open" do
    Spec.before_each do
      WebMock.reset
      WebMock.stub(:get, REPO_INFO_ENDPOINT).
      to_return(status: 200, body: OPEN_RESPONSE_BODY)
    end

    it "returns open dev-close as json" do
      expected_info = Information.new("open", REPO_URL, 200, tempfile.path).to_json
      returned_info = dc_checker.info

      information_is_equal(returned_info, expected_info)
    end

    it "returns that dev-close is open" do
      expected_devclose = "open"
      returned_devclose = dc_checker.devclose

      returned_devclose.should eq(expected_devclose)
    end

    context "bitbar plugin" do
      it "shows that dev-close is open" do
        expected_bitbar = <<-STRING
        :white_check_mark:
        ---
        Repository|href=#{REPO_URL}
        Edit config …|bash=\"vi #{tempfile.path}\"
        STRING
        returned_bitbar = dc_checker.bitbar

        returned_bitbar.should eq(expected_bitbar)
      end
    end
  end

  context "when dev is closed" do
    Spec.before_each do
      WebMock.reset
      WebMock.stub(:get, REPO_INFO_ENDPOINT).
      to_return(status: 200, body: CLOSED_RESPONSE_BODY)
    end

    it "returns closed dev-close as json" do
      expected_info = Information.new("closed", REPO_URL, 200, tempfile.path).to_json
      returned_info = dc_checker.info

      information_is_equal(returned_info, expected_info)
    end

    it "returns that dev-close is closed" do
      expected_devclose = "closed"
      returned_devclose = dc_checker.devclose

      returned_devclose.should eq(expected_devclose)
    end

    context "bitbar plugin" do
      it "shows that dev-close is closed" do
        expected_bitbar = <<-STRING
        :no_entry_sign:
        ---
        Repository|href=#{REPO_URL}
        Edit config …|bash=\"vi #{tempfile.path}\"
        STRING
        returned_bitbar = dc_checker.bitbar

        returned_bitbar.should eq(expected_bitbar)
      end
    end
  end

  context "when no description is provided" do
    Spec.before_each do
      WebMock.reset
      WebMock.stub(:get, REPO_INFO_ENDPOINT).
      to_return(status: 200, body: NO_DESCRIPTION_RESPONSE_BODY)
    end
    it "returns unkown dev-close as json" do
      expected_info = Information.new("unknown", REPO_URL, 200, tempfile.path).to_json
      returned_info = dc_checker.info

      information_is_equal(returned_info, expected_info)
    end

    it "returns that dev-close is unknown" do
      expected_devclose = "unknown"
      returned_devclose = dc_checker.devclose

      returned_devclose.should eq(expected_devclose)
    end

    context "bitbar plugin" do
      it "shows that dev-close is unknown" do
        expected_bitbar = <<-STRING
        :question:
        ---
        Repository|href=#{REPO_URL}
        Edit config …|bash=\"vi #{tempfile.path}\"
        STRING
        returned_bitbar = dc_checker.bitbar

        returned_bitbar.should eq(expected_bitbar)
      end
    end
  end

  context "when url times out and throws an error" do
    Spec.before_each do
      #Provocate HTTP::Client error by NOT stubbing any method
      #therfore, calling the client will throw an error
      WebMock.reset
    end

    it "returns that repository is unavailable as json" do
      expected_info = Information.new("unavailable", REPO_INFO_ENDPOINT, 503, tempfile.path).to_json
      returned_info = dc_checker.info

      information_is_equal(returned_info, expected_info)
    end

    it "returns that repository is unavailable" do
      expected_devclose = "unavailable"
      returned_devclose = dc_checker.devclose

      returned_devclose.should eq(expected_devclose)
    end

    context "bitbar plugin" do
      it "shows that repository is unavailable" do
        expected_bitbar = <<-STRING
        :boom:
        ---
        Repository|href=#{REPO_INFO_ENDPOINT}
        Edit config …|bash=\"vi #{tempfile.path}\"
        STRING
        returned_bitbar = dc_checker.bitbar

        returned_bitbar.should eq(expected_bitbar)
      end
    end
  end

  context "when url is not valid" do
    Spec.before_each do
      WebMock.reset
      WebMock.stub(:get, INVALID_ENDPOINT).
      to_return(status: 404, body: "{}")

      tempfile = File.tempfile("devclose", ".config") do |file|
        file.print("repo_api: #{INVALID_ENDPOINT}")
      end
      dc_checker = DevcloseChecker.new(tempfile.path)
    end

    it "returns unkown dev-close as json" do
      expected_info = Information.new("unavailable", INVALID_ENDPOINT, 404, tempfile.path).to_json
      returned_info = dc_checker.info

      information_is_equal(returned_info, expected_info)
    end

    it "returns that dev-close is unavailable" do
      expected_devclose = "unavailable"
      returned_devclose = dc_checker.devclose

      returned_devclose.should eq(expected_devclose)
    end

    context "bitbar plugin" do
      it "shows that dev-close is unavailable" do
        expected_bitbar = <<-STRING
        :boom:
        ---
        Repository|href=#{INVALID_ENDPOINT}
        Edit config …|bash=\"vi #{tempfile.path}\"
        STRING
        returned_bitbar = dc_checker.bitbar

        returned_bitbar.should eq(expected_bitbar)
      end
    end
  end
end

def information_is_equal(returned_info, expected_info)
  returned_info_json = JSON.parse(returned_info)
  expected_info_json = JSON.parse(expected_info)

  returned_info_json["dev_close"].should eq(expected_info_json["dev_close"])
  returned_info_json["repo_url"].should eq(expected_info_json["repo_url"])
  returned_info_json["status_code"].should eq(expected_info_json["status_code"])
  returned_info_json["config_file_path"].should eq(expected_info_json["config_file_path"])
end
