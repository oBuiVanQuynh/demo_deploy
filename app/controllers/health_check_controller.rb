class HealthcheckController < ActionController::Base
  def show
    render body: nil, status: 200
  end
end
