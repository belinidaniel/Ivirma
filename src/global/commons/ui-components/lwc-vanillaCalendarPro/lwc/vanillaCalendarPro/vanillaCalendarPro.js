import { LightningElement, api } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import VanillaCalendarProResources from "@salesforce/resourceUrl/VanillaCalendarProJs"; // Documentation for this library component: https://vanilla-calendar.pro/docs/reference

export default class VanillaCalendarPro extends LightningElement {
	@api
	options; // Same as VanillaCalendarPro options: https://vanilla-calendar.pro/docs/reference

	resourcesLoaded = false;
	initialized = false;
	instance = null;

	async renderedCallback() {
		await this.loadResources();
		await this.initialize();
	}

	disconnectedCallback() {
		if (this.instance) {
			this.instance.destroy();
			this.instance = null;
			this.initialized = false;
			this.resourcesLoaded = false;
		}
	}

	async loadResources() {
		if (this.resourcesLoaded) {
			return;
		}

		this.resourcesLoaded = true;
		try {
			await Promise.all([
				loadScript(this, VanillaCalendarProResources + "/index.js"),
				loadStyle(this, VanillaCalendarProResources + "/styles/themes/slate-light.css"),
				loadStyle(this, VanillaCalendarProResources + "/styles/layout.css")
			]);
		} catch (error) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: "Error loading VanillaCalendarProResources",
					variant: "error"
				})
			);
			throw error;
		}
	}

	async initialize() {
		if (this.initialized) {
			return;
		}

		const { Calendar } = window.VanillaCalendarPro;
		this.instance = new Calendar(this.refs.calendar, this.options);
		this.instance.init();

		this.initialized = true;
	}

	@api
	getCalendarInstance() {
		return this.instance;
	}
}
