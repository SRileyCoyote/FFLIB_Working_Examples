/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Rating Trigger Handler Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* Testing for actual Logic in the Triggers are tested in the Service and Domain Class Tests so
* these are true Unit Tests to make sure that the Trigger Class is working as intended
*
* Makes use of the MockSetup Test Pattern to stub out the Service used in the Handler.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2024-12-21
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@IsTest
public class BoardGameRatingsTriggerHandlerTest {

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
        RETURNED_VALUE
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                // No Methods in the TriggerHander have any return values that need to
                // be mocked. Leaving these here in case needed in the futrue  
            };
        }
    }

    class MockSetup{

        public fflib_ApexMocks mocks = new fflib_ApexMocks();
        public fflib_SObjectUnitOfWork uowMock;
        public BoardGameRatingsTriggerHandler triggerHandler;
        
        // Constructor with Booleon if Errors Should be thrown
        private MockSetup(Map<MockParams, Object> params, Boolean throwErrors){
            this(params, new Domain_Config__mdt(
                                Bypass_Trigger__c = false,
                                Bypass_Error_Handling__c = false,
                                Prevent_Recursion__c = false
                        ), throwErrors);
        }

        //Overloaded Constructor with Booleon if Errors Should be thrown as well as Config Settings for TriggerHandler 
        private MockSetup(Map<MockParams, Object> params, Domain_Config__mdt config, Boolean throwErrors){
            
            //Loop through Map of ParamTypes
            //For Each MockParams Value, if the MockParams Value is NOT a key in the given Map Parameter
            //Add that MockParams Value to the given map with a new empty instance of the related Object Type
            for (MockParams param : paramTypes.keySet()) {
                if (!params.containsKey(param)) {
                    params.put(param, paramTypes.get(param).newInstance());
                }
            }

            mocks = new fflib_ApexMocks();
            
            //Initialize the Mocks
            uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            IBoardGameRatingsService mockBGRService = (IBoardGameRatingsService) mocks.mock(BoardGameRatingsService.class);

            mocks.startStubbing();
            //Stubbing the BGR Service
            // If we want to throw errors, stub out the Set New Favorite Methods to throw an error when called
            if(throwErrors){
                ((IBoardGameRatingsService) mocks.doThrowWhen(new BoardGameRatingsTriggerHandler.BRGTriggerHandlerException('Thrown Exception'),
                                                mockBGRService)).setNewFavorite(
                                                                    (fflib_SObjectUnitOfWork) fflib_Match.anyObject(), 
                                                                    (List<Board_Game_Rating__c>) fflib_Match.anyObject()
                                                                );
                ((IBoardGameRatingsService) mocks.doThrowWhen(new BoardGameRatingsTriggerHandler.BRGTriggerHandlerException('Thrown Exception'),
                                                mockBGRService)).setNewFavorite(
                                                                    (fflib_SObjectUnitOfWork) fflib_Match.anyObject(), 
                                                                    (List<Board_Game_Rating__c>) fflib_Match.anyObject(),
                                                                    (Map<Id, SObject>) fflib_Match.anyObject()
                                                                );
            }
            mocks.stopStubbing();

            //Whenever the BoardGameRatingsService or UnitOfWork is created using the Application Class, 
            //Replace those class and all of their methods with our Mock Service with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Service.setMock(IBoardGameRatingsService.class, mockBGRService); 
            Application.UnitOfWork.setMock(uowMock);

            //Initialize Trigger Handler with empty list
            //Do this last so that mocks are applied
            triggerHandler = new BoardGameRatingsTriggerHandler(config, new List<Board_Game_Rating__c>()); 
        }
    } 

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    // Test Plan
    // Call Constructor Class 
    // Call TriggerHandler with Current Config 
    // Call AfterUpdate Method with BGR Record
    // Call AfterInsert Method with BGR Record
    // Call AfterUpdate Method with Custom Config where Recursion Disabled
    // Call AfterInsert Method with Custom Config where Recursion Disabled
    // Call TriggerHandler with Custom Config where Trigger Disabled 
    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Disabled
    // Call AfterInsert and Throw Error with Custom Config where Bypass Triggers Disabled
    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Enabled
    // Call AfterInsert and Throw Error with Custom Config where Bypass Triggers Enabled

    // Call Constructor Class
    @isTest
    public static void givenListOfRecords_WhenConstructorClassCalled_ThenReturnsCorrectNumberOfRecords(){
        List<Board_Game_Rating__c> records = new List<Board_Game_Rating__c>{new Board_Game_Rating__c()};
        BoardGameRatingsTriggerHandler.Constructor constructor = new BoardGameRatingsTriggerHandler.Constructor();
        BoardGameRatingsTriggerHandler handler = (BoardGameRatingsTriggerHandler) constructor.construct(records);
        
        Assert.areEqual(records.size(), handler.getRecords().size(), 'Number of Records Match');
    } 

    // Call TriggerHandler with Current Config 
    @IsTest
    public static void givenNothing_WhenTriggerHandlerInitialized_ThenUseCurrentConfigMDT(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, false);
        
        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        List<Board_Game_Rating__c> testRecords = new List<Board_Game_Rating__c>{
            new Board_Game_Rating__c(Id = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType))
        };

        Test.startTest();
            BoardGameRatingsTriggerHandler triggerhandler = new BoardGameRatingsTriggerHandler(testRecords);
        Test.stopTest();

        //Validate Current Config Record was Used
        Assert.areEqual('BoardGameRatings', triggerhandler.domainConfig.DeveloperName, 'Dev Name for Config File Does not match');
    }

    // Call AfterUpdate Method with BGR Record    
    @IsTest
    public static void givenBGRRecord_WhenOnAfterUpdateIsCalled_ThenNoErrors(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, false);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };

        Test.startTest();
            mock.triggerHandler.onAfterUpdate(existingRecords);
        Test.stopTest();

        //Validate Method finished and Service Not Called
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1)).commitWork();
    }

    // Call AfterInsert Method with BGR Record    
    @IsTest
    public static void givenBGRRecord_WhenOnAfterInsertIsCalled_ThenNoErrors(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, false);

        // Create Test Data
        //No Additional Test Data Needed

        Test.startTest();
            mock.triggerHandler.onAfterInsert();
        Test.stopTest();

        //Validate Method finished and Service Not Called
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1)).commitWork();
    }

    // Call AfterUpdate Method with Custom Config where Recursion Disabled
    @IsTest
    public static void givenConifigWithPreventRecursionEnabled_WhenOnAfterUpdateIsCalled_ThenOnAfterUpdateMethodsDisabled(){
        
        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = false,
                                        Prevent_Recursion__c = true
                                    );
        MockSetup mock = new MockSetup(params, config, false);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };

        Test.startTest();
            mock.triggerHandler.onAfterUpdate(existingRecords);
        Test.stopTest();

        //Validate After Update Trigger is Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).AfterUpdateEnabled, 'After Update Was Not Disabled');
    }

    // Call AfterInsert Method with Custom Config where Recursion Disabled
    @IsTest
    public static void givenConifigWithPreventRecursionEnabled_WhenOnAfterInsertIsCalled_ThenOnAfterInsertMethodsDisabled(){
        
        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = false,
                                        Prevent_Recursion__c = true
                                    );
        MockSetup mock = new MockSetup(params, config, false);

        // Create Test Data
        //No Additional Test Data Needed

        Test.startTest();
            mock.triggerHandler.onAfterInsert();
        Test.stopTest();

        //Validate After Update Trigger is Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).AfterInsertEnabled, 'After Insert Was Not Disabled');
    }


    // Call TriggerHandler with Custom Config where Trigger Disabled 
    @IsTest
    public static void givenConifigWithDisableTriggersEnabled_WhenTriggerHandlerInitialized_ThenTriggerDisabled(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
            Bypass_Trigger__c = true,
            Bypass_Error_Handling__c = false,
            Prevent_Recursion__c = false
        );
        

        Test.startTest();
            MockSetup mock = new MockSetup(params, config, false);
        Test.stopTest();

        //Validate Triggers are Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).AfterUpdateEnabled, 'After Update Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).AfterInsertEnabled, 'After Insert Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).BeforeUpdateEnabled, 'Before Update Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).BeforeInsertEnabled, 'Before Insert Was Not Disabled');
    }

    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Disabled
    @IsTest
    public static void givenConifigWithByPassErrorHandlingDisabled_WhenAfterUpdateErrorOccurs_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();
        
        //Initialize MockSetup with params, Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, true);

        
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onAfterUpdate(existingRecords);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Correct Error Was Thrown
        Assert.areEqual(String.format(mock.triggerHandler.ERR_MESSAGE, new String[]{'After Update', 'Thrown Exception'}), errMsg, 'Error Message Recieved: '+ errMsg);
    }

    // Call AfterInsert and Throw Error with Custom Config where Bypass Triggers Disabled
    @IsTest
    public static void givenConifigWithByPassErrorHandlingDisabled_WhenAfterInsertErrorOccurs_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Create Test Data
        // No Additional Test Data Needed
                                           
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();
        
        //Initialize MockSetup with params, Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, true);

        
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onAfterInsert();
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Correct Error Was Thrown
        Assert.areEqual(String.format(mock.triggerHandler.ERR_MESSAGE, new String[]{'After Insert', 'Thrown Exception'}), errMsg, 'Error Message Recieved: '+ errMsg);
    }

    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Enabled
    @IsTest
    public static void givenConifigWithByPassErrorHandlingEnabled_WhenAfterUpdateErrorOccurs_ThenErrorBypassed(){

        //Setup Test Data and Mocking
        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Setup Custom Config
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = true,
                                        Prevent_Recursion__c = false
                                    );

        //Initialize MockSetup with params, Dont Throw Errors, and Given Settings on Config File
        MockSetup mock = new MockSetup(params, config, true);

        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onAfterUpdate(existingRecords);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate After Update Trigger is Disabled
        Assert.areEqual('No Errors', errMsg, 'Error Message Recieved: '+ errMsg);
    }

    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Enabled
    @IsTest
    public static void givenConifigWithByPassErrorHandlingEnabled_WhenAfterInsertErrorOccurs_ThenErrorBypassed(){

        //Setup Test Data and Mocking
        // Create Test Data
        // No Additional Test Data Needed

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Setup Custom Config
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = true,
                                        Prevent_Recursion__c = false
                                    );

        //Initialize MockSetup with params, Dont Throw Errors, and Given Settings on Config File
        MockSetup mock = new MockSetup(params, config, true);

        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onAfterInsert();
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate After Update Trigger is Disabled
        Assert.areEqual('No Errors', errMsg, 'Error Message Recieved: '+ errMsg);
    }
}