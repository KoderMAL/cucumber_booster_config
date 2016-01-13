require "spec_helper"

describe CucumberBoosterConfig::Injection do

  context "blank cucumber.yml in root" do

    before do
      FileUtils.touch("cucumber.yml")
      CucumberBoosterConfig::Injection.new(".").run
    end

    it "inserts semaphoreci profile" do
      lines = File.open("cucumber.yml", "r") { |f| f.readlines }

      expect(lines[0].chomp).to eql(CucumberBoosterConfig::CucumberFile::SEMAPHORE_PROFILE)
    end

    it "inserts a default profile definition" do
      lines = File.open("cucumber.yml", "r") { |f| f.readlines }

      expect(lines[1].chomp).to eql(CucumberBoosterConfig::CucumberFile::DEFAULT_PROFILE)
    end

    after do
      FileUtils.rm("cucumber.yml")
    end
  end

  context "config/cucumber.yml found" do

    context "with a default profile" do

      before do
        FileUtils.mkdir_p("config")
        File.open("config/cucumber.yml", "w") do |f|
          f.puts "default: <%= common %>"
        end
      end

      it "inserts semaphoreci profile and appends it to default profile" do
        CucumberBoosterConfig::Injection.new(".").run

        lines = []
        File.open("config/cucumber.yml", "r") { |f| lines = f.readlines }

        expect(lines.size).to eql(2)
        expect(lines[0].chomp).to eql("default: <%= common %> --profile semaphoreci")
        expect(lines[1].chomp).to eql(CucumberBoosterConfig::CucumberFile::SEMAPHORE_PROFILE)
      end
    end

    context "default profile is missing" do

      before do
        FileUtils.mkdir_p("config")
        File.open("config/cucumber.yml", "w") do |f|
          f.puts "todd: --format progress --tags @wip CUC=on"
        end
      end

      it "inserts a new line that defines the default profile" do
        CucumberBoosterConfig::Injection.new(".").run

        lines = []
        File.open("config/cucumber.yml", "r") { |f| lines = f.readlines }

        expect(lines.size).to eql(3)
        expect(lines[0].chomp).to eql("todd: --format progress --tags @wip CUC=on")
        expect(lines[1].chomp).to eql(CucumberBoosterConfig::CucumberFile::SEMAPHORE_PROFILE)
        expect(lines[2].chomp).to eql("default: --format pretty --profile semaphoreci features")
      end
    end

    after do
      FileUtils.rm_rf("config")
    end
  end
end
