require 'orchestrate'
require 'dotenv'
require 'active_support/core_ext/numeric/time.rb'

Dotenv.load

class Uptime

  def initialize(data)
    @data = data
  end

  def by_day
    Uptime.new(@data.group_by { |event| Date::DAYNAMES[event.time.wday] })
  end

  def by_hour
    Uptime.new(@data.group_by { |event| event.time.hour })
  end

  def percentages
    map { |key, events| percent(events) }
  end

  def counts
    map { |key, events| events.count }
  end

  Entry = Struct.new(:time, :status) do
    def value
      status == 'up' ? 1 : 0
    end
  end

  private

  def map
    @data.dup.tap do |data|
      @data.each do |key, value|
        data[key] = yield key, value
      end
    end
  end

  def percent(events)
    events.map(&:value).reduce(&:+).to_f / events.count * 100
  end

  class << self
    def last_seven_days
      new(map(events.after(7.days.ago)))
    end

    def today
      new(map(events.after(Date.today.beginning_of_day)))
    end

    def now
      map([events.first]).first
    end

    private

    def app
      @app ||= Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY'])
    end

    def uptime
      @uptime ||= app[:uptime]
    end

    def record
      @record ||= uptime[ENV['ORCHESTRATE_CHECKER_ID']]
    end

    def events
      @events ||= record.events[:status_check]
    end

    def map(events)
      events.map { |event| Entry.new(event.time, event.value['status']) }
    end
  end
end
