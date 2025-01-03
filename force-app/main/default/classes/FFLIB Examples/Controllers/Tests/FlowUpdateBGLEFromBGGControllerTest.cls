/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Update Board Game Library Entry From BGG Flow Controller Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* Makes use of the MockSetup Test Pattern to stub out Service Class used in the Controller.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-03
* @modified       2025-01-03
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class FlowUpdateBGLEFromBGGControllerTest {
        
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
                MockParams.RETURNED_MESSAGE => List<String>.class
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
            IBGLibraryEntryService mockBGLEService = (IBGLibraryEntryService) mocks.mock(BGLibraryEntryService.class);

            mocks.startStubbing();
            //Stubbing the Board Game Library Entry Service
            if(throwErrors){
                ((IBGLibraryEntryService) mocks.doThrowWhen(new BGLibraryEntryService.BGLEServiceException('Thrown Exception'),
                                                                mockBGLEService)).updateBGLibraryEntriesFromBGG(
                                                                            (fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                            (List<BG_Library_Entry__c>) fflib_Match.anyObject());

            } else {
                mocks.when(mockBGLEService.updateBGLibraryEntriesFromBGG( (fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                            (List<BG_Library_Entry__c>) fflib_Match.anyObject() 
                                                                        ))
                    .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
            }
            mocks.stopStubbing();

            //Whenever the BoardGamesService is created using the Application Class, 
            //Replace that class and all of its methods with our Mock Service with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Service.setMock(IBGLibraryEntryService.class, mockBGLEService);
            Application.UnitOfWork.setMock(uowMock);
        }
    } 

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    // Test Plan
    // Call updateMultipleBGLERecordsFromBGG Method Given Dummy Inputs, Return Success Message
    // Call updateMultipleBGLERecordsFromBGG Method Given Dummy Inputs, Throw Error

    //Start Testing
    // Call updateMultipleBGLERecordsFromBGG Method Given Dummy Inputs
    @IsTest
    public static void givenDummyInputs_WhenUpdateMultipleBGLERecordsFromBGGIsCalled_ThenReturnExpectedMessage(){
                //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_MESSAGE => 'Service Mocked Successfully'
        };

        FlowUpdateBGLEFromBGGController.InputWrapper input = new FlowUpdateBGLEFromBGGController.InputWrapper();
        input.boardGameLibraryEntries = new List<BG_Library_Entry__c>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<String> results = FlowUpdateBGLEFromBGGController.updateMultipleBGLERecordsFromBGG(new List<FlowUpdateBGLEFromBGGController.InputWrapper>{input});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
        Assert.areEqual('Service Mocked Successfully', results[0], 'Incorrect Message Recieved: '+ results[0]);
    }

    // Call updateMultipleBGLERecordsFromBGG Method Given Dummy Inputs, Throw Error
    @IsTest
    public static void givenDummyInputs_WhenUpdateMultipleBGLERecordsFromBGGIsCalled_ThenThrowError(){
                //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_MESSAGE => 'Service Mocked Successfully'
        };

        FlowUpdateBGLEFromBGGController.InputWrapper input = new FlowUpdateBGLEFromBGGController.InputWrapper();
        input.boardGameLibraryEntries = new List<BG_Library_Entry__c>();
        
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<String> results = FlowUpdateBGLEFromBGGController.updateMultipleBGLERecordsFromBGG(new List<FlowUpdateBGLEFromBGGController.InputWrapper>{input});
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

}