import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class ScreenFlowModal extends LightningModal {
	@api label = "Screen Flow";
	@api flowName;
	@api inputVariables;
	@api flowFinishBehaviour = "NONE"; //Either NONE or RESTART

	handleStatusChange(event) {
		if (event.detail.status === "FINISHED") {
			this.close(event.detail.status, event.detail.outputVariables);
		}
	}

	handleClose() {
		this.close("CLOSED");
	}
}
