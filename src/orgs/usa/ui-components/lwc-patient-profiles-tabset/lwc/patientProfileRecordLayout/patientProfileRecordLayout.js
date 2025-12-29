import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getLayout } from "lightning/uiLayoutApi";

export default class PatientProfileRecordLayout extends NavigationMixin(LightningElement) {
	@api recordId;
	@api defaultMode = "view"; // Either "view" or "edit"

	layoutViewModeMetadata;
	layoutEditModeMetadata;
	inEditMode = false;
	isSaving = false;
	isLoading = true; //applicable to the record view form

	connectedCallback() {
		if (this.defaultMode == "edit") {
			this.inEditMode = true;
			this.isLoading = false;
		}
	}

	@wire(getLayout, { objectApiName: "PatientServerProfile__c", layoutType: "Full", mode: "View" })
	loadLayoutViewModeMetadata({ error, data }) {
		if (data) {
			//console.log("layoutViewModeMetadata", data);
			this.layoutViewModeMetadata = data;
		} else if (error) {
			console.log("error", error);
		}
	}

	@wire(getLayout, { objectApiName: "PatientServerProfile__c", layoutType: "Full", mode: "Edit" })
	loadLayoutEditModeMetadata({ error, data }) {
		if (data) {
			//console.log("layoutEditModeMetadata", data);
			this.layoutEditModeMetadata = data;
		} else if (error) {
			console.log("error", error);
		}
	}

	get hasLoadedLayoutMetadata() {
		return this.layoutViewModeMetadata && this.layoutEditModeMetadata;
	}

	handleEditRecordClick() {
		this.inEditMode = true;
	}

	handleEditCancelClick() {
		const inputFields = this.template.querySelectorAll("lightning-input-field");
		if (inputFields) {
			inputFields.forEach((field) => {
				field.reset();
			});
		}
		this.inEditMode = false;
	}

	handleEditSubmit() {
		this.isSaving = true;
	}

	handleEditSuccess() {
		this.inEditMode = false;
		this.isSaving = false;
	}

	handleEditError() {
		this.isSaving = false;
	}

	handleRecordViewLoad() {
		this.isLoading = false;
	}

	handleOnselectHeaderAction(event) {
		switch (event.detail.value) {
			case "view-history":
				this[NavigationMixin.Navigate]({
					type: "standard__recordRelationshipPage",
					attributes: {
						recordId: this.recordId,
						objectApiName: "PatientServerProfile__c",
						relationshipApiName: "Histories",
						actionName: "view"
					}
				});
				break;
			case "refresh":
				// TODO
				break;
			case "force-pull":
				// TODO
				break;
			case "force-push":
				// TODO
				break;
			case "compare":
				// TODO
				break;
		}
	}
}
