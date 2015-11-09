require "spec_helper"

describe GreenOnion do

  before(:all) do
    @tmp_path = './spec/tmp'
    @url = 'http://localhost:8070'
    @url_w_uri = @url + '/fake_uri'
  end

  describe "Skins" do
    before(:each) do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
      end
    end

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end

    it "should default to 1024x768 browser dimensions" do
      ( (GreenOnion.configuration.dimensions[:height] == 768) &&
        (GreenOnion.configuration.dimensions[:width] == 1024) ).should be true
    end

    it "should set/get custom directory" do
      GreenOnion.configuration.skins_dir.should eq(@tmp_path)
    end

    it "should get the correct paths_hash" do
      2.times do
        GreenOnion.skin(@url)
      end
      ( (GreenOnion.screenshot.paths_hash[:original] == "#{@tmp_path}/root.png") && 
        (GreenOnion.screenshot.paths_hash[:fresh] == "#{@tmp_path}/root_fresh.png") ).should be true
    end

    it "should measure the percentage of diff between skins" do
      2.times do
        GreenOnion.skin_percentage(@url)
      end
      GreenOnion.compare.percentage_changed.should be > 0
    end

    it "should measure the percentage of diff between skins (even if there is no diff)" do
      2.times do
        GreenOnion.skin_percentage(@url_w_uri)
      end
      GreenOnion.compare.percentage_changed.should be == 0
    end

    it "should print just URL and changed/total when diff percentage threshold has not been surpassed" do
      $stdout.should_receive(:puts).exactly(3).times
      2.times do
        GreenOnion.skin_percentage(@url, 6)
      end
    end

    it "should create visual diff between skins" do
      2.times do
        GreenOnion.skin_visual(@url)
      end
      GreenOnion.compare.diffed_image.should eq("#{@tmp_path}/root_diff.png")
    end

    it "should create visual diff between skins (even when there is no change)" do
      2.times do
        GreenOnion.skin_visual(@url_w_uri)
      end
      GreenOnion.compare.diffed_image.should eq("#{@tmp_path}/fake_uri_diff.png")
    end

    it "should measure the percentage of diff between skins AND create visual diff" do
      2.times do
        GreenOnion.skin_visual_and_percentage(@url)
      end
      ( (GreenOnion.compare.diffed_image.should eq("#{@tmp_path}/root_diff.png")) &&
        (GreenOnion.compare.percentage_changed.should be > 0) ).should be true
    end
  end

  describe "Skins with custom dimensions" do
    before(:each) do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
        c.dimensions = { :width => 1440, :height => 900 }
      end
    end

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end

    it "should allow custom browser dimensions" do
      ( (GreenOnion.configuration.dimensions[:height] == 900) &&
        (GreenOnion.configuration.dimensions[:width] == 1440) ).should be true
    end
  end

  describe "Skins with custom threshold" do
    before(:each) do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
        c.threshold = 1
      end
    end

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end

    it "should alert when diff percentage threshold is surpassed" do
      GreenOnion.should_receive(:abort)
      2.times do
        GreenOnion.skin_percentage(@url)
      end
    end
  end

  describe "Skins with custom file namespace" do

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end

    it "should allow custom file namespacing" do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
        c.skin_name = {
          :match => /[\/a-z]/,
          :replace => "-",
          :prefix => "start",
          :root => "first"
        }
      end
      ( (GreenOnion.configuration.skin_name[:match] == /[\/a-z]/) &&
        (GreenOnion.configuration.skin_name[:replace] == "-")     &&
        (GreenOnion.configuration.skin_name[:prefix] == "start")  &&
        (GreenOnion.configuration.skin_name[:root] == "first")  ).should be true
    end

    it "should allow incomplete setting of skin_name hash" do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
        c.skin_name = {
          :replace => "o"
        }
      end
      ( (GreenOnion.configuration.skin_name[:match] == /[\/]/) &&
        (GreenOnion.configuration.skin_name[:replace] == "o")     &&
        (GreenOnion.configuration.skin_name[:prefix] == nil)  &&
        (GreenOnion.configuration.skin_name[:root] == "root")  ).should be true
    end
  end

  describe "Errors" do
    before(:each) do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
      end
    end

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end

    it "should raise error for when ill-formatted URL is used" do
      expect { GreenOnion.skin_percentage("localhost") }.to raise_error(GreenOnion::Errors::IllformattedURL)
    end

    it "should raise error for when threshold is out of range for skin_percentage" do
      expect { GreenOnion.skin_percentage(@url, 101) }.to raise_error(GreenOnion::Errors::ThresholdOutOfRange)
    end

    it "should raise error for when threshold is out of range for skin_visual_and_percentage" do
      expect { GreenOnion.skin_visual_and_percentage(@url, 101) }.to raise_error(GreenOnion::Errors::ThresholdOutOfRange)
    end

    it "should raise error for when unknown driver is assigned" do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
        c.driver = :foo
      end
      expect { GreenOnion.skin_percentage(@url) }.to raise_error(ArgumentError)
    end
  end


  describe "Skins with custom driver" do
    before(:each) do
      GreenOnion.configure do |c|
        c.skins_dir = @tmp_path
        c.driver = "selenium"
      end
    end

    after(:each) do
      FileUtils.rm_r(@tmp_path, :force => true)
    end

    it "should allow custom browser driver" do
      GreenOnion.configuration.browser.driver.should eq("selenium")
    end
  end
end
