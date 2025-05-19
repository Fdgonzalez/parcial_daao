class Product
  attr_reader :name, :price
  def initialize(name, price)
    @name = name
    @price = price
  end
end

class NewOrderEvent
  attr_reader :client_id, :products, :shipping_address, :payment_method
  def initialize(client_id, products, shipping_address, payment_method)
    @client_id = client_id
    @products = products
    @shipping_address = shipping_address
    @payment_method = payment_method
  end
end

class PaymentReceivedEvent
  attr_reader :order_id, :ammount, :payment_method, :date, :transaction_id
  def initialize(order_id, ammount, payment_method, date, transaction_id)
    @order_id = order_id
    @ammount = ammount
    @payment_method = payment_method
    @date = date
    @transaction_id = transaction_id
  end
end

class OrderCanaceledEvent
  attr_reader :order_id, :reason, :requester
  def initialize(order_id, reason, requester)
    @order_id = order_id
    @reason = reason
    @requester = requester
  end
end


class EventHandler
  def initialize(payment_processor, stock_manager, successor = nil)
    # Although these references may not be used, always including them allows me to then use metaprogramming to create all the handlers more easily
    @payment_processor = payment_processor
    @stock_manager = stock_manager
    @successor = successor
  end

  def handle(event)
    if can_handle?(event)
      receive(event)
    elsif @successor
      @successor.handle(event)
    else
      raise "No handler found for this event"
    end
  end
end

class NewOrderEventHandler < EventHandler
  def can_handle?(event)
    event.instance_of?(NewOrderEvent)
  end

  def receive(event)
    if not @stock_manager.stock_available?(event.products)
        puts "No stock!" # TODO: Update order status in DB
    end
    @stock_manager.reserve_stock(event.products)
    total = 0
    event.products.each do |product|
      total += product.price
    end
    puts "Stock reserved, total: #{total}" # TODO: Update order status with total in DB
  end
end


class PaymentReceivedEventHandler < EventHandler
  def can_handle?(event)
    event.instance_of?(PaymentReceivedEvent)
  end

  def receive(event)
    # TODO: Get real order from a database to check the tota
    # TODO: Update order status
    # TODO: Generate Invoice
    puts "Emitiendo factura para el pedido #{event.order_id}"
  end
end

class OrderCanaceledEventHandler < EventHandler
  def can_handle?(event)
    event.instance_of?(OrderCanaceledEvent)
  end

  def receive(event)
    # TODO: Get real client account and stock reservation id
    @stock_manager.free_stock("real reservation id")
    @payment_processor.refund(1000, "client account")
  end
end

class ECommerceSystem
  def initialize(payment_processor, stock_manager)
    # Payment processor and stock manager are services that would normally be injected
    event_handler_classes = ObjectSpace.each_object(Class).select { |c| c < EventHandler }
    @event_handler = event_handler_classes.reverse.reduce(nil) { |next_handler, klass| klass.new(payment_processor, stock_manager, next_handler) }
  end

  def handle_event(event)
    @event_handler.handle(event)
  end
end
