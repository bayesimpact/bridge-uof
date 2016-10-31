require 'rails_helper'

describe '[DB Capacity]', type: :request do
  it 'check the amount of DynamoDB read/write capacity used in performing basic tasks' do
    puts "(Note: For simplicity, we assume that all transactions are under 4 KB in size.)"

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
    attr_reader :read_operations, :write_operations

    # Given a block monitor the read and write capacity taken
    # to execute the task.
    def monitor(description)
      puts ""
      puts "(#{description})"

      @read_operations = Hash.new { |h, k| h[k] = 0 }
      @write_operations = Hash.new { |h, k| h[k] = 0 }

      @monitoring = true
      yield
      @monitoring = false

      puts "  Read operations: #{Dynamoid.adapter.read_operations.values.reduce(:+)}"
      Dynamoid.adapter.read_operations.each do |table, capacity|
        puts "    #{table}: #{capacity}"
      end

      puts "  Write operationsused: #{Dynamoid.adapter.write_operations.values.reduce(:+)}"
      Dynamoid.adapter.write_operations.each do |table, capacity|
        puts "    #{table}: #{capacity}"
      end
    end

    # DynamoDB's built-in `Adapter#benchmark` method simply times operations.
    # Instead, let's benchmark read/write capacity usage.
    def benchmark(method, *args)
      result = yield

      if @monitoring && args
        case method
        when 'get_item'
          @read_operations[args[0][0]] += 1
        when 'put_item'
          @write_operations[args[0][0]] += 1
        when 'batch_get_item'
          args[0].each do |table, ids|
            @read_operations[table] += ids.length if ids
          end
        when 'Scan'
          result.each do
            @read_operations[args[0]] += 1
          end
          result.rewind
        end
      end

      result
    end
  end
end
