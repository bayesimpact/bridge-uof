# Preview all emails at http://localhost:3000/rails/mailers/ursus_mailer
class BridgeMailerPreview < ActionMailer::Preview
  def feedback_email
    feedback = Feedback.new(source: "Some part of the page (test)",
                            content: "This was confusing (test)")
    BridgeMailer.feedback_email(feedback, User.all.first)
  end
end
