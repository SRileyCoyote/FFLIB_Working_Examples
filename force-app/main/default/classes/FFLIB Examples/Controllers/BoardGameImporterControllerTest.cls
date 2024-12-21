/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Importer Controller Class
*
* Testing for actual Logic in the Controller are tested in the Service Class Tests, 
* so these are true Unit Tests to make sure that the Controller is working as intended.
*
* Makes use of the MockSetup Test Pattern to stub out Service Class and Selectors used 
* in the Controller.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2024-11-30
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BoardGameImporterControllerTest {

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
        RETURNED_EVENTS,
        RETURNED_MESSAGE
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_EVENTS => List<Event__c>.class,
                MockParams.RETURNED_MESSAGE => String.class
            };
        }
    }

    //Create the MockSetup Class which we will use to handle all of our mocking and stubbing in our test methods 
    class MockSetup{

        public fflib_ApexMocks mocks = new fflib_ApexMocks();
        public fflib_SobjectUnitOfWork uowMock;

        private MockSetup(Map<MockParams, Object> params) {
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
            IEventSelector mockEventSelector = (IEventSelector) mocks.mock(EventSelector.class);
            uowMock = (fflib_SobjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            IBoardGamesService mockBoardGameService = (IBoardGamesService) mocks.mock(BoardGamesService.class);

            mocks.startStubbing();
            //Stubbing the Event Selector
            //IMPORTANT: Stubbing the SObjectType is REQUIRED or the mocking of the Selector WILL Fail
            mocks.when(mockEventSelector.SObjectType()).thenReturn(Event__c.SObjectType);
            //Stub out each Selector Method that the Controller calls
            mocks.when(mockEventSelector.selectAll())
                // The Mocked Selector will BYPASS calling of the actual method and instead just return
                // the Value in the Params Map that was passed in for the Enum Key RETURNED_EVENTS
                // If no value was provided, a newInstance of the Object (List<Event__c>) was created
                // and we will return that here instead
                .thenReturn((List<Event__c>) params.get(MockParams.RETURNED_EVENTS));
            //Any Methods of the Selector that are NOT Stubbed will return a NULL value if called

            //Stubbing the Board Game Service
            mocks.when(mockBoardGameService.getBoardGameDetailsFromBGG( (fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                                        fflib_Match.anyId(), 
                                                                                        fflib_Match.anyString(), 
                                                                                        fflib_Match.anyBoolean(), 
                                                                                        fflib_Match.anyBoolean()))
                .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
            mocks.stopStubbing();

            //Whenever the BoardGamesService or EventsSelector are created using the Application Class, 
            //Replace that class and all of its methods with our Mock Service with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Selector.setMock(mockEventSelector);
            Application.Service.setMock(IBoardGamesService.class, mockBoardGameService);
            Application.UnitOfWork.setMock(uowMock);
        }
    } 

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    // Test Plan
    // Call getEventList Method
    // Call importFromBGG Method Given Dummy Inputs

    // Call getEventList Method
    @IsTest
    public static void givenMockedEvent_WhenGetEventListIsCalled_ThenReturnMockEvent(){

        //Setup Test Data and Mocking
        //Setup Return Values without performing insert
        Event__c returnedEvent = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType)
        );

        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_EVENTS => new List<Event__c>{returnedEvent}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);

        //Run Test
        Test.startTest();
        List<Event__c> results = BoardGameImporterController.getEventList();
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Events Returned');
        Assert.areEqual(returnedEvent.Id, results[0].id, 'Id of Returned Event does not match');
    }

    // Call importFromBGG Method Given Dummy Inputs
    @IsTest
    public static void givenDummyInputs_WhenImportFromBGGIsCalled_ThenReturnExpectedMessage(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_MESSAGE => 'Service Mocked Successfully'
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);

        //Run Test
        Test.startTest();
        String result = BoardGameImporterController.importFromBGG(fflib_IDGenerator.generate(Event__c.SObjectType),
                                                    'Fake Collection Name',
                                                    true,
                                                    true );
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Service Mocked Successfully', result, 'Incorrect Message Recieved: '+ result);
    }
}