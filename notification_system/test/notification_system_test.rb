require 'minitest/autorun'
require_relative '../notification_system'

$current_notification = nil
class TestNotifier < Notifier
  def send(notification)
    $current_notification = notification
  end
end

class NotificationSystemTest < Minitest::Test
  def setup
    @notification = Notification.new("Hello, this is a test", "Juan", "Test")
    @notifier = TestNotifier.new
  end

  def test_simple_notification
    @notifier.send(@notification)
    assert_equal "Hello, this is a test", $current_notification.message
    assert_equal "Juan", $current_notification.receiver
    assert_equal "Test", $current_notification.origin
  end

  def test_encryption_decorator
    notifier = EncryptionDecorator.new(@notifier)
    notifier.send(@notification)
    decrypted_message = $current_notification.message.tr("A-Za-z", "N-ZA-Mn-za-m")
    assert_equal "Hello, this is a test", decrypted_message
    assert_equal "Juan", $current_notification.receiver
    assert_equal "Test", $current_notification.origin
  end

  def test_markdown_decorator
    notifier = MarkdownDecorator.new(@notifier)
    notifier.send(@notification)
    assert_equal "*Hello, this is a test*", $current_notification.message
    assert_equal "Juan", $current_notification.receiver
    assert_equal "Test", $current_notification.origin
  end

  def test_logging_decorator
    notifier = LoggingDecorator.new(@notifier)
    notifier.send(@notification)
    assert_equal "Hello, this is a test", $current_notification.message
    assert_equal "Juan", $current_notification.receiver
    assert_equal "Test", $current_notification.origin
    assert_equal "Test sent notification: \"Hello, this is a test\" to Juan", notifier.logs[0]
  end

  def test_combined
    logger = LoggingDecorator.new(@notifier)  # Need to keep a reference to this one to check the logs
    notifier = EncryptionDecorator.new(MarkdownDecorator.new(logger))
    notifier.send(@notification)
    decrypted_message = $current_notification.message.tr("A-Za-z", "N-ZA-Mn-za-m")
    assert_equal "*Hello, this is a test*", decrypted_message
    assert_equal "Juan", $current_notification.receiver
    assert_equal "Test", $current_notification.origin
    # The logger has the encrypted message because it ran second to last
    assert_equal "Test sent notification: \"*Uryyb, guvf vf n grfg*\" to Juan", logger.logs[0]
  end
end