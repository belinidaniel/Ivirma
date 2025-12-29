import { LightningElement, api } from "lwc";

export default class ExpandableSection extends LightningElement {
	@api id;
	@api label;
	@api initialState = "open"; // open or close. Only applicable if collapsable is true
	@api collapsable = false;

	sectionState = "open"; // open or close

	connectedCallback() {
		this.id = this.id || Math.random().toString(36).substring(2, 15);

		if (!this.collapsable) {
			this.sectionState = "open";
			this.initialState = "open";
		} else {
			this.initialState = this.initialState?.toLowerCase() || "";
			if (this.initialState !== "open" && this.initialState !== "close") {
				this.initialState = "open";
			}

			this.sectionState = this.initialState;
		}
	}

	handleToggleSection(event) {
		event.stopPropagation();

		if (!this.collapsable) {
			return;
		}
		this.sectionState = this.sectionState === "open" ? "close" : "open";
	}

	get sectionStateClass() {
		return this.sectionState === "open" ? "slds-section slds-is-open" : "slds-section slds-is-close";
	}
}