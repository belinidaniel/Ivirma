/**
 * @description  : Test class for the Artemis Providers Client implementation.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
private class ArtemisProvidersClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldGetProvider() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisProviderRestModel provider = ArtemisRestClientTest.getTestRestClientInstance().providers.getProvider('1234');
		Test.stopTest();

		Assert.isNotNull(provider, 'Provider should not be null');
		Assert.isNotNull(provider.id, 'Provider id should not be empty');
	}

	@isTest
	static void shouldFailGettingProviderWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().providers.getProvider(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldGetProviders() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		List<ArtemisProviderRestModel> providers = ArtemisRestClientTest.getTestRestClientInstance().providers.getProviders();
		Test.stopTest();

		Assert.isNotNull(providers, 'Providers should not be null');
		Assert.isTrue(providers.size() > 0, 'Providers should not be empty');
		Assert.isNotNull(providers[0].id, 'First provider id should not be empty');
	}

	@isTest
	static void shouldFindProvider() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		Map<String, Object> params = new Map<String, Object>{ 'npi' => '1234567890' };
		ArtemisProviderRestModel provider = ArtemisRestClientTest.getTestRestClientInstance().providers.findProvider(params);
		Test.stopTest();

		Assert.isNotNull(provider, 'Provider should have been found');
		Assert.isNotNull(provider.id, 'Provider id should not be empty');
		Assert.isNotNull(provider.npi, 'Provider npi should not be empty');
	}

	@isTest
	static void shouldFailFindingProviderWithoutNpi() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			Map<String, Object> params = new Map<String, Object>();
			ArtemisRestClientTest.getTestRestClientInstance().providers.findProvider(params);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}
}
