# Preview all emails at http://localhost:3000/rails/mailers/daily_mailer
class DailyMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/daily_mailer/digest
  def digest
    user = User.first
    questions = Question.last_day
    DailyMailer.digest(user, questions)
  end

end
