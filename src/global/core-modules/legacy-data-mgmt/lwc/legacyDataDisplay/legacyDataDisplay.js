import { LightningElement, api, wire } from "lwc";
import getLegacyData from "@salesforce/apex/LegacyDataController.getLegacyData";

export default class LegacyDataDisplay extends LightningElement {
	@api recordId;
	@api layoutColumns = "single";
	@api layoutType = "card";
	@api hideIfNoData = false;
	@api noDataMessage = "No Legacy data found";
	@api componentTitle = "Legacy Data";
	legacyData;
	error;

	get isCardLayout() {
		return this.layoutType === "card";
	}

	get isSectionLayout() {
		return this.layoutType === "section";
	}

	get containerClass() {
		return this.layoutColumns === "two" ? "slds-grid slds-wrap" : "";
	}

	get itemClass() {
		return this.layoutColumns === "two" ? "slds-col slds-size_1-of-2 slds-p-right_small" : "slds-col";
	}

	get hasLegacyData() {
		return this.legacyData && this.legacyData.length > 0;
	}

	get isLightningAppBuilder() {
		return window.location.href.indexOf("flexipageEditor") > -1;
	}

	get shouldDisplayComponent() {
		// Always display this component if we're in builder mode
		if (this.isLightningAppBuilder) {
			return true;
		}
		return !this.hideIfNoData || this.hasLegacyData;
	}

	@wire(getLegacyData, { recordId: "$recordId" })
	wiredLegacyData({ error, data }) {
		if (data) {
			this.legacyData = data;
			this.error = undefined;
		} else if (error) {
			this.error = error;
			this.legacyData = undefined;
		}
	}
}
