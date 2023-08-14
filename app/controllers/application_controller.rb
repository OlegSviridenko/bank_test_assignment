class ApplicationController < ActionController::Base
  skip_forgery_protection

  rescue_from ActionController::ParameterMissing do
    render_bad_request
  end

  def render_bad_request(error_message: 'Bad Request')
    render json: { message: error_message }, status: :unprocessable_entity
  end
end
