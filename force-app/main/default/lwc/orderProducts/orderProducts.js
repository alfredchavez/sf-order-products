import { api, LightningElement, wire } from "lwc";
import getOrderProducts from "@salesforce/apex/OrderProductsController.getOrderProducts";
import activateOrder from "@salesforce/apex/OrderProductsController.activateOrder";
import getOrder from "@salesforce/apex/OrderProductsController.getOrder";
import { MessageContext, publish, subscribe, unsubscribe } from "lightning/messageService";
import refreshMessageChannel from "@salesforce/messageChannel/RefreshMessageChannel__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const DATA_COLUMNS = [
  { label: "Name", fieldName: "name", type: "text", sortable: "true" },
  { label: "Quantity", fieldName: "quantity", type: "number", sortable: "true" },
  { label: "Unit Price", fieldName: "unit_price", type: "currency", sortable: "true" },
  { label: "Total Price", fieldName: "total_price", type: "currency", sortable: "true" }
];
export default class OrderProducts extends LightningElement {
  data = [];
  columns = DATA_COLUMNS;
  sortBy;
  sortDirection;

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

  handleSortClick (event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.data = this.sortedData(this.sortBy, this.sortDirection);
  }

  sortedData(sortBy, sortDirection) {
    const newData = [...this.data];
    newData.sort((a, b) => {
      const direction = sortDirection === "asc" ? -1 : 1;
      return direction * ((a[sortBy] > b[sortBy]) - (b[sortBy] > a[sortBy]));
    })
    return newData;
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