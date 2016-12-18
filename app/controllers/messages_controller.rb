class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def create
    action = MessageCreator.new(params)
    p '!!!!!!!!!!!'
    p action.message
    p '!!!!!!!!!!'
    if action.ok?
      flash[:message] = "Message sent"
      redirect_to new_message_path
    else
      @message = action.message
      p "NO message sorrry"
      render :new
    end
  end
end
