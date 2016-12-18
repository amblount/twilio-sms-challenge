class MessageCreator
  extend ActiveModel::Naming
  require 'twilio-ruby'
  attr_accessor :message, :sms_record
  attr_reader   :errors

  def initialize(params)
    @message = Message.new(allowed_params(params))
    @errors = ActiveModel::Errors.new(self)
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def ok?
    update_sender && update_recipient && save_message && send_notification && send_message(@message)
  end

  #Start process to figure out what type of input phone | email
  #currently both input types are set on create
  #ex: 12345678 => recipient_email: "12345678", recipient_phone: "12345678"

  def update_sender
    if @message.sender_email.include? "@"
      @message.sender_phone = nil
      @message.save
    else
      @message.sender_email = nil
      @message.sender_phone = phone(@message.sender_phone)
      @message.save
    end
  end

  def update_recipient
    p "im in recipient email"
    if @message.recipient_email.include? "@"
      @message.recipient_phone = nil
      @message.save
    else
      @message.recipient_email = nil
      @message.recipient_phone = phone(@message.recipient_phone)
      @messave.save
      p @message
    end
  end

  def numeric?(string)
    string =~ /[[\d]]/
  end

  def phone(num)
    #+15104651992
    #12 chars long
    #first char "+"
    #all other chars numbers
    first_char = num[0]
    sequence = num.reverse.chop.reverse
    if first_char = "+" && num.length == 12 && numeric?(sequence) == 0
      return num
    end

    # sequence is a string without the first character of num
    # initially want to make sure that all the chars are digits
    if numeric?(sequence) == 0
      # logic here to make sure that the number is actually a valid number
      case num.length != 12
      # make sure the length of this return statement is 12
      #the input is missing some character is not 12 chars long
        when num.length == 11
        # add +
          return num = "+" + num
        when num.length == 10
          return num = "+1" + num
        when num.length == 7
          errors.add(:message, :blank, message: "must include an area code and be 12 characters long, ex: +12139873647")
        else
          errors.add(:message, :blank, message: "phone number too short must be 12 characters long including: +, country-code, area code, ex: +12139873647")
      end
    end
  end

  def send_message(message)
    # @client.account.messages.create(
    #   from: message.sender_email,
    #   to: message.recipient_email,
    #   body: message.body
    # )
  end

  # active model error methods required http://api.rubyonrails.org/classes/ActiveModel/Errors.html
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  private

  def send_notification
    #sends an email notification to recipient as an alert of a new message
    MessageMailer.secure_message(@message).deliver_now
  end

  def save_message
    @message.secure_id = SecureRandom.urlsafe_base64(25)
    @message.save
  end

  def allowed_params(params)
    { sender_phone:params[:message][:sender], sender_email: params[:message][:sender], recipient_phone: params[:message][:recipient], recipient_email: params[:message][:recipient], body: params[:message][:body]}
  end
end
