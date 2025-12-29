import { LightningElement, api } from "lwc";
import geMetadataReferralSources from "@salesforce/apex/LwcArtemisRefSourcesPickerController.geMetadataReferralSources";
import getPractitioners from "@salesforce/apex/LwcArtemisRefSourcesPickerController.getPractitioners";

export default class ArtemisReferralSourcePicker extends LightningElement {
	@api
	emrServerId;
	@api
	displayReferenceIds = false;
	@api
	selectedRecordId; //Output field. Either this refsource metadata record id or a selectedRefCategory with selectedRefPersonId
	@api
	selectedRefCategory;
	@api
	selectedRefPersonId;
	@api
	required = false;
	@api
	requiredMessage = "Please select a referral source.";

	selectedCategoryId = null;
	_categories = [];
	_referralSourcesByCategoryId = new Map();

	async connectedCallback() {
		if (!this.emrServerId) {
			console.error("emrServerId not provided");
			return;
		}

		await this.fetchReferralSources();
		await this.fetchPractitioners();
	}

	async fetchReferralSources() {
		const referralSources = await geMetadataReferralSources({ emrServerId: this.emrServerId });
		const uniqueCategoryIds = new Set(referralSources.map((referralSource) => referralSource.ReferralCategoryInternalId__c));
		const categoryNames = new Map(
			referralSources.map((referralSource) => [referralSource.ReferralCategoryInternalId__c, referralSource.ReferralCategory__c])
		);
		this._categories = Array.from(uniqueCategoryIds).map((categoryId) => ({
			label: categoryNames.get(categoryId),
			value: categoryId,
			description: this.displayReferenceIds ? "Category Id: " + categoryId : null
		}));

		//Group the referral sources by category
		this._referralSourcesByCategoryId = referralSources.reduce((accumulator, currentRefSource) => {
			// Check if the category ID already exists in the map
			const categoryId = currentRefSource.ReferralCategoryInternalId__c;
			if (!accumulator.has(categoryId)) {
				accumulator.set(categoryId, {
					categoryId: categoryId,
					referralSources: []
				});
			}
			// Add the current referral source to the appropriate category
			accumulator.get(categoryId).referralSources.push({
				label: currentRefSource.ReferredBy__c,
				value: currentRefSource.Id,
				description: this.displayReferenceIds ? "Referral Source Id: " + currentRefSource.ReferralSourceInternalId__c : null
			});
			return accumulator;
		}, new Map());
	}

	async fetchPractitioners() {
		const practitioners = await getPractitioners({ emrServerId: this.emrServerId });
		const practitionersAsReferralSourcesFormat = practitioners.map((practitioner) => {
			// Use the practitioner name and account name as the label
			const labelItems = [];
			if (practitioner.Name) {
				labelItems.push(practitioner.Name);
			}
			if (practitioner.Account__r?.Name) {
				labelItems.push(practitioner.Account__r.Name);
			}
			if (practitioner.Email) {
				labelItems.push(practitioner.Email);
			}

			return {
				label: labelItems.join(" · "),
				value: practitioner.Id,
				description: this.displayReferenceIds ? "Practitioner id: " + practitioner.Id : null
			};
		});

		if (practitionersAsReferralSourcesFormat.length === 0) {
			return;
		}
		return;
		// Add the practitioners to the categories
		this._categories = [
			{
				label: "Doctor_Non OBGYN",
				value: "Doctor_Non OBGYN"
			},
			{
				label: "Doctor_OBGYN",
				value: "Doctor_OBGYN"
			},
			{
				label: "Acupuncturist",
				value: "Acupuncturist"
			}
		].concat(this._categories);

		this._referralSourcesByCategoryId.set("Doctor_OBGYN", {
			categoryId: "Doctor_OBGYN",
			referralSources: practitionersAsReferralSourcesFormat
		});
		this._referralSourcesByCategoryId.set("Doctor_Non OBGYN", {
			categoryId: "Doctor_Non OBGYN",
			referralSources: practitionersAsReferralSourcesFormat
		});
		this._referralSourcesByCategoryId.set("Acupuncturist", {
			categoryId: "Acupuncturist",
			referralSources: practitionersAsReferralSourcesFormat
		});
	}

	get categories() {
		return this._categories;
	}

	get referralSourcesForSelectedCategory() {
		const selectedCategoryId = this.selectedCategoryId;
		return selectedCategoryId ? this._referralSourcesByCategoryId.get(selectedCategoryId)?.referralSources || [] : [];
	}

	get disabledReferralBySelection() {
		debugger;
		const selectedCategoryId = this.selectedCategoryId;
		return (
			selectedCategoryId == null ||
			!this._referralSourcesByCategoryId.has(selectedCategoryId) ||
			this._referralSourcesByCategoryId.get(selectedCategoryId).referralSources.length === 0
		);
	}

	handleChangeSelectedCategory(event) {
		this.selectedCategoryId = event.detail.value;
		if (this.selectedCategoryId == "Doctor_Non OBGYN" || this.selectedCategoryId == "Doctor_OBGYN" || this.selectedCategoryId == "Acupuncturist") {
			this.selectedRefCategory = event.detail.value;
		} else {
			this.selectedRefCategory = null;
		}

		//if there is a ref source with an empty label, select that by default
		const defaultReferralSource = this._referralSourcesByCategoryId
			.get(this.selectedCategoryId)
			?.referralSources.find((referralSource) => !referralSource.label);
		this.selectedRecordId = defaultReferralSource ? defaultReferralSource.value : null;
	}

	handleChangeSelectedReferralSource(event) {
		this.selectedRecordId = event.detail.value;
		if (this.selectedRefCategory != null) {
			this.selectedRefPersonId = event.detail.value;
		} else {
			this.selectedRefPersonId = null;
		}
	}

	@api validate() {
		if (this.required && (!this.selectedRecordId || (this.selectedRefCategory && !this.selectedRefPersonId))) {
			return {
				isValid: false,
				errorMessage: this.requiredMessage
			};
		}

		return {
			isValid: true,
			errorMessage: null
		};
	}
}
