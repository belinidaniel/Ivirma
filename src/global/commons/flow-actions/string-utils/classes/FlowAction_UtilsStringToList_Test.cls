/**
 * @description       : Test class for FlowAction_UtilsStringToList
 * @author            : Ivo Rocha
 * @testSuite        :
 * @testClass        :
 **/
@isTest
private class FlowAction_UtilsStringToList_Test {
	@isTest
	static void shouldSplit() {
		Test.startTest();
		List<FlowAction_UtilsStringToList.SplitRequest> flowSplitRequests = new List<FlowAction_UtilsStringToList.SplitRequest>();
		flowSplitRequests.add(new FlowAction_UtilsStringToList.SplitRequest('text1,text2,text3', ','));
		flowSplitRequests.add(new FlowAction_UtilsStringToList.SplitRequest('string1;string2;string3;string4', ';'));

		List<List<String>> outputs = FlowAction_UtilsStringToList.splitText(flowSplitRequests);

		System.assertEquals(3, outputs[0].size());
		System.assertEquals('text1', outputs[0][0]);
		System.assertEquals('text2', outputs[0][1]);
		System.assertEquals('text3', outputs[0][2]);

		System.assertEquals(4, outputs[1].size());
		System.assertEquals('string1', outputs[1][0]);
		System.assertEquals('string2', outputs[1][1]);
		System.assertEquals('string3', outputs[1][2]);
		System.assertEquals('string4', outputs[1][3]);
		Test.stopTest();
	}
}
