import { api, LightningElement, track, wire } from "lwc";
import getOrderProducts from "@salesforce/apex/OrderProductsController.getOrderProducts"
import activateOrder from "@salesforce/apex/OrderProductsController.activateOrder"
import { MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import refreshMessageChannel from '@salesforce/messageChannel/RefreshMessageChannel__c';

const DATA_COLUMNS = [
  { label: "Name", fieldName: "name", type: "text" },
  { label: "Quantity", fieldName: "quantity", type: "number" },
  { label: "Unit Price", fieldName: "unit_price", type: "currency" },
  { label: "Total Price", fieldName: "total_price", type: "currency" },
];
export default class OrderProducts extends LightningElement {
  @track data = [];
  columns = DATA_COLUMNS;
  @api recordId;
  subscription = null;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.getAndUpdateOrderProducts();
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.unsubscribeToMessageChanel();
  }

  getAndUpdateOrderProducts() {
    getOrderProducts({ orderId: this.recordId })
      .then((result) => {
        this.data = result.map((orderProduct) => ({
          name: orderProduct.name,
          unit_price: orderProduct.unitPrice,
          id: orderProduct.id,
          total_price: orderProduct.totalPrice,
          quantity: orderProduct.quantity,
        }));
      })
      .catch((err) => console.error("Some err", err));
  }

  subscribeToMessageChannel() {
    if(this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, refreshMessageChannel, (message) => {
      if(message.message === "refresh-order-products") {
        this.getAndUpdateOrderProducts();
      }
    });
  }

  unsubscribeToMessageChanel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleActivateButtonClick() {
    throw new Error("Not implemented yet!");
    const orderId = this.recordId;
    activateOrder({orderId})
      .then(() => {
        console.log("finished to add :)")
      })
      .catch(err => console.error(err))
  }
}