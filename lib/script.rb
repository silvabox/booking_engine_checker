require 'capybara'
require 'selenium-webdriver'
require 'dotenv'

Dotenv.load

include Capybara::DSL

Capybara.default_driver = :selenium

visit 'http://intelligent-tickets.co.uk/index.php?th=tw&pg=login'

fill_in 'user', with: ENV['USER']
fill_in 'pass', with: ENV['PASSWORD']
click_button 'LOG IN'
