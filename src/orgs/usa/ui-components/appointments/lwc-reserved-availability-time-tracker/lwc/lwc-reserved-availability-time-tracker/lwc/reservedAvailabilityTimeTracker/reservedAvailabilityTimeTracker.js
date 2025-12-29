import { LightningElement, api } from "lwc";

export default class ReservedAvailabilityTimeTracker extends LightningElement {
	@api
	reservedAvailabilitySlot = null;

	remainingTime = null;
	expired = false;
	_interval;

	connectedCallback() {
		this.calculateRemainingTime();
		this.defineInterval();
	}

	disconnectedCallback() {
		this.removeInterval();
	}

	defineInterval() {
		this._interval = setInterval(() => {
			this.calculateRemainingTime();
			if (this.expired) {
				this.removeInterval();
			}
		}, 1000);
	}

	removeInterval() {
		if (this._interval) {
			clearInterval(this._interval);
		}
	}

	calculateRemainingTime() {
		this.remainingTime = this.reservedAvailabilitySlot?.reservedUntil ? this._getTimeRemaining(this.reservedAvailabilitySlot.reservedUntil) : null;
		this.expired = this.remainingTime?.totalSeconds <= 0 || false;
	}

	get formattedTimeClassNames() {
		let classNames = ["slds-text-align_right", "slds-text-body_small"];
		if (this.remainingTime?.totalSeconds <= 90) {
			classNames.push("slds-text-color_error");
		}
		return classNames.join(" ");
	}

	get formattedTimeRemaining() {
		if (!this.remainingTime) {
			return "";
		}

		if (this.remainingTime.total <= 0) {
			return "Reserved time has expired";
		}

		if (this.remainingTime.days > 0) {
			return `${this.remainingTime.days} days, ${this.remainingTime.hours} hours, ${this.remainingTime.minutes} minutes and ${this.remainingTime.seconds} seconds`;
		}

		if (this.remainingTime.hours > 0) {
			return `${this.remainingTime.hours} hours, ${this.remainingTime.minutes} minutes and ${this.remainingTime.seconds} seconds`;
		}

		if (this.remainingTime.minutes > 0) {
			return `${this.remainingTime.minutes} minutes and ${this.remainingTime.seconds} seconds`;
		}

		return `${this.remainingTime.seconds} seconds`;
	}

	_getTimeRemaining(strDateTime) {
		const totalMilliseconds = Date.parse(strDateTime) - Date.parse(new Date());
		const totalSeconds = Math.floor(totalMilliseconds / 1000);
		const seconds = Math.floor((totalMilliseconds / 1000) % 60);
		const minutes = Math.floor((totalMilliseconds / 1000 / 60) % 60);
		const hours = Math.floor((totalMilliseconds / (1000 * 60 * 60)) % 24);
		const days = Math.floor(totalMilliseconds / (1000 * 60 * 60 * 24));
		return { totalMilliseconds, totalSeconds, days, hours, minutes, seconds };
	}
}
