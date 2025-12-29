import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { updateRecord } from "lightning/uiRecordApi";
import getLeadInteractions from "@salesforce/apex/LwcLeadInteractionsController.getLeadInteractions";
import getLeadCurrentValues from "@salesforce/apex/LwcLeadInteractionsController.getLeadCurrentValues";
import LeadInteractionsConfirmChangesModal from "c/leadInteractionsConfirmChangesModal";

export default class LeadInteractionsDisplayer extends LightningElement {
	@api recordId;
	@api fieldSetName;

	isLoading = true;
	isApplyButtonDisabled = true;
	interactionsData;
	leadFieldToUniqueKeyMap = new Map();
	modalUpdates = [];
	selectedItems = new Set();
	wiredResult;

	@wire(getRecord, { recordId: "$recordId", layoutTypes: ["Full"], modes: ["View"] })
	wiredLead({ error, data }) {
		refreshApex(this.wiredResult);
		this.selectedItems.clear();
		this.leadFieldToUniqueKeyMap.clear();
		this.lead = data;
		this.isApplyButtonDisabled = true;
		const checkboxes = this.template.querySelectorAll('[id^="checkbox"]');
		checkboxes.forEach((box) => (box.checked = false));
	}

	@wire(getLeadInteractions, { leadRecordId: "$recordId", fieldSetName: "$fieldSetName" })
	wiredInteractions(result) {
		this.wiredResult = result;
		const { error, data } = result;
		if (data) {
			this.interactionsData = data.map((interaction, index) => {
				const clonedInteraction = { ...interaction, expandableSectionInitialState: index === 0 ? "open" : "close" };
				clonedInteraction.values = interaction.values.map((value) => {
					return {
						...value,
						uniqueKey: interaction.id + "-" + value.fieldApiName,
						showCheckbox: value.isSynchable ? "checkbox" : "hidden-checkbox"
					};
				});

				return clonedInteraction;
			});
			this.isLoading = false;
		} else if (error) {
			this.isLoading = false;
			console.error("Error retrieving lead interactions", error);
		}
	}

	handleCheckboxChange(event) {
		const fieldApiName = event.target.dataset.field;
		const leadField = event.target.dataset.fieldLead;
		const uniqueKey = event.target.dataset.uniqueKey;
		const isChecked = event.target.checked;

		if (isChecked) {
			if (this.leadFieldToUniqueKeyMap.has(leadField)) {
				const oldUniqueKey = this.leadFieldToUniqueKeyMap.get(leadField);
				this.selectedItems.delete(oldUniqueKey);
				const oldCheckbox = this.template.querySelector(`lightning-input[data-unique-key="${oldUniqueKey}"]`);
				if (oldCheckbox) {
					oldCheckbox.checked = false;
				}
			}
			this.leadFieldToUniqueKeyMap.set(leadField, uniqueKey);
			this.selectedItems.add(uniqueKey);
		} else {
			this.selectedItems.delete(uniqueKey);
			if (this.leadFieldToUniqueKeyMap.get(leadField) === uniqueKey) {
				this.leadFieldToUniqueKeyMap.delete(leadField);
			}
		}
		this.isApplyButtonDisabled = this.selectedItems.size === 0;
	}

	async handleApplySelections() {
		const selectedLeadFields = [];
		this.leadFieldToUniqueKeyMap.forEach((uniqueKey, leadField) => {
			selectedLeadFields.push(leadField);
		});

		const leadValues = await getLeadCurrentValues({
			leadId: this.recordId,
			leadFields: selectedLeadFields
		});

		this.modalUpdates = [];
		this.interactionsData.forEach((interaction) => {
			interaction.values.forEach((item) => {
				if (this.selectedItems.has(item.uniqueKey)) {
					this.modalUpdates.push({
						fieldApiName: item.leadFieldApiName,
						currentValue: leadValues[item.leadFieldApiName],
						value: item.value,
						mergeBehaviour: item.mergeBehaviour,
						interaction: interaction.name
					});
				}
			});
		});

		const modalResult = await LeadInteractionsConfirmChangesModal.open({
			size: "small",
			leadId: this.recordId,
			updates: this.modalUpdates
		});

		if (modalResult.confirm) {
			try {
				this.isLoading = true;
				const fields = { Id: this.recordId };
				this.modalUpdates.forEach((update) => {
					console.log("update", JSON.stringify(update));
					console.log("update", this.valueToUpdate(update));
					fields[update.fieldApiName] = this.valueToUpdate(update);
				});

				const recordInput = { fields };
				const clientOptions = { ifUnmodifiedSince: this.lead.fields.LastModifiedDate.value };

				await updateRecord(recordInput, clientOptions);

				this.dispatchEvent(
					new ShowToastEvent({
						title: "Success",
						message: "Lead updated successfully.",
						variant: "success"
					})
				);
			} catch (error) {
				console.error("Error updating lead:", JSON.stringify(error));

				const errorMessage = error.body?.output?.errors?.find((err) => err.errorCode === "CollisionDetectedException")
					? "Record modified by another user. Reload and try again."
					: error.body?.message || "Unexpected error occurred.";

				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message: errorMessage,
						variant: "error"
					})
				);
			} finally {
				this.isLoading = false;
			}
		}
	}

	valueToUpdate(update) {
		if (update.mergeBehaviour == "replace") {
			return update.value;
		}
		if (update.mergeBehaviour == "append") {
			return update.currentValue + " " + update.value;
		}
		if (update.mergeBehaviour == "append_with_headerinfo") {
			update.currentValue == undefined ? (update.currentValue = "") : update.currentValue;
			return `${update.interaction}:\n${update.value}\n\n${update.currentValue}`;
		}
	}

	get cardTitle() {
		let title = "Interactions";
		if (this.interactionsData && this.interactionsData.length >= 0) {
			title += ` (${this.interactionsData.length})`;
		}
		return title;
	}
}
