require 'capybara/dsl'
require 'capybara-webkit'
require 'capybara/poltergeist'
require 'dotenv'
require 'orchestrate'

Dotenv.load

Capybara.default_driver = :poltergeist
Capybara.default_max_wait_time = 20
Capybara::Webkit.configure do |config|
  config.allow_url('intelligent-tickets.co.uk')
  config.allow_url("www.paypal.com")
end

class Checker
  include Capybara::DSL

  def run
    visit 'http://intelligent-tickets.co.uk/index.php?th=tw&pg=login'

    fill_in 'user', with: ENV['USER']
    fill_in 'pass', with: ENV['PASSWORD']
    check 'cookiecheck'
    click_button 'LOG IN'

    within '#messagediv' do
      click_button 'Close message'
    end

    within '#date_table' do
      find('tr.tabletext').click
    end

    within 'form#book' do
      click_button 'Check availability'

      if page.has_content?('Seats available online')
        puts 'SYSTEM IS UP'
        return :up
      else
        puts 'SYSTEM IS DOWN'
        return :down
      end
    end
  end
end

app = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY'])
uptime = app[:uptime]
record = uptime[ENV['ORCHESTRATE_CHECKER_ID']]

status = Checker.new.run
record.events['status_check'] << { status: status.to_s }
