# Controller for feedback form.
class FeedbackController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(get_formatted_params(params, Feedback))
    if @feedback.save
      @current_user.feedbacks << @feedback
      BridgeMailer.feedback_email(@feedback, @current_user).deliver_now
      redirect_to :thank_you
    else
      render :new
    end
  end

  def thank_you
  end
end
