/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Check Out Log Service Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* Makes use of the MockSetup Test Pattern to stub out the Domain used in the Controller.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-09
* @modified       2025-01-09
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BGCheckOutLogServiceTest {

    /**
     * List of possible params for the mock setup.
     * Done to allow dynamically providing params without having to update every 
     * single test class every time something changes.
     * Instructions for adding a new param type:
     * 1. Add to `MockParams` enum
     * 2. Add type to `paramTypes` property
     * 3. Use the new param in the `MockSetup` constructor
     */
    enum MockParams {
        RETURNED_BOARD_GAME_CHECK_OUT_LOG_FROM_DOMAIN
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_BOARD_GAME_CHECK_OUT_LOG_FROM_DOMAIN => List<BG_Checkout_Log__c>.class
            };
        }
    }

    class MockSetup {
        public fflib_ApexMocks mocks = new fflib_ApexMocks();
        public fflib_SobjectUnitOfWork uowMock;
        public Services_Config__mdt mockConfig;

        private MockSetup(Map<MockParams, Object> params) {
            //Loop through Map of ParamTypes
            //For Each MockParams Value, if the MockParams Value is NOT a key in the given Map Parameter
            //Add that MockParams Value to the given map with a new empty instance of the related Object Type
            for (MockParams param : paramTypes.keySet()) {
                if (!params.containsKey(param)) {
                    params.put(param, paramTypes.get(param).newInstance());
                }
            }

            //Initialize Class Variables and mocked classes
            mocks = new fflib_ApexMocks();
            uowMock = (fflib_SobjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            IBGCheckOutLogDomain mockBGCheckOutLogDomain = (IBGCheckOutLogDomain) mocks.mock(BGCheckOutLogDomain.class);

            mockConfig = new Services_Config__mdt(
                                        Domain_Config__r = new Domain_Config__mdt(
                                            DeveloperName = 'BGCheckOutLog'),
                                        Service_Enabled__c = true
                                    );
            
            mocks.startStubbing();
            //Stubbing the BG Check Out Log Domain
            // Stub out each Domain Method that the Domain calls
            mocks.when(mockBGCheckOutLogDomain.getType())
                .thenReturn(BG_Checkout_Log__c.SObjectType);
            mocks.when(mockBGCheckOutLogDomain.getChanged(fflib_Match.anyString()))
                .thenReturn((List<BG_Checkout_Log__c>) params.get(MockParams.RETURNED_BOARD_GAME_CHECK_OUT_LOG_FROM_DOMAIN));
            mocks.when(mockBGCheckOutLogDomain.getCompletedCheckOutLogs((List<BG_Checkout_Log__c>) fflib_Match.anyObject()))
                .thenReturn((List<BG_Checkout_Log__c>) params.get(MockParams.RETURNED_BOARD_GAME_CHECK_OUT_LOG_FROM_DOMAIN));

            mocks.stopStubbing();

            //Set the Domain Mock and UOW Mock created as the classes to be used when
            // the Domain and UOW Classes are initialized from the Application Layer instead of the normal classes
            Application.UnitOfWork.setMock(uowMock);
            Application.Domain.setMock(mockBGCheckOutLogDomain);
        }
    }

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    ////////////////////////////// Constructor Tests //////////////////////////////////////////    
    // Test Plan
    // Call Service using Current Config Record 
    @IsTest
    public static void givenCurrentServiceConfig_WhenServiceClassCalled_ThenCurrentServiceConfigReturned(){
        
        // Since we have no control over what the Services_Config settings might be, 
        // We are simply going to test the default public constructor and validate that a 
        // config file exists for our methods we are going to test

        Test.startTest();
        BGCheckOutLogService service = new BGCheckOutLogService();
        Test.stopTest(); 

        // Validate that serviceConfigMap not only contains values for the BGCheckOutLogService
        // But also contains a config record for each of the methods of the Service 
        Assert.areNotEqual(0, service.serviceConfigMap.size(), 'No Service Configs Found for BGCheckOutLogDomain');
        Assert.isTrue(service.serviceConfigMap.containsKey('setTotalCheckOutTime'), 'Service Config for setTotalCheckOutTime Method Not Found');
    }

    ////////////////////////////// setTotalCheckOutTime Tests ////////////////////////////////////////
        //Test Plan
        // Call setTotalCheckOutTime Service Method with Custom Config where Service Disabled
        // Call setTotalCheckOutTime With No Records Returned From Domain
        // Call setTotalCheckOutTime With Records Returned From Domain

        //Start Testing
        // Call setTotalCheckOutTime Service Method with Custom Config where Service Disabled
        @IsTest
        public static void givenServiceConfigWithServiceDisabled_WhenSetTotalCheckOutTimeCalled_ThenNothingHappens(){

            //Setup Test Data and Mocking
            BG_Checkout_Log__c testRecord = (BG_Checkout_Log__c) new sfab_FabricatedSObject(BG_Checkout_Log__c.class)
                                                                        .setField(BG_Checkout_Log__c.Id,
                                                                                    fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType))
                                                                        .setField(BG_Checkout_Log__c.Total_Check_Out_Time_Formula__c, 60) // Formula Field
                                                                    .toSObject();

            //Setup Return Values
            //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
            Map<MockParams, Object> params = new Map<MockParams, Object>();

            //Initialize MockSetup with Params 
            MockSetup mock = new MockSetup(params);
            
            //Customize Service Config Record
            mock.mockConfig.DeveloperName = 'setTotalCheckOutTime';
            mock.mockConfig.Service_Enabled__c = false;

            //Run Test
            Test.startTest();
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.setTotalCheckOutTime(new List<BG_Checkout_Log__c>{testRecord});
            Test.stopTest();

            //Validate Data
            Assert.areEqual(null, testRecord.Total_Check_Out_Time_Value__c, 'Value Was Updated');
        }

        // Call setTotalCheckOutTime With No Records Returned From Domain
        @IsTest
        public static void givenNoRecordsReturnedFromDomain_WhenSetTotalCheckOutTimeCalled_ThenNoUpdate(){
                    
            //Setup Test Data and Mocking
            BG_Checkout_Log__c testRecord = (BG_Checkout_Log__c) new sfab_FabricatedSObject(BG_Checkout_Log__c.class)
                                                                        .setField(BG_Checkout_Log__c.Id,
                                                                                    fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType))
                                                                        .setField(BG_Checkout_Log__c.Total_Check_Out_Time_Formula__c, 60) // Formula Field
                                                                    .toSObject();

            //Setup Return Values
            //By Not addeding Anything to the Params Map, the return value from the Domain will be an empty list
            Map<MockParams, Object> params = new Map<MockParams, Object>();

            //Initialize MockSetup with Params 
            MockSetup mock = new MockSetup(params);
            
            //Customize Service Config Record
            mock.mockConfig.DeveloperName = 'setTotalCheckOutTime';

            //Run Test
            Test.startTest();
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.setTotalCheckOutTime(new List<BG_Checkout_Log__c>{testRecord});
            Test.stopTest();

            //Validate Data
            Assert.areEqual(null, testRecord.Total_Check_Out_Time_Value__c, 'Value Was Updated');
        }

        // Call setTotalCheckOutTime With Records Returned From Domain
        @IsTest
        public static void givenRecordsReturnedFromDomain_WhenSetTotalCheckOutTimeCalled_ThenRecordUpdated(){
                    
            //Setup Test Data and Mocking
            // Using sfab_FabricatedSObject to generate Object as we need to Mock a Formula Field
            BG_Checkout_Log__c testRecord = (BG_Checkout_Log__c) new sfab_FabricatedSObject(BG_Checkout_Log__c.class)
                                                                        .setField(BG_Checkout_Log__c.Id,
                                                                                    fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType))
                                                                        .setField(BG_Checkout_Log__c.Total_Check_Out_Time_Formula__c, 60) // Formula Field
                                                                    .toSObject();


            //Setup Return Values
            Map<MockParams, Object> params = new Map<MockParams, Object>{
                MockParams.RETURNED_BOARD_GAME_CHECK_OUT_LOG_FROM_DOMAIN => new List<BG_Checkout_Log__c>{testRecord}
            };

            //Initialize MockSetup with Params 
            MockSetup mock = new MockSetup(params);
            
            //Customize Service Config Record
            mock.mockConfig.DeveloperName = 'setTotalCheckOutTime';

            //Run Test
            Test.startTest();
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.setTotalCheckOutTime(new List<BG_Checkout_Log__c>{testRecord});
            Test.stopTest();

            //Validate Data
            Assert.areEqual(testRecord.Total_Check_Out_Time_Formula__c, testRecord.Total_Check_Out_Time_Value__c, 'Value Was Not Updated');   
        }


    ////////////////////////////// End setTotalCheckOutTime Tests ////////////////////////////////////////

}