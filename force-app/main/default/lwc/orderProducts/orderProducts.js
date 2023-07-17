import { api, LightningElement, track, wire } from "lwc";
import getOrderProducts from "@salesforce/apex/OrderProductsController.getOrderProducts";
import activateOrder from "@salesforce/apex/OrderProductsController.activateOrder";
import getOrder from "@salesforce/apex/OrderProductsController.getOrder";
import { MessageContext, publish, subscribe, unsubscribe } from "lightning/messageService";
import refreshMessageChannel from "@salesforce/messageChannel/RefreshMessageChannel__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const DATA_COLUMNS = [
  { label: "Name", fieldName: "name", type: "text" },
  { label: "Quantity", fieldName: "quantity", type: "number" },
  { label: "Unit Price", fieldName: "unit_price", type: "currency" },
  { label: "Total Price", fieldName: "total_price", type: "currency" }
];
export default class OrderProducts extends LightningElement {
  @track data = [];
  columns = DATA_COLUMNS;
  @api recordId;
  subscription = null;
  isActivateDisabled = true;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.getOrderData();
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
          quantity: orderProduct.quantity
        }));
      })
      .catch((err) => console.error(err));
  }

  getOrderData() {
    getOrder({orderId: this.recordId})
      .then(order => {
        this.isActivateDisabled = order.status === "Activated";
      })
      .catch((err) => {
        console.error(err);
        this.isActivateDisabled = true;
      })
  }

  subscribeToMessageChannel() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, refreshMessageChannel, (message) => {
      if (message.message === "refresh-order-products") {
        this.getAndUpdateOrderProducts();
      }
    });
  }

  unsubscribeToMessageChanel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  showNotification(message, isError = false) {
    const event = new ShowToastEvent({
      title: isError ? "Unsuccessful operation" : "Successful operation",
      message: message,
      variant: isError ? "error" : "success"
    });
    this.dispatchEvent(event);
  }

  handleActivateButtonClick() {
    this.isActivateDisabled = true;
    const orderId = this.recordId;
    activateOrder({ orderId })
      .then(() => {
        this.showNotification("Order was successfully activated");
        publish(this.messageContext, refreshMessageChannel, { message: "order-is-activated" });
      })
      .catch(err => {
        console.error(err);
        this.isActivateDisabled = false;
        this.showNotification("Order could not be activated", true);
      });
  }
}