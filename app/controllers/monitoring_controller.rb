# Controller for monitoring endpoints.
# Note this controller inherits from ActionController::Base,
# NOT ApplicationController, so it doesn't perform use authentication,
# tracking, etc.
class MonitoringController < ActionController::Base
  def ping
    render plain: "pong"
  end
end
