/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Update From Board Game Geek Controller Class
*
* Testing for actual Logic in the Controller are tested in the Service Class Tests, 
* so these are true Unit Tests to make sure that the Controller is working as intended.
*
* Makes use of the MockSetup Test Pattern to stub out Service Class used in the Controller.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-26
* @modified       2024-12-26
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class UpdateFromBGGControllerTest {

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
        RETURNED_MESSAGE
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_MESSAGE => String.class
            };
        }
    }

    //Create the MockSetup Class which we will use to handle all of our mocking and stubbing in our test methods 
    class MockSetup{

        public fflib_ApexMocks mocks = new fflib_ApexMocks();
        public fflib_SobjectUnitOfWork uowMock;

        private MockSetup(Map<MockParams, Object> params, Boolean throwErrors) {
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
            uowMock = (fflib_SobjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            IBoardGamesService mockBoardGameService = (IBoardGamesService) mocks.mock(BoardGamesService.class);

            mocks.startStubbing();
            //Stubbing the Board Game Service
            //Stub out each Service Method that the Controller calls
            If(throwErrors){ //If throwErrors is true, throw an error when method is called instead
                ((IBoardGamesService) mocks.doThrowWhen(new BoardGamesService.BGServiceException('Thrown Exception'),
                                                    mockBoardGameService)).updateBoardGameDetailsFromBGG(
                                                                            (fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                            (Map<ID, String>) fflib_Match.anyObject());
            } else { //If throwErrors is false, return given string value when method is called
                mocks.when(mockBoardGameService.updateBoardGameDetailsFromBGG((fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                            (Map<ID, String>) fflib_Match.anyObject()))
                    // The Mocked Selector will BYPASS calling of the actual method and instead just return
                    // the Value in the Params Map that was passed in for the Enum Key RETURNED_EVENTS
                    // If no value was provided, a newInstance of the Object (List<Event__c>) was created
                    // and we will return that here instead
                    .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
                //Any Methods of the Selector that are NOT Stubbed will return a NULL value if called
                }
            mocks.stopStubbing();

            //Whenever the BoardGamesService is created using the Application Class, 
            //Replace that class and all of its methods with our Mock Service with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Service.setMock(IBoardGamesService.class, mockBoardGameService);
            Application.UnitOfWork.setMock(uowMock);
        }
    } 

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    // Test Plan
    // Call UpdateRecordFromBGG Method Given Dummy Inputs Successfully
    // Call UpdateRecordFromBGG Method Given Dummy Inputs With Error Thrown

    // Call UpdateRecordFromBGG Method Given Dummy Inputs Successfully
    @IsTest
    public static void givenDummyInputs_WhenUpdateRecordFromBGGIsCalled_ThenReturnExpectedMessage(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_MESSAGE => 'Service Mocked Successfully'
        };

        //Initialize MockSetup with Params without throwing errors
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        String result = UpdateFromBGGController.UpdateRecordFromBGG(fflib_IDGenerator.generate(Board_Games__c.SObjectType), '12345');
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Service Mocked Successfully', result, 'Incorrect Message Recieved: '+ result);
    }

    // Call UpdateRecordFromBGG Method Given Dummy Inputs With Error Thrown
    @IsTest
    public static void givenDummyInputs_WhenUpdateRecordFromBGGIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_MESSAGE => 'Service Mocked Successfully'
        };

        //Initialize MockSetup with Params with errors thrown
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            String result = UpdateFromBGGController.UpdateRecordFromBGG(fflib_IDGenerator.generate(Board_Games__c.SObjectType), '12345');
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }
}