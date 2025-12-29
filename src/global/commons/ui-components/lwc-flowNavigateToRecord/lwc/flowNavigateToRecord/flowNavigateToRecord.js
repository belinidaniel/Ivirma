import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class FlowNavigateToRecord extends NavigationMixin(LightningElement) {
	@api recordId;
	@api mode = "view"; //clone, edit or view
	@api autoNavigate = false;
	@api buttonLabel = "Navigate";
	@api buttonTitle = "Navigate to record";
	@api buttonVariant = "neutral";

	connectedCallback() {
		if (this.autoNavigate) {
			this.navigate();
		}
	}

	navigate() {
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: this.recordId,
				actionName: this.mode
			}
		});
	}
}
