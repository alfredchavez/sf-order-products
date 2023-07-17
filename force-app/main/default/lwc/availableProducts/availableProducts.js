import { LightningElement, api, wire } from "lwc";
import getAvailableProducts from "@salesforce/apex/AvailableProductsController.getAvailableProducts";
import addProductToOrder from "@salesforce/apex/AvailableProductsController.addProductToOrder"
import { MessageContext, publish } from "lightning/messageService";
import refreshMessageChannel from '@salesforce/messageChannel/RefreshMessageChannel__c';

const ROW_ACTIONS = [
  {label: "Add to Order", name: "add_to_order"}
];

const DATA_COLUMNS = [
  { label: "Name", fieldName: "name", type: "text" },
  { label: "List Price", fieldName: "list_price", type: "currency" },
  {type: "action", typeAttributes: {rowActions: ROW_ACTIONS}}
];

export default class AvailableProducts extends LightningElement {
  data = [];
  columns = DATA_COLUMNS;
  @api recordId;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    getAvailableProducts({ orderId: this.recordId })
      .then((result) => {
        this.data = result.map((pbe) => ({
          name: pbe.name,
          list_price: pbe.price,
          id: pbe.id
        }));
      })
      .catch((err) => console.error("Some err", err));
  }

  handleAddToOrder(row) {
    const productId = row.id;
    const orderId = this.recordId;
    addProductToOrder({productId, orderId})
      .then(() => {
        console.log("finished to add :)")
        publish(this.messageContext, refreshMessageChannel, {message: "refresh-order-products"})
      })
      .catch(err => console.error(err))
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
