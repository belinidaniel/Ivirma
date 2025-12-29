import { LightningElement, api } from "lwc";

export default class CalendarAppointmentAvailabilityPicker extends LightningElement {
	@api
	availabilitySlots = [];
	@api
	noSelectionErrorMessage = "Please select a slot";

	flowErrorMessageToRender; // Only defined when component is rendered in flows
	cachedFlowErrorMessageToRender; // Only defined when component is rendered in flows
	internalErrorMessageToRender;

	selectedDateAvailabilitySlots = [];
	selectedDate = null;
	selectedSlotId = null;

	calendarOptions = null;

	connectedCallback() {
		if (!this.availabilitySlots) {
			this.availabilitySlots = [];
		}

		this.calendarOptions = {
			selectedTheme: "slate-light",
			selectionMonthsMode: "only-arrows",
			selectionYearsMode: false,
			disableAllDates: true,
			enableDates: this.getDaysWithAvailabilities(),
			onClickDate: this.handleDateSelected.bind(this),
			popups: this.buildCalendarPopups(),
			styles: {
				headerContent: "calendar-header-content"
			}
		};
	}

	getDaysWithAvailabilities() {
		// Get all the unique days with availabilities
		const daysWithAvailabilities = new Set();
		this.availabilitySlots.forEach((slot) => {
			daysWithAvailabilities.add(slot.startDateTime.split("T")[0]);
		});
		return Array.from(daysWithAvailabilities);
	}

	buildCalendarPopups() {
		//for each date in the availability slots, count the number of slots for that day, storing the count in the popups object
		const availabilitiesPerDate = new Map();
		this.availabilitySlots.forEach((slot) => {
			const date = slot.startDateTime.split("T")[0];
			if (!availabilitiesPerDate.has(date)) {
				availabilitiesPerDate.set(date, 0);
			}
			availabilitiesPerDate.set(date, availabilitiesPerDate.get(date) + 1);
		});

		// return an object, where the keys is the date, and the value is an object with the modifier and html properties
		return Array.from(availabilitiesPerDate.entries()).reduce((acc, [dateKey, count]) => {
			acc[dateKey] = {
				modifier: "bg-red color-pink",
				html: `
                    <div>
                        <b>${count} slots available</b>
                    </div>
                `
			};
			return acc;
		}, {});
	}

	handleDateSelected(self, event) {
		// Filter availability slots by the selected date
		this.selectedDate = self.context.selectedDates[0] || null;
		let availabilitySlots = this.selectedDate ? this.availabilitySlots.filter((slot) => slot.startDateTime.split("T")[0] === this.selectedDate) : [];
		availabilitySlots = availabilitySlots.sort((a, b) => new Date(a.startDateTime) - new Date(b.startDateTime));
		this.selectedDateAvailabilitySlots = availabilitySlots;
		this.selectedSlotId = null;
	}

	handleSlotSelected(event) {
		if (this.selectedSlotId === event.detail.slotId) {
			// Unselect the slot if clicked again
			this.selectedSlotId = null;
		} else {
			this.selectedSlotId = event.detail.slotId;
		}

		// Update the selected state of all slots
		this.template.querySelectorAll("c-calendar-appointment-availability-slot-item-view").forEach((slot) => {
			slot.selected = slot.getSlotId() === this.selectedSlotId;
		});

		this.dispatchEvent(new CustomEvent("selected", { detail: { slotId: this.selectedSlotId, slot: this.selectedSlot } }));
	}

	get hasNoData() {
		return this.availabilitySlots && this.availabilitySlots.length === 0;
	}

	@api
	get selectedSlot() {
		if (!this.selectedSlotId) {
			return null;
		}

		return this.availabilitySlots.find((slot) => slot.id === this.selectedSlotId);
	}

	@api validate() {
		return {
			isValid: this.selectedSlotId !== null,
			errorMessage: this.selectedSlotId === null ? this.noSelectionErrorMessage : null
		};
	}

	@api
	setCustomValidity(externalErrorMessage) {
		if (this.flowErrorMessageToRender) {
			this.flowErrorMessageToRender = externalErrorMessage;
		}

		this.cachedFlowErrorMessageToRender = externalErrorMessage;
	}

	@api reportValidity() {
		this.flowErrorMessageToRender = this.cachedFlowErrorMessageToRender;
		this.internalErrorMessageToRender = this.validate().errorMessage;
	}
}
