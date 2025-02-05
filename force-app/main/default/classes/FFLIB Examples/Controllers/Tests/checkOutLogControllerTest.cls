/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Check Out Log Controller Class
*
* Testing for actual Logic in the Controller are tested in the Service Class Tests, 
* so these are true Unit Tests to make sure that the Controller is working as intended.
*
* Makes use of the MockSetup Test Pattern to stub out Service and Selector Classes used in the Controller.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-02-05
* @modified       2025-02-05
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class checkOutLogControllerTest {

    //#region Test Setup
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
        RETURNED_BGLES,
        RETURNED_BGRS,
        RETURNED_CHECKOUT_LOGS,
        RETURNED_ATTENDEES
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_BGLES => List<BG_Library_Entry__c>.class,
                MockParams.RETURNED_BGRS => List<Board_Game_Rating__c>.class,
                MockParams.RETURNED_CHECKOUT_LOGS => List<BG_Checkout_Log__c>.class,
                MockParams.RETURNED_ATTENDEES => List<Event_Attendee__c>.class
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
            IEventAttendeeSelector mockAttendeeSelector = (IEventAttendeeSelector) mocks.mock(EventAttendeeSelector.class);
            IBGLibraryEntrySelector mockBGLESelector = (IBGLibraryEntrySelector) mocks.mock(BGLibraryEntrySelector.class);
            IBoardGameRatingSelector mockBGRSelector = (IBoardGameRatingSelector) mocks.mock(BoardGameRatingSelector.class);
            IBGCheckOutLogSelector mockLogSelector = (IBGCheckOutLogSelector) mocks.mock(BGCheckOutLogSelector.class);
            IBGCheckOutLogService mockLogService = (IBGCheckOutLogService) mocks.mock(BGCheckOutLogService.class);

            mocks.startStubbing();
            //Stubbing the Check Out Log Service and Selectors
            //Stub out each Service Method and Selector Method that the Controller calls
            mocks.when(mockAttendeeSelector.SObjectType()).thenReturn(Event_Attendee__c.SObjectType);
            mocks.when(mockBGLESelector.SObjectType()).thenReturn(BG_Library_Entry__c.SObjectType);
            mocks.when(mockBGRSelector.SObjectType()).thenReturn(Board_Game_Rating__c.SObjectType);
            mocks.when(mockLogSelector.SObjectType()).thenReturn(BG_Checkout_Log__c.SObjectType);

            If(throwErrors){ //If throwErrors is true, throw an error when methods are called instead
                ((IEventAttendeeSelector) mocks.doThrowWhen(new BGCheckOutLogService.BGCheckOutLogServiceException('Thrown Exception'),
                                                    mockAttendeeSelector)).selectByEventIDs(
                                                                            (Set<Id>) fflib_Match.anyObject());
                ((IBGLibraryEntrySelector) mocks.doThrowWhen(new BGCheckOutLogService.BGCheckOutLogServiceException('Thrown Exception'),
                                                    mockBGLESelector)).selectById(
                                                                            (Set<Id>) fflib_Match.anyObject());
                ((IBGCheckOutLogSelector) mocks.doThrowWhen(new BGCheckOutLogService.BGCheckOutLogServiceException('Thrown Exception'),
                                                    mockLogSelector)).selectById(
                                                                            (Set<Id>) fflib_Match.anyObject());
                ((IBGCheckOutLogService) mocks.doThrowWhen(new BGCheckOutLogService.BGCheckOutLogServiceException('Thrown Exception'),
                                                    mockLogService)).createCheckOutLog(
                                                                            (fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                            fflib_Match.anyId(),
                                                                            fflib_Match.anyId(),
                                                                            fflib_Match.anyDatetime());
                ((IBGCheckOutLogService) mocks.doThrowWhen(new BGCheckOutLogService.BGCheckOutLogServiceException('Thrown Exception'),
                                                    mockLogService)).updateCheckOutLog(
                                                                            (fflib_SObjectUnitOfWork) fflib_Match.anyObject(),
                                                                            (BG_Checkout_Log__c) fflib_Match.anyObject(),
                                                                            fflib_Match.anyDatetime());
            } else { //If throwErrors is false, return given List of Records when methods are called
                mocks.when(mockAttendeeSelector.selectByEventIDs(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<Event_Attendee__c>) params.get(MockParams.RETURNED_ATTENDEES));
                mocks.when(mockBGLESelector.selectById(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<BG_Library_Entry__c>) params.get(MockParams.RETURNED_BGLES));
                mocks.when(mockBGLESelector.selectByBoardGameId(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<BG_Library_Entry__c>) params.get(MockParams.RETURNED_BGLES));
                mocks.when(mockBGRSelector.selectById(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<Board_Game_Rating__c>) params.get(MockParams.RETURNED_BGRS));
                mocks.when(mockLogSelector.selectById(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<BG_Checkout_Log__c>) params.get(MockParams.RETURNED_CHECKOUT_LOGS));
                mocks.when(mockLogSelector.selectByLibraryEntryId(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<BG_Checkout_Log__c>) params.get(MockParams.RETURNED_CHECKOUT_LOGS));
                mocks.when(mockLogSelector.selectByBoardGameId(
                                                        (Set<Id>) fflib_Match.anyObject()))
                    .thenReturn((List<BG_Checkout_Log__c>) params.get(MockParams.RETURNED_CHECKOUT_LOGS));
            }
            mocks.stopStubbing();

            //Whenever the Service or Selectors are created using the Application Class, 
            //Replace that class and all of its methods with our Mocked Class with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Selector.setMock(mockAttendeeSelector);
            Application.Selector.setMock(mockBGLESelector);
            Application.Selector.setMock(mockBGRSelector);
            Application.Selector.setMock(mockLogSelector);
            Application.Service.setMock(IBGCheckOutLogService.class, mockLogService);
            Application.UnitOfWork.setMock(uowMock);
        }
    } 
    //#endregion

    // Begin Tests
    // Tests should follow a Use Case Test Plan

    //#region Test Plan
    // Get Event Attendees with Null Id
    // Get Event Attendees with Thrown Error
    // Get Event Attendees with No Results Returned
    // Get Event Attendees with Results Returned
    // Get Library Entries for BG_Library_Entry__c SObject Type
    // Get Library Entries for Board_Games__c SObject Type
    // Get Library Entries for Board_Game_Rating__c SObject Type When BGR Not Found
    // Get Library Entries for Board_Game_Rating__c SObject Type When BGR Found
    // Get Library Entries for BG_Checkout_Log__c SObject Type When Log Not Found
    // Get Library Entries for BG_Checkout_Log__c SObject Type When Log Found
    // Get Library Entries with Other SObject Type
    // Get Library Entries with Error Thrown
    // Get Check Out Logs for BG_Library_Entry__c SObject Type
    // Get Check Out Logs for Board_Games__c SObject Type
    // Get Check Out Logs for Board_Game_Rating__c SObject Type When BGR Not Found
    // Get Check Out Logs for Board_Game_Rating__c SObject Type When BGR Found
    // Get Check Out Logs for BG_Checkout_Log__c SObject Type
    // Get Check Out Logs with Other SObject Type    
    // Get Check Out Logs with Error Thrown
    // Create Check Out Log with Error Thrown
    // Create Check Out Log Successfully
    // Update Check Out Log with Error Thrown
    // Update Check Out Log Successfully
    //#endregion

    //Start Testing
    //#region ////////////////////////// getEventAttendeesByEventId ////////////////////////////////////
    // Get Event Attendees with Null Id
    @IsTest
    public static void givenMissingEventId_WhenGetEventAttendeesByEventIdIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<Event_Attendee__c> results = checkOutLogController.getEventAttendeesByEventId(null);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Event ID cannot be null or empty.', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Get Event Attendees with Thrown Error
    @IsTest
    public static void givenEventId_WhenGetEventAttendeesByEventIdIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params with errors thrown
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<Event_Attendee__c> results = checkOutLogController.getEventAttendeesByEventId(fflib_IDGenerator.generate(Event__c.SObjectType));
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Get Event Attendees with No Results Returned
    @IsTest
    public static void givenNoReturnedResults_WhenGetEventAttendeesByEventIdIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<Event_Attendee__c> results = checkOutLogController.getEventAttendeesByEventId(fflib_IDGenerator.generate(Event__c.SObjectType));
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('No Event Attendees found for this event.', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Get Event Attendees with Results Returned
    @IsTest
    public static void givenEventId_WhenGetEventAttendeesByEventIdIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_ATTENDEES => new List<Event_Attendee__c>{new Event_Attendee__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<Event_Attendee__c> results = checkOutLogController.getEventAttendeesByEventId(fflib_IDGenerator.generate(Event__c.SObjectType));
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    //#endregion
    //#region ////////////////////////// getBGLEs ////////////////////////////////////
    // Get Library Entries for BG_Library_Entry__c SObject Type
    @IsTest
    public static void givenBGLEType_WhenGetBGLEsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BGLES => new List<BG_Library_Entry__c>{new BG_Library_Entry__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 'BG_Library_Entry__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Library Entries for Board_Games__c SObject Type
    @IsTest
    public static void givenBoardGameType_WhenGetBGLEsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BGLES => new List<BG_Library_Entry__c>{new BG_Library_Entry__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(Board_Games__c.SObjectType), 'Board_Games__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Library Entries for Board_Game_Rating__c SObject Type When BGR not Found
    @IsTest
    public static void givenBGRTypeAndNoRecord_WhenGetBGLEsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BGLES => new List<BG_Library_Entry__c>{new BG_Library_Entry__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType), 'Board_Game_Rating__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(0, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Library Entries for Board_Game_Rating__c SObject Type When BGR Found
    @IsTest
    public static void givenBGRTypeAndBGRRecord_WhenGetBGLEsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BGLES => new List<BG_Library_Entry__c>{new BG_Library_Entry__c()},
            MockParams.RETURNED_BGRS => new List<Board_Game_Rating__c>{new Board_Game_Rating__c(Board_Game__c = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType), 'Board_Game_Rating__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Library Entries for BG_Checkout_Log__c SObject Type When Log Not Found
    @IsTest
    public static void givenLogTypeAndNoLogRecord_WhenGetBGLEsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BGLES => new List<BG_Library_Entry__c>{new BG_Library_Entry__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType), 'BG_Checkout_Log__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(0, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Library Entries for BG_Checkout_Log__c SObject Type When Log Found
    @IsTest
    public static void givenLogTypeAndLogRecord_WhenGetBGLEsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BGLES => new List<BG_Library_Entry__c>{new BG_Library_Entry__c()},
            MockParams.RETURNED_CHECKOUT_LOGS => new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c(BG_Library_Entry__c = fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType))}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType), 'BG_Checkout_Log__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Library Entries with Other SObject Type
    @IsTest
    public static void givenOtherType_WhenGetBGLEsIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(Account.SObjectType), 'Other');
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Invalid SObject Type.', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Get Library Entries with Error Thrown
    @IsTest
    public static void givenBGLEType_WhenGetBGLEsIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params with errors thrown
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<BG_Library_Entry__c> results = checkOutLogController.getBGLEs(fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 'BG_Library_Entry__c');
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    //#endregion
    //#region ////////////////////////// getCheckOutLogs ////////////////////////////////////
    // Get Check Out Logs for BG_Library_Entry__c SObject Type
    @IsTest
    public static void givenBGLEType_WhenGetCheckOutLogsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_CHECKOUT_LOGS => new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType), 'BG_Library_Entry__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Check Out Logs for Board_Games__c SObject Type
    @IsTest
    public static void givenBoardGameType_WhenGetCheckOutLogsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_CHECKOUT_LOGS => new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(Board_Games__c.SObjectType), 'Board_Games__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Check Out Logs for Board_Game_Rating__c SObject Type When BGR Not Found
    @IsTest
    public static void givenBGRTypeAndNoBGR_WhenGetCheckOutLogsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_CHECKOUT_LOGS => new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType), 'Board_Game_Rating__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(0, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Check Out Logs for Board_Game_Rating__c SObject Type When BGR Found
    @IsTest
    public static void givenBGRTypeAndBGRRecord_WhenGetCheckOutLogsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_CHECKOUT_LOGS => new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c()},
            MockParams.RETURNED_BGRS => new List<Board_Game_Rating__c>{new Board_Game_Rating__c(Board_Game__c = fflib_IDGenerator.generate(Board_Games__c.SObjectType))}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType), 'Board_Game_Rating__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Check Out Logs for BG_Checkout_Log__c SObject Type
    @IsTest
    public static void givenLogType_WhenGetCheckOutLogsIsCalled_ThenReturnResults(){

        //Setup Test Data and Mocking
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_CHECKOUT_LOGS => new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c()}
        };

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType), 'BG_Checkout_Log__c');
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'Incorrect Number of Results Returned');
    }

    // Get Check Out Logs with Other SObject Type
    @IsTest
    public static void givenOtherType_WhenGetCheckOutLogsIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(Account.SObjectType), 'Other');
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Invalid SObject Type.', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Get Check Out Logs with Error Thrown
    @IsTest
    public static void givenLogType_WhenGetCheckOutLogsIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params with errors thrown
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            List<BG_Checkout_Log__c> results = checkOutLogController.getCheckOutLogs(fflib_IDGenerator.generate(BG_Checkout_Log__c.SObjectType), 'BG_Checkout_Log__c');
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }
     
    //#endregion
    //#region ////////////////////////// createCheckOutLog ////////////////////////////////////
    // Create Check Out Log with Error Thrown
    @IsTest
    public static void givenCorrectInputs_WhenCreateCheckOutLogsIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params with errors thrown
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            checkOutLogController.createCheckOutLog(
                                                    fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType),
                                                    fflib_IDGenerator.generate(Event_Attendee__c.SObjectType),
                                                    System.now()
                                                );
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Create Check Out Log Successfully
    @IsTest
    public static void givenCorrectInputs_WhenCreateCheckOutLogsIsCalled_ThenNoErrors(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        checkOutLogController.createCheckOutLog(
                                                fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType),
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType),
                                                System.now()
                                            );
        Test.stopTest();

        //Validate Method finished and Service Not Called
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1)).commitWork();
    }

    //#endregion
    //#region ////////////////////////// updateCheckOutLog ////////////////////////////////////
    // Update Check Out Log with Error Thrown
    @IsTest
    public static void givenCorrectInputs_WhenUpdateCheckOutLogsIsCalled_ThenThrowError(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params with errors thrown
        MockSetup mock = new MockSetup(params, true);

        //Run Test
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            checkOutLogController.updateCheckOutLog(
                                                    new BG_Checkout_Log__c(),
                                                    System.now()
                                                );
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
    }

    // Update Check Out Log Successfully
    @IsTest
    public static void givenCorrectInputs_WhenUpdateCheckOutLogsIsCalled_ThenNoErrors(){

        //Setup Test Data and Mocking
        //No Test Data Needed For this Unit Test
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params
        MockSetup mock = new MockSetup(params, false);

        //Run Test
        Test.startTest();
        checkOutLogController.updateCheckOutLog(
                                                new BG_Checkout_Log__c(),
                                                System.now()
                                            );
        Test.stopTest();

        //Validate Method finished and Service Not Called
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1)).commitWork();
    }

    //#endregion
}