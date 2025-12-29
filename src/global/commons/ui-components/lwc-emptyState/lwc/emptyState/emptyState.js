import { LightningElement, api } from "lwc";
import { getSvg } from "./lightningIllustration/lightningIllustrationHelper";

//https://v1.lightningdesignsystem.com/components/illustration/

export default class EmptyState extends LightningElement {
	@api size = "small";
	@api illustration = null; //Possible values: desert, road, access, event, lake, camping, maintenance, connection, lightning, page, walkthrough, task, fishing, fishing2, setup, access2, content, preview, nopreview, research
	@api header;
	@api description;
	@api buttonLabel = null;
	@api buttonIcon = null;
	@api linkLabel = null;
	@api greyscale = false;

	get containerClass() {
		return `slds-illustration slds-illustration_${this.size}${this.greyscale ? " greyscale" : ""}`;
	}

	get showIllustration() {
		return this.illustration !== null && this.illustration !== "";
	}

	get showButton() {
		return this.buttonLabel !== null && this.buttonLabel !== "";
	}

	get showLink() {
		return this.linkLabel !== null && this.linkLabel !== "";
	}

	renderedCallback() {
		if (this.showIllustration) {
			const container = this.template.querySelector(".svg-container");
			container.innerHTML = getSvg(this.illustration);
		}
	}

	handleLinkClick() {
		this.dispatchEvent(new CustomEvent("linkclick"));
	}

	handleButtonClick() {
		this.dispatchEvent(new CustomEvent("buttonclick"));
	}
}
