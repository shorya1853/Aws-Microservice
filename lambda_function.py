from pay.card import CreditCard
from pay.order import LineItem, Order
from pay.payment import pay_order
from pay.processor import PaymentProcessor


def read_card_info(card, month, year) -> CreditCard:
    # "1249190007575069"
    card = card
    month = month
    year = year
    return CreditCard(card, month, year)


def lambda_handler(event, context):
    payment_processor = PaymentProcessor("6cfb67f3-6281-4031-b893-ea85db0dce20")
    # Test card number: 1249190007575069
    order = Order()
    # LineItem(name="Shoes", price=100_00, quantity=2)
    print(event["body"])
    item = event["body"]["items"]
    for items in item:
        name = items["name"]
        price = items["price"]
        quantity = items["quantity"]
        order.line_items.append(LineItem(name=name, price=price, quantity=quantity))
    
    # Read card info from user
    card_req = event["body"]["card"]
    card_no = card_req["card-no"]
    month = card_req["month"]
    exp_year = card_req["expiry-year"]
    card = read_card_info(card_no, month, exp_year)
    try:
        result = pay_order(order, payment_processor, card)
    
        return {
        "message": result, 
        "status": 200
        }
    except Exception as e:
        return {
            "message": f"error{e}",
            "status": 500
        }
