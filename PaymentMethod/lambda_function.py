from pay.card import CreditCard
from pay.order import LineItem, Order
from pay.payment import pay_order
from pay.processor import PaymentProcessor


def read_card_info() -> CreditCard:
    card = "1249190007575069"
    month = 12
    year = 2024
    return CreditCard(card, month, year)


def lambda_handler(event, context):
    payment_processor = PaymentProcessor("6cfb67f3-6281-4031-b893-ea85db0dce20")
    # Test card number: 1249190007575069
    order = Order()
    # LineItem(name="Shoes", price=100_00, quantity=2)
    print(event["body"])
    order.line_items.append(LineItem(name="Shoes", price=100_00, quantity=2))
    name = event["body"]["name"]
    # Read card info from user
    card = read_card_info()
    try:
        pay_order(order, payment_processor, card)
    
        return {
        "message": f"Charging card number {name}", 
        "status": 200
        }
    except Exception as e:
        return {
            "message": f"error{e}",
            "status": 500
        }
