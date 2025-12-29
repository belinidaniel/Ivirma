import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContactReferences from "@salesforce/apex/LwcArtemisContactRefsStatusController.getContactReferences";

export default class ArtemisContactReferencesStatus extends LightningElement {
	@api recordId;
	@api componentTitle = "Artemis Contact References";
	@api componentIcon = "custom:custom14";

	columns = [
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
		{ label: "Int", fieldName: "identifier", sortable: false, hideDefaultActions: true },
		{ label: "Ext", fieldName: "practitionerIdentifier", sortable: false, hideDefaultActions: true },
		{ label: "Ref", fieldName: "referralIdentifier", sortable: false, hideDefaultActions: true },
		{
			label: "Last sync",
			fieldName: "lastSync",
			type: "date",
			typeAttributes: { day: "numeric", month: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit" },
			sortable: false,
			hideDefaultActions: true
		}
		// {
		// 	type: "action",
		// 	typeAttributes: { rowActions: this.getRowActions }
		// }
	];

	contactReferences = [];
	wireContactReferences;
	error;

	@wire(getContactReferences, { contactId: "$recordId" })
	wiredContactReferences(wiredReference) {
		this.wireContactReferences = wiredReference; // Store the wire reference for refresh
		const { data, error } = wiredReference;
		if (data) {
			this.contactReferences = data;
			this.error = undefined;
		} else if (error) {
			this.error = error;
			this.contactReferences = [];
		}
	}

	handleRefreshButtonClick() {
		refreshApex(this.wireEntityReferences);
	}
}
