# Load all of our lib code.
Dir[File.join(Rails.root, "lib", "*.rb")].each { |l| require l }
Dir[File.join(Rails.root, "lib", "core_extensions", "*.rb")].each { |l| require l }
