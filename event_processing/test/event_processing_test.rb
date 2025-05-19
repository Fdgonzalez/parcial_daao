require 'minitest/autorun'
require_relative '../event_processing'

class MockPaymentProcessor
  attr_reader :refund_called
  
  def initialize
    @refund_called = false
  end

  def refund(_ammount, _account)
    @refund_called = true
  end
end

class MockStockManager
  attr_reader :checked_stock, :reserved_stock, :freed_stock
  
  def initialize
    @checked_stock = false
    @reserved_stock = false
    @freed_stock = false
  end

  def stock_available?(products)
    @checked_stock = true
    true
  end

  def reserve_stock(products)
    @reserved_stock = true
    "FakeReservationId"
  end

  def free_stock(reservation_id)
    @freed_stock = true
  end
end

class ReportingSystemTest < Minitest::Test
  def test_new_order_event
    @payment_processor = MockPaymentProcessor.new
    @stock_manager = MockStockManager.new
    @ecommerce = ECommerceSystem.new(@payment_processor, @stock_manager)
    event = NewOrderEvent.new("1234", [Product.new("Aspiradora", 100)], "Calle Falsa 123", "Visa")
    @ecommerce.handle_event(event)
    assert_equal true, @stock_manager.checked_stock
    assert_equal true, @stock_manager.reserved_stock
    assert_equal false, @stock_manager.freed_stock
    assert_equal false, @payment_processor.refund_called
  end

  def test_payment_received_event
    @payment_processor = MockPaymentProcessor.new
    @stock_manager = MockStockManager.new
    @ecommerce = ECommerceSystem.new(@payment_processor, @stock_manager)
    event = PaymentReceivedEvent.new("1234", "100", "VISA", "2025-1-1", "transaction_id")
    @ecommerce.handle_event(event)
    assert_equal false, @stock_manager.checked_stock
    assert_equal false, @stock_manager.reserved_stock
    assert_equal false, @stock_manager.freed_stock
    assert_equal false, @payment_processor.refund_called
  end

  def test_order_canceled_event
    @payment_processor = MockPaymentProcessor.new
    @stock_manager = MockStockManager.new
    @ecommerce = ECommerceSystem.new(@payment_processor, @stock_manager)
    event = OrderCanaceledEvent.new("1234", "No me gusto", "Juan")
    @ecommerce.handle_event(event)
    assert_equal false, @stock_manager.checked_stock
    assert_equal false, @stock_manager.reserved_stock
    assert_equal true, @stock_manager.freed_stock
    assert_equal true, @payment_processor.refund_called
  end
end
