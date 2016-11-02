namespace :maintenance do
  desc "Start maintenance mode"
  task start: :environment do
    GlobalState.start_maintenance_mode!
  end

  desc "Stop maintenance mode"
  task start: :environment do
    GlobalState.start_maintenance_mode!
  end
end
