import { LightningElement, api } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import PrettyPrintJsonResources from "@salesforce/resourceUrl/PrettyPrintJsonJs"; // Documentation for this library component: https://github.com/center-key/pretty-print-json

export default class PrettyPrintJson extends LightningElement {
	@api json;
	@api lineNumbers = false;
	@api quoteKeys = false;
	@api trailingCommas = false;
	@api darkMode = false;

	_json;

	resourcesLoaded = false;
	initialized = false;

	connectedCallback() {
		this._json = this.json;
		if (typeof this.json === "string") {
			this._json = JSON.parse(this.json);
		}
	}

	async renderedCallback() {
		await this.loadResources();
		await this.renderJson();
	}

	async loadResources() {
		if (this.resourcesLoaded) {
			return;
		}

		this.resourcesLoaded = true;
		try {
			await Promise.all([
				loadScript(this, PrettyPrintJsonResources + "/pretty-print-json.min.js"),
				loadStyle(this, PrettyPrintJsonResources + "/css/pretty-print-json.css")
			]);
			this.initialized = true;
		} catch (error) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: "Error loading PrettyPrintJsonResources",
					variant: "error"
				})
			);
			throw error;
		}
	}

	renderJson() {
		if (!this.initialized) {
			return;
		}
		const options = {
			indent: 3,
			lineNumbers: this.lineNumbers || false,
			linkUrls: false,
			linksNewTab: false,
			quoteKeys: this.quoteKeys || false,
			trailingCommas: this.trailingCommas || false
		};
		this.refs.container.innerHTML = window.prettyPrintJson.toHtml(this._json, options);
	}
}
