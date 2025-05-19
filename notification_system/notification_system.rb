

class Notification
  attr_reader :message, :receiver, :origin

  def initialize(message, receiver, origin)
    @message = message
    @receiver = receiver
    @origin = origin
  end
end

# Pseudo-interface
class Notifier
  def send(notification)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class ConsoleNotifier < Notifier
  def send(notification)
    puts notification.message
  end
end

class NotifierDecorator
  def initialize(wrappee)
    @wrappee = wrappee
  end

  def send(notification)
    @wrappee.send(notification)
  end
end

class LoggingDecorator < NotifierDecorator
  attr_reader :logs

  def initialize(wrappee)
    super
    @logs = []
  end

  def send(notification)
    logs.push("#{notification.origin} sent notification: \"#{notification.message}\" to #{notification.receiver}")
    @wrappee.send(notification)
  end
end

class EncryptionDecorator < NotifierDecorator
  def send(notification)
    encrypted_message = notification.message.tr("A-Za-z", "N-ZA-Mn-za-m") # ROT-13
    encrypted_notification = Notification.new(encrypted_message, notification.receiver, notification.origin)
    @wrappee.send(encrypted_notification)
  end
end

class MarkdownDecorator < NotifierDecorator
  def send(notification)
    formatted_message = "*#{notification.message}*" # Make the notification *bold*
    formatted_notification = Notification.new(formatted_message, notification.receiver, notification.origin)
    @wrappee.send(formatted_notification)
  end
end
