import { LightningElement, api, wire } from "lwc";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

import IS_PERSON_ACCOUNT_FIELD from "@salesforce/schema/Account.IsPersonAccount";
import ScreenFlowModal from "c/screenFlowModal";

export default class PatientProfilesTabset extends LightningElement {
	@api recordId;

	selectedTabId = "new";
	profileServerRecords = null;
	_wirePatientServerProfileRecordsRef = null;

	@wire(getRecord, { recordId: "$recordId", fields: [IS_PERSON_ACCOUNT_FIELD] })
	account;

	@wire(getRelatedListRecords, {
		parentRecordId: "$recordId",
		relatedListId: "PatientServerProfiles__r",
		fields: ["PatientServerProfile__c.EmrServer__r.Name"],
		sortBy: ["PatientServerProfile__c.CreatedDate"]
	})
	loadPatientServerProfileRecords(response) {
		this._wirePatientServerProfileRecordsRef = response;

		const { error, data } = response;
		if (data) {
			//console.log("data", data);
			this.profileServerRecords = data.records;
			this.selectedTabId = this.profileServerRecords.length > 0 ? this.profileServerRecords[0].id : "new";
		} else if (error) {
			//console.log("error", error);
		}
	}

	async handleCreateSyncClick(ev) {
		await ScreenFlowModal.open({
			label: "New Patient Server Profile",
			flowName: "ScreenFlow_NewPatientServerProfileRecord",
			inputVariables: [
				{
					name: "recordId",
					type: "String",
					value: this.recordId
				}
			]
		});

		refreshApex(this._wirePatientServerProfileRecordsRef);
	}

	get hasLoadedData() {
		return this.account && this.profileServerRecords;
	}

	get hasServerProfiles() {
		return this.profileServerRecords && this.profileServerRecords.length > 0;
	}

	get isPersonAccount() {
		return getFieldValue(this.account.data, IS_PERSON_ACCOUNT_FIELD);
	}
}
