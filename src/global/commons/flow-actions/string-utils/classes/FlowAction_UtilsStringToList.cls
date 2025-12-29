/**
 * @description       : Flow Action Utils - Function to allow to split text strigns into a list of strings using a separator.
 * @author            : Ivo Rocha
 * @testSuite        :
 * @testClass        : FlowAction_UtilsStringToList_Test
 **/
public without sharing class FlowAction_UtilsStringToList {
	@InvocableMethod(
		category='String utils'
		label='Split String into a List of Strings'
		description='Split String into List of String using a defined separator.'
		iconName='slds:custom:custom83'
	)
	public static List<List<String>> splitText(List<SplitRequest> splitRequests) {
		List<List<String>> outputs = new List<List<String>>();
		for (SplitRequest splitRequest : splitRequests) {
			outputs.add(splitRequest.getOutput());
		}
		return outputs;
	}

	public class SplitRequest {
		@InvocableVariable(
			required=false
			label='Text'
			description='Text to be splitted.'
		) //Non-Required so that null values can be passed, even though nothing will be done in that case.
		public String text;

		@InvocableVariable(required=true label='Split by' description='Character or word to split the text by.')
		public String splitBy;

		public SplitRequest() {
		}

		public SplitRequest(String text, String splitBy) {
			this.text = text;
			this.splitBy = splitBy;
		}

		public List<String> getOutput() {
			if (String.isBlank(this.text)) {
				return new List<String>();
			}
			return this.text.split(this.splitBy);
		}
	}
}
