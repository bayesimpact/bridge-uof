require 'rails_helper'

describe '[DB Capacity]', type: :request do
  it 'check the amount of DynamoDB read/write capacity used in performing basic tasks' do
    Dynamoid.adapter.monitor("Log in") do
      login
    end

    Dynamoid.adapter.monitor("Create an incident w/ 1 civilian and 1 officer") do
      create_complete_incident
    end

    Dynamoid.adapter.monitor("Review an incident") do
      visit_status :in_review
      click_link "View"
    end

    Dynamoid.adapter.monitor("Create an incident w/ 3 civilians and 3 officers") do
      create_complete_incident 3, 3
    end
  end
end

module Dynamoid
  class Adapter
    attr_reader :read_capacity_used, :write_capacity_used

    # Given a block monitor the read and write capacity taken
    # to execute the task.
    def monitor(description)
      puts ""
      puts "(#{description})"

      @read_capacity_used = Hash.new { |h, k| h[k] = 0 }
      @write_capacity_used = Hash.new { |h, k| h[k] = 0 }

      yield

      puts "  Read capacity used: #{Dynamoid.adapter.read_capacity_used.values.reduce(:+)}"
      Dynamoid.adapter.read_capacity_used.each do |table, capacity|
        puts "    #{table}: #{capacity}"
      end

      puts "  Write capacity used: #{Dynamoid.adapter.write_capacity_used.values.reduce(:+)}"
      Dynamoid.adapter.write_capacity_used.each do |table, capacity|
        puts "    #{table}: #{capacity}"
      end
    end

    # DynamoDB's built-in `Adapter#benchmark` method simply times operations.
    # Instead, let's benchmark read/write capacity usage.
    def benchmark(method, *args)
      result = yield

      if args
        case method
        when 'get_item'
          @read_capacity_used[args[0][0]] += 1
        when 'put_item'
          @write_capacity_used[args[0][0]] += 1
        when 'batch_get_item'
          args[0].each do |table, ids|
            @read_capacity_used[table] += ids.length if ids
          end
        when 'Scan'
          result.each do
            @read_capacity_used[args[0]] += 1
          end
          result.rewind
        end
      end

      result
    end
  end
end
