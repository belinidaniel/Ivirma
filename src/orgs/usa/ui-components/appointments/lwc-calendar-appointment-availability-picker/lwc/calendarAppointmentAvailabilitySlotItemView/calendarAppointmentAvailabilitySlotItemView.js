import { LightningElement, api } from "lwc";
import TIME_ZONE from "@salesforce/i18n/timeZone";

export default class CalendarAppointmentAvailabilitySlotItemView extends LightningElement {
	@api availabilitySlot;
	@api selected = false;
	@api tabIndex = 0;

	userTimeZone = TIME_ZONE;

	@api
	getSlotId() {
		return this.availabilitySlot.id;
	}

	selectSlot() {
		if (this.availabilitySlot.status !== "free") {
			return;
		}

		this.dispatchEvent(new CustomEvent("select", { detail: { slotId: this.availabilitySlot.id } }));
	}

	handleClick(event) {
		event.preventDefault();
		this.selectSlot();
	}

	handleKeydown(event) {
		if (event.key === "Enter" || event.key === " ") {
			event.preventDefault();
			this.selectSlot();
		}
	}

	get badgeStatusClass() {
		// Return SLDS badge color class based on status
		switch ((this.availabilitySlot.status || "").toLowerCase()) {
			case "free":
				return "slds-theme_success";
			case "reserved":
				return "slds-theme_error";
			default:
				return "slds-theme_warning";
		}
	}

	get cardClass() {
		let classes = ["slds-card", "slds-m-bottom_medium", "slds-card_boundary"];
		classes.push(this.availabilitySlot.status === "free" ? "clickable" : "unclickable");

		if (this.selected) {
			classes.push("selected");
		}

		return classes.join(" ");
	}

	get isReserved() {
		return this.availabilitySlot.status === "reserved";
	}

	get reservedUntil() {
		return new Date(this.availabilitySlot.reservedUntil);
	}

	get reservedBy() {
		return "Reserved by " + this.availabilitySlot.reservedBy;
	}

	get providerName() {
		return this.availabilitySlot.internalContext?.provider?.Name || "";
	}

	get isProviderMissingFromDatabase() {
		return !this.availabilitySlot.internalContext?.provider?.Id;
	}

	get providerMissingText() {
		return `Provider with Id ${this.availabilitySlot.providerId} missing from database`;
	}

	get locationName() {
		return this.availabilitySlot.internalContext?.location?.Name || "";
	}

	get isLocationMissingFromDatabase() {
		return !this.availabilitySlot.internalContext?.location?.Id;
	}

	get locationMissingText() {
		return `Location with Id ${this.availabilitySlot.locationId} missing from database`;
	}
}
