import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import evaluateText from "@salesforce/apex/LwcDynamicBannerController.evaluateText";

export default class DynamicBanner extends LightningElement {
	@api recordId;

	@api title;
	@api text;
	@api backgroundColor;
	@api fontColor;
	@api fontSize;
	@api alignment;
	@api borderStyle;
	@api borderRadius;
	@api iconName;
	@api iconSize;
	@api iconVariant;

	textsToProcess = [];
	processedTitle;
	processedText;

	//To listen to record changes, so we can re-evaluate the texts
	@wire(getRecord, { recordId: "$recordId", layoutTypes: ["Full"], modes: ["View"] })
	wiredRecord({ error, data }) {
		if (data) {
			refreshApex(this.wiredEvaluateTextReference);
		}
	}

	wiredEvaluateTextReference = null;
	@wire(evaluateText, { recordId: "$recordId", textsToProcess: "$textsToProcess" })
	wiredEvaluateText(wireResult) {
		this.wiredEvaluateTextReference = wireResult;
		const { error, data } = wireResult;
		if (data) {
			this.processedTitle = data[0];
			this.processedText = data[1];
		} else if (error) {
			console.error("Error processing text:", error);
		}
	}

	connectedCallback() {
		this.textsToProcess = [this.title, this.text];
	}

	renderedCallback() {
		//Apply styles to the banner
		const bannerDiv = this.template.querySelector(".dynamic-banner");
		if (bannerDiv) {
			bannerDiv.style.backgroundColor = this.backgroundColor;
			bannerDiv.style.color = this.fontColor;
			bannerDiv.style.fontSize = this.fontSize;
			bannerDiv.style.textAlign = this.alignment;
			bannerDiv.style.justifyContent = this.alignment;
			bannerDiv.style.border = this.borderStyle;
			bannerDiv.style.borderRadius = this.borderRadius;
		}
	}

	get hasIcon() {
		return this.iconName !== undefined && this.iconName !== null && this.iconName !== "";
	}
}
