require 'capybara/dsl'
require 'capybara-webkit'

module GreenOnion
  class Webkit
    include Capybara::DSL

    def initialize
      Capybara.default_driver = :webkit
    end

    def record(url, path, dimensions)
      visit url
      page.driver.save_screenshot(path, dimensions)
    end

  end
end
