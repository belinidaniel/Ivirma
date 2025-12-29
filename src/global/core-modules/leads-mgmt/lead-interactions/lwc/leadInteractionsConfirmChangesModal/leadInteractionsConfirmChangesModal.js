import LightningModal from "lightning/modal";
import { api } from "lwc";

export default class LeadInteractionsConfirmChangesModal extends LightningModal {
	@api leadId;
	@api updates;

	confirmChanges() {
		this.close({ confirm: true });
	}

	cancel() {
		this.close({ confirm: false });
	}
}
