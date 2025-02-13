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
* @modified       2025-02-13
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BGCheckOutLogServiceTest {

    //#region Setup
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
    //#endregion
    
    // Begin Tests
    // Tests should follow a Use Case Test Plan

    //#region //////////////////////////// Constructor Tests //////////////////////////////////////////    
    // Test Plan
    // Call New Instance
    @IsTest
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IBGCheckOutLogService result = BGCheckOutLogService.newInstance();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return instance');
    }

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
        Assert.isTrue(service.serviceConfigMap.containsKey('createCheckOutLog'), 'Service Config for createCheckOutLog Method Not Found');
        Assert.isTrue(service.serviceConfigMap.containsKey('updateCheckOutLog'), 'Service Config for updateCheckOutLog Method Not Found');
    }
    //#endregion 
    //#region //////////////////////////// setTotalCheckOutTime Tests ////////////////////////////////////////
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


    //#endregion
    //#region //////////////////////////// createCheckOutLog Tests ////////////////////////////////////////
    //Test Plan
    // Call createCheckOutLog Service Method with Custom Config where Service Disableds
    // BGLE ID is Null
    // BGLE is not correct Type
    // Attendee ID is Null
    // Attendee ID is not Correct Type
    // Check Out Time is null
    // Check Out Time is in future
    // All Correct Inputs
    
    // Call createCheckOutLog Service Method with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test
        
        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = false;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, null, null, null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.SERVICE_NOT_ENABLED_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }
    
    // BGLE ID is Null
    @IsTest
    public static void givenMissingBGLEId_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, null, null, null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_BGLE_ID_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // BGLE is not correct Type
    @IsTest
    public static void givenInvalidBGLEId_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, 
                                        fflib_IDGenerator.generate(Account.SObjectType), 
                                        null, 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_BGLE_ID_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Attendee ID is Null
    @IsTest
    public static void givenMissingAttendeeId_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, 
                                        fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 
                                        null, 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_ATTENDEE_ID_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Attendee ID is not Correct Type
    @IsTest
    public static void givenInvalidAttendeeId_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, 
                                        fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 
                                        fflib_IDGenerator.generate(Account.SObjectType), 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_ATTENDEE_ID_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }
    
    // Check Out Time is null
    @IsTest
    public static void givenMissingCheckOutTime_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, 
                                        fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 
                                        fflib_IDGenerator.generate(Event_Attendee__c.SObjectType), 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_CHK_OUT_TIME_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Check Out Time is in future
    @IsTest
    public static void givenFutureCheckOutTime_WhenCreateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.createCheckOutLog(mock.uowMock, 
                                        fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 
                                        fflib_IDGenerator.generate(Event_Attendee__c.SObjectType), 
                                        System.now().addDays(1));
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.FUTURE_CHK_OUT_TIME_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // All Correct Inputs
    @IsTest
    public static void givenCorrectInputs_WhenCreateCheckOutLogCalled_ThenInsertLogRecord(){

        //Setup Test Data and Mocking
        Id bgleId = fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType); 
        Id attendeeID = fflib_IDGenerator.generate(Event_Attendee__c.SObjectType); 
        Datetime now = System.now();

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'createCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
        service.createCheckOutLog(mock.uowMock, 
                                    bgleId, 
                                    attendeeID, 
                                    now);
        Test.stopTest();

        //Verify that UOW Register New Ran Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.anySObject());

        //Verify that UOW RegisterNew Ran Only Once
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerNew(fflib_Match.sObjectWith(
            new Map<Schema.SObjectField, Object>{
                //Validate Record in Register New is a new Record 
                //And that the Values Set match the values given
                BG_Checkout_Log__c.Checked_Out_By__c => attendeeID,
                BG_Checkout_Log__c.BG_Library_Entry__c => bgleId,
                BG_Checkout_Log__c.Check_Out_Time__c => now
            }
        ));
    }


    //#endregion
    //#region //////////////////////////// updateCheckOutLog Tests ////////////////////////////////////////
    //Test Plan
    // Call updateCheckOutLog Service Method with Custom Config where Service Disabled
    // Log is Null
    // Log ID is Null
    // Check In Time is null
    // Check In Time is before Check Out Time
    // All Correct Inputs
    
    // Call updateCheckOutLog Service Method with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenUpdateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateCheckOutLog';
        mock.mockConfig.Service_Enabled__c = false;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.updateCheckOutLog(mock.uowMock, new BG_Checkout_Log__c(), null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.SERVICE_NOT_ENABLED_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Log is Null
    @IsTest
    public static void givenMissingLog_WhenUpdateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.updateCheckOutLog(mock.uowMock, 
                                        null, 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_LOG_ID_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Log ID is Null
    @IsTest
    public static void givenMissingLogId_WhenUpdateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.updateCheckOutLog(mock.uowMock, 
                                        new BG_Checkout_Log__c(), 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_LOG_ID_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Check In Time is null
    @IsTest
    public static void givenMissingChkInTime_WhenUpdateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.updateCheckOutLog(mock.uowMock, 
                                        new BG_Checkout_Log__c(ID = fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType)), 
                                        null);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.NO_CHK_IN_TIME_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // Check In Time is before Check Out Time
    @IsTest
    public static void givenChkInTimeBeforeChkOutTime_WhenUpdateCheckOutLogCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        // No Test Data Needed For this Test

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.updateCheckOutLog(mock.uowMock, 
                                        new BG_Checkout_Log__c(ID = fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType),
                                                                Check_Out_Time__c = System.now()), 
                                        System.now().addDays(-1));
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(errMsg, BGCheckOutLogService.INVALID_CHK_IN_TIME_ERR_MSG, 'Error Message Not What was Expected: '+ errMsg);
    }

    // All Correct Inputs
    @IsTest
    public static void givenCorrectInputs_WhenUpdateCheckOutLogCalled_ThenUpdateLogRecord(){

        //Setup Test Data and Mocking
        BG_Checkout_Log__c testLog = new BG_Checkout_Log__c(
                                            ID = fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType),
                                            Check_Out_Time__c = System.now().addDays(-1)
                                        );
        Datetime now = System.now();

        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an empty list
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateCheckOutLog';
        mock.mockConfig.Service_Enabled__c = true;

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try{
            BGCheckOutLogService service = new BGCheckOutLogService(new List<Services_Config__mdt>{mock.mockConfig});
            service.updateCheckOutLog(mock.uowMock, 
                                        testLog,
                                        now);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        //Verify that UOW RegisterDirty Ran Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.anySObject());

        //Verify that UOW RegisterNew Ran Only Once
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerDirty(fflib_Match.sObjectWith(
            new Map<Schema.SObjectField, Object>{
                //Validate Record in Register New is a new Record 
                //And that the Values Set match the values given
                BG_Checkout_Log__c.Id => testLog.Id,
                BG_Checkout_Log__c.Check_In_Time__c => now
            }
        ));
    }    
    //#endregion
}