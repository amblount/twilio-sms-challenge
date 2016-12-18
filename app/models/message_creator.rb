class MessageCreator
  require 'twilio-ruby'
  attr_accessor :message, :sms_record

  def initialize(params)
    @message = Message.new(allowed_params(params))
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def ok?
    save_message && send_notification && send_message(@message)
  end

  def send_message(message)
    # @client.account.messages.create(
    #   from: message.sender_email,
    #   to: message.recipient_email,
    #   body: message.body
    # )
  end

  private

  def send_notification
    #sends an email notification to recipient as an alert of a new message
    MessageMailer.secure_message(@message).deliver_now
  end

  def save_message
    @message.secure_id = SecureRandom.urlsafe_base64(25)
    @message.save
    p 'HERE'
  end

  def allowed_params(params)
    { sender_phone:params[:message][:sender], sender_email: params[:message][:sender], recipient_phone: params[:message][:recipient], recipient_email: params[:message][:recipient], body: params[:message][:body]}
  end
end
