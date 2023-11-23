import os

from dotenv import load_dotenv

from pay.card import CreditCard
from pay.order import LineItem, Order
from pay.payment import pay_order
from pay.processor import PaymentProcessor


def read_card_info() -> CreditCard:
    card = "1249190007575069"
    month = 12
    year = 2024
    return CreditCard(card, month, year)


def lambda_function(event, context):
    load_dotenv()
    api_key = os.getenv("API_KEY") or ""
    payment_processor = PaymentProcessor(api_key)
    # Test card number: 1249190007575069
    order = Order()
    # LineItem(name="Shoes", price=100_00, quantity=2)
    print(event["body"])
    order.line_items.append(LineItem(name="Shoes", price=100_00, quantity=2))

    # Read card info from user
    card = read_card_info()
    pay_order(order, payment_processor, card)
    print(order.status.value)
    
