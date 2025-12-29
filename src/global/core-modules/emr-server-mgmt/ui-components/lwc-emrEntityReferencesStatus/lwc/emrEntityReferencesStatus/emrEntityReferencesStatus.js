import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasManageEntityReferencesPermission from "@salesforce/userPermission/ViewSetup"; //TODO create proper permission ManageEntityReferences
import hasManageEntitySyncPermission from "@salesforce/userPermission/ViewSetup"; //TODO create proper permission ManageEntitySync
import getEntityReferences from "@salesforce/apex/EmrEntityReferencesStatusController.getEntityReferences";
import createEntityReference from "@salesforce/apex/EmrEntityReferencesStatusController.createEntityReference";

const EXISTING_REF_ACTIONS = [
	{ label: "Push", name: "push", disabled: !hasManageEntitySyncPermission },
	{ label: "Pull", name: "pull", disabled: !hasManageEntitySyncPermission },
	{ label: "Compare", name: "diff", disabled: false },
	{ label: "Make Primary", name: "make_primary", disabled: !hasManageEntitySyncPermission }
];

const NON_EXISTING_REF_ACTIONS = [
	{ label: "Lookup", name: "lookup", disabled: !hasManageEntityReferencesPermission },
	{ label: "Set", name: "set_reference", disabled: !hasManageEntityReferencesPermission }
];

export default class EmrEntityReferencesStatus extends LightningElement {
	@api recordId;
	@api componentTitle;
	@api componentIcon;

	columns = [
		{
			label: "",
			hideLabel: true,
			fixedWidth: 35,
			sortable: false,
			hideDefaultActions: true,
			cellAttributes: { iconName: { fieldName: "primaryRefIconName" }, iconPosition: "left", iconAlternativeText: "Primary reference" }
		},
		{
			label: "Server",
			fieldName: "serverUrl",
			type: "url",
			fixedWidth: 100,
			typeAttributes: {
				label: { fieldName: "serverName" },
				tooltip: { fieldName: "serverName" },
				target: "_self"
			},
			sortable: false,
			hideDefaultActions: true
		},
		{ label: "Reference", fieldName: "reference", sortable: false, hideDefaultActions: true },
		{
			label: "Last sync",
			fieldName: "lastSync",
			type: "date",
			typeAttributes: { day: "numeric", month: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit" },
			sortable: false,
			hideDefaultActions: true
		},
		{
			type: "action",
			typeAttributes: { rowActions: this.getRowActions }
		}
	];
	entityReferences = [];
	wireEntityReferences;
	error;

	selectedServerNameReferenceAction;
	newReferenceValue;
	showInputReferenceBox = false; // Track whether to show the input box
	selectedRow; // Store the selected row

	@wire(getEntityReferences, { entityId: "$recordId" })
	wiredEntityReferences(wiredReference) {
		this.wireEntityReferences = wiredReference; // Store the wire reference for refresh
		const { data, error } = wiredReference;
		if (data) {
			// Add the icon name for primary references
			this.entityReferences = data.map((reference) => ({
				...reference,
				primaryRefIconName: reference.isPrimary ? "standard:opportunity" : ""
			}));
			this.error = undefined;
		} else if (error) {
			this.error = error;
			this.entityReferences = [];
		}
	}

	getRowActions(row, doneCallback) {
		// Check if the row has a reference number to determine if it's an existing reference
		const isExistingReference = !!row.reference;
		return doneCallback(isExistingReference ? EXISTING_REF_ACTIONS : NON_EXISTING_REF_ACTIONS);
	}

	handleRowAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		switch (actionName) {
			case "set_reference":
				this.showInputReferenceBox = true; // Show the input box
				this.selectedServerNameReferenceAction = row.serverName + " Reference";
				this.selectedRow = row; // Store the selected row
				break;
			case "push":
				// Handle push action
				//TODO
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Not implemented",
						variant: "info"
					})
				);
				break;
			case "pull":
				// Handle pull action
				//TODO
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Not implemented",
						variant: "info"
					})
				);
				break;
			case "diff":
				// Handle diff action
				//TODO
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Not implemented",
						variant: "info"
					})
				);
				break;
			case "lookup":
				// Handle lookup action
				//TODO
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Not implemented",
						variant: "info"
					})
				);
				break;
		}
	}

	handleRefreshButtonClick() {
		refreshApex(this.wireEntityReferences);
	}

	handleReferenceInputChange(event) {
		this.newReferenceValue = event.target.value;
	}

	handleCreateReference() {
		createEntityReference({
			entityId: this.recordId,
			emrServerId: this.selectedRow.serverId,
			reference: this.newReferenceValue
		})
			.then(() => {
				this.showInputReferenceBox = false; // Hide the input box
				this.newReferenceValue = ""; // Clear the input value
				this.selectedServerNameReferenceAction = ""; // Clear the selected server name
				refreshApex(this.wireEntityReferences); // Refresh data
			})
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Success",
						message: "Reference created successfully",
						variant: "success"
					})
				);
			})
			.catch((error) => {
				this.error = error;
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error creating reference",
						message: error.body.message,
						variant: "error"
					})
				);
			});
	}

	handleCancelCreate() {
		this.showInputReferenceBox = false; // Hide the input box
		this.newReferenceValue = ""; // Clear the input value
		this.selectedServerNameReferenceAction = ""; // Clear the selected server name
	}
}
