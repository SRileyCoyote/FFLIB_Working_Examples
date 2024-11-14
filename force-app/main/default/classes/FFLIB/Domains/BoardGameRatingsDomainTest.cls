@IsTest
public class BoardGameRatingsDomainTest {
    //Test Class just for the Board Game Rating Domain Class
    //Testing for actual Logic in the Triggers are tested in the Service Class Tests, 
    //so these are true Unit Tests to make sure that the Trigger and Domain Classes are working as intended

    //Create the MockSetup Class which we will use to handle all of our mocking and stubbing in our test methods 
    class MockSetup{

        public fflib_ApexMocks mocks = new fflib_ApexMocks();
        public fflib_SobjectUnitOfWork uowMock;
        public BoardGameRatingsDomain bgrDomain;
        
        // Constructor with Booleon if Errors Should be thrown
        private MockSetup(Boolean throwErrors){
            this(new Domain_Config__mdt(
                                Bypass_Trigger__c = false,
                                Bypass_Error_Handling__c = false,
                                Prevent_Recursion__c = false
                        ), throwErrors);
        }

        //Overloaded Constructor with Booleon if Errors Should be thrown as well as Config Settings for Domain 
        private MockSetup(Domain_Config__mdt config, Boolean throwErrors){
            
            mocks = new fflib_ApexMocks();
            bgrDomain = new BoardGameRatingsDomain(config, new List<Board_Game_Rating__c>()); //Initialize Domain with empty list
            
            //Initialize the Mocks
            uowMock = (fflib_SobjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            IBoardGameRatingsService mockBGRService = (IBoardGameRatingsService) mocks.mock(IBoardGameRatingsService.class);

            mocks.startStubbing();
            if(throwErrors){
                ((IBoardGameRatingsService) mocks.doThrowWhen(new BoardGameRatingsDomain.BRGDomainException('Thrown Exception'),
                                                mockBGRService)).setNewFavorite(
                                                                    (fflib_SObjectUnitOfWork) fflib_Match.anyObject(), 
                                                                    (List<SObject>) fflib_Match.anyObject(),
                                                                    (Map<Id,SObject>) fflib_Match.anyObject()
                                                                );
            }
            mocks.stopStubbing();

            //Whenever the BoardGameRatingsService is created using the Application Class, 
            //Replace that class and all of its methods with our Mock Service with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Service.setMock(IBoardGameRatingsService.class, mockBGRService); 
            Application.UnitOfWork.setMock(uowMock);
        }
    } 

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    // Test Plan
    // Call Domain with Current Config 
    // Call AfterUpdate Method with 1 BGR Record
    // Call AfterUpdate Method with Multiple BGR Records
    // Call AfterUpdate Method with No BGR Records
    // Call AfterUpdate Method with Custom Config where Recursion Disabled
    // Call Domain with Custom Config where Trigger Disabled 
    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Disabled
    // Call AfterUpdate and Throw Error with Custom Config where Bypass Triggers Enabled

    @IsTest
    public static void givenBGRRecord_WhenOnAfterUpdateIsCalled_ThenNoErrors(){

        //Initialize MockSetup with no Errors and Default Settings on Config File
        MockSetup mock = new MockSetup(false);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };

        Test.startTest();
            mock.bgrDomain.onAfterUpdate(existingRecords);
        Test.stopTest();

        //Validate Method finished and Service Not Called
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1)).commitWork();
    }

    @IsTest
    public static void givenConifigWithPreventRecursionEnabled_WhenOnAfterUpdateIsCalled_ThenOnAfterUpdateMethodsDisabled(){
        
        //Initialize MockSetup with no Errors and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = false,
                                        Prevent_Recursion__c = true
                                    );
        MockSetup mock = new MockSetup(config, false);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };

        Test.startTest();
            mock.bgrDomain.onAfterUpdate(existingRecords);
        Test.stopTest();

        //Validate After Update Trigger is Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).AfterUpdateEnabled, 'After Update Was Not Disabled');
    }

    @IsTest
    public static void givenConifigWithDisableTriggersEnabled_WhenDomainInitialized_ThenTriggerDisabled(){

        //Initialize MockSetup with no Errors and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
            Bypass_Trigger__c = true,
            Bypass_Error_Handling__c = false,
            Prevent_Recursion__c = false
        );
        

        Test.startTest();
            MockSetup mock = new MockSetup(config, false);
        Test.stopTest();

        //Validate Triggers are Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).AfterUpdateEnabled, 'After Update Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).AfterInsertEnabled, 'After Insert Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).BeforeUpdateEnabled, 'Before Update Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).BeforeInsertEnabled, 'Before Insert Was Not Disabled');

    }

    @IsTest
    public static void givenConifigWithByPassErrorHandlingDisabled_WhenErrorOccurs_ThenErrorThrown(){

        //Initialize MockSetup with no Errors and Default Settings on Config File
        MockSetup mock = new MockSetup(true);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };

        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.bgrDomain.onAfterUpdate(existingRecords);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Correct Error Was Thrown
        Assert.areEqual(errMsg, 'An Error Occured in the Board Game Ratings Domain: Thrown Exception', 'Error Message Recieved: '+ errMsg);

    }

    @IsTest
    public static void givenConifigWithByPassErrorHandlingEnabled_WhenErrorOccurs_ThenErrorBypassed(){

        //Initialize MockSetup with no Errors and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = true,
                                        Prevent_Recursion__c = false
                                    );
        MockSetup mock = new MockSetup(config, true);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID bgrID = fflib_IdGenerator.generate(Board_Game_Rating__c.sobjectType);
        Map<ID, Board_Game_Rating__c> existingRecords = new Map<ID, Board_Game_Rating__c>{
                                                                bgrID => new Board_Game_Rating__c( ID = bgrID )                      
                                                        };

        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.bgrDomain.onAfterUpdate(existingRecords);
            Assert.isTrue(true, 'Error Thrown');
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate After Update Trigger is Disabled
        Assert.areNotEqual(errMsg, 'An Error Occured in the Board Game Ratings Domain: Thrown Exception', 'Error Message Recieved: '+ errMsg);

    }
}