import { api, LightningElement, track } from "lwc";
import getOrderProducts from "@salesforce/apex/OrderProductsController.getOrderProducts"
import activateOrder from "@salesforce/apex/OrderProductsController.activateOrder"

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

  connectedCallback() {
    getOrderProducts({ orderId: this.recordId })
      .then((result) => {
        this.data = result.map((orderProduct) => ({
          name: orderProduct.name,
          unit_price: orderProduct.unitPrice,
          id: orderProduct.id,
          total_price: orderProduct.totalPrice,
          quantity: orderProduct.quantity,
        }));
        console.log("obtained products");
      })
      .catch((err) => console.error("Some err", err));
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