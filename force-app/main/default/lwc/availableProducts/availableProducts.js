import { LightningElement, api, wire } from "lwc";
import getAvailableProducts from "@salesforce/apex/AvailableProductsController.getAvailableProducts";
import addProductToOrder from "@salesforce/apex/AvailableProductsController.addProductToOrder";
import getOrder from "@salesforce/apex/AvailableProductsController.getOrder";
import { MessageContext, publish, subscribe, unsubscribe } from "lightning/messageService";
import refreshMessageChannel from "@salesforce/messageChannel/RefreshMessageChannel__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const DATA_COLUMNS = [
  { label: "Name", fieldName: "name", type: "text", sortable: "true" },
  { label: "List Price", fieldName: "list_price", type: "currency",  sortable: "true" },
  {
    type: "button",
    initialWidth: 100,
    typeAttributes: { label: "Add", name: "add_to_order", value:"add_to_order", title: "Add Product to Order", disabled: { fieldName: "is_disabled" } }
  }
];

export default class AvailableProducts extends LightningElement {
  data = [];
  areButtonsDisabled = true;
  columns = DATA_COLUMNS;
  sortBy;
  sortDirection;
  searchTextValue = "";

  @api recordId;
  subscription = null;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.getOrderData();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChanel();
  }

  subscribeToMessageChannel() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, refreshMessageChannel, (message) => {
      if (message.message === "order-is-activated") {
        this.areButtonsDisabled = true;
        this.getAndUpdateAvailableProducts();
      }
    });
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

  handleInputChange(event) {
    this.searchTextValue = event.detail.value ?? "";
  }

  handleSearchButtonClick() {
    this.getAndUpdateAvailableProducts();
  }

  unsubscribeToMessageChanel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  getOrderData() {
    getOrder({ orderId: this.recordId })
      .then(order => {
        this.areButtonsDisabled = order.status === "Activated";
        this.getAndUpdateAvailableProducts();
      })
      .catch((err) => {
        console.error(err);
        this.areButtonsDisabled = false;
      });
  }

  getAndUpdateAvailableProducts() {
    getAvailableProducts({ orderId: this.recordId, search: this.searchTextValue })
      .then((result) => {
        result.sort((a, b) => (a.alreadyAdded && b.alreadyAdded ? 0 : a.alreadyAdded ? -1 : 1));
        this.data = result.map((pbe) => ({
          name: pbe.name,
          list_price: pbe.price,
          id: pbe.id,
          is_disabled: this.areButtonsDisabled
        }));
      })
      .catch((err) => {
        console.error(err);
      });
  }

  showNotification(message, isError = false) {
    const event = new ShowToastEvent({
      title: isError ? "Unsuccessful operation" : "Successful operation",
      message: message,
      variant: isError ? "error" : "success"
    });
    this.dispatchEvent(event);
  }

  handleAddToOrder(row) {
    const productId = row.id;
    const orderId = this.recordId;
    addProductToOrder({ productId, orderId })
      .then(() => {
        this.showNotification("Product was correctly added to this Order");
        publish(this.messageContext, refreshMessageChannel, { message: "refresh-order-products" });
      })
      .catch(err => {
        console.error(err);
        this.showNotification("Product could not be added to this Order", true);
      });
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "add_to_order":
        this.handleAddToOrder(row);
        break;
      default:
        throw Error("Action not implemented yet");
    }
  }
}
