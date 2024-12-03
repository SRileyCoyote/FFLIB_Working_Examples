/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Service Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* Makes use of the MockSetup Test Pattern to stub out the Selectors 
* and BGG API Callout Service used in the Service.
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
private class BoardGamesServiceTest {

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
        RETURNED_BOARD_GAMES,
        RETURNED_ID_CALLOUT_RESULT,
        RETURNED_DETAILS_CALLOUT_RESULT
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_BOARD_GAMES => List<Board_Games__c>.class,
                MockParams.RETURNED_ID_CALLOUT_RESULT => BGGCalloutService.CalloutResult.class,                
                MockParams.RETURNED_DETAILS_CALLOUT_RESULT => BGGCalloutService.CalloutResult.class
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
            IBoardGameSelector mockBoardGameSelector = (IBoardGameSelector) mocks.mock(BoardGameSelector.class);
            IBGGCalloutService mockCalloutService = (IBGGCalloutService) mocks.mock(BGGCalloutService.class);
            
            mockConfig = new Services_Config__mdt(
                                        Domain_Config__r = new Domain_Config__mdt(
                                            DeveloperName = 'BoardGames'),
                                        Service_Enabled__c = true
                                    );
            
            mocks.startStubbing();
            //Stubbing the BGR Selector
            //IMPORTANT: Stubbing the SObjectType is REQUIRED or the mocking of the Selector WILL Fail
            mocks.when(mockBoardGameSelector.SObjectType()).thenReturn(Board_Games__c.SObjectType);
            //Stub out each Selector Method that the Service calls using calls
            mocks.when(mockBoardGameSelector.selectByBGGIDs(
                                            //Using fflib_Match here tells the mock to replace this method
                                            //Regardless of what values are given to the method  
                                            (Set<String>) fflib_Match.anyObject()
                                        ))
                // The Mocked Selector will BYPASS calling of the actual method and instead just return
                // the Value in the Params Map that was passed in for the Enum Key RETURNED_BOARD_GAME_RATINGS
                // If no value was provided, a newInstance of the Object (List<Board_Game_Rating__c>) was created
                // and we will return that here instead
                .thenReturn((List<Board_Games__c>) params.get(MockParams.RETURNED_BOARD_GAMES));
            //Any Methods of the Selector that are NOT Stubbed will return a NULL value if called

            //Stubbing the BGGCalloutService
            mocks.when(mockCalloutService.getIDsFromBoardGameGeek(
                                            fflib_Match.anyString(),
                                            fflib_Match.anyBoolean()
                                        ))
                .thenReturn((BGGCalloutService.CalloutResult) params.get(MockParams.RETURNED_ID_CALLOUT_RESULT));
            mocks.when(mockCalloutService.getBoardGameDetailsFromBGG(
                                            (BGGCalloutService.CalloutResult) fflib_Match.anyObject()
                                        ))
                //Using Seperate Return Value for the Second Callout 
                .thenReturn((BGGCalloutService.CalloutResult) params.get(MockParams.RETURNED_DETAILS_CALLOUT_RESULT));
            mocks.stopStubbing();

            // Set the Selector Mock and UOW Mock created as the classes to be used 
            // when the Selector and UOW Classes are initialized from the Application Layer instead of the normal classes
            Application.UnitOfWork.setMock(uowMock);
            Application.Selector.setMock(mockBoardGameSelector);
            Application.Service.setMock(IBGGCalloutService.class, mockCalloutService);
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
        BoardGamesService service = new BoardGamesService();
        Test.stopTest(); 

        // Validate that serviceConfigMap not only contains values for the BoardGamesService
        // But also contains a config record for each of the methods of the Service 
        Assert.areNotEqual(0, service.serviceConfigMap.size(), 'No Service Configs Found for BoardGameRatingsDomain');
        Assert.isTrue(service.serviceConfigMap.containsKey('getBoardGameDetailsFromBGG'), 'Service Config for getBoardGameDetailsFromBGG Method Not Found');
    }

    ////////////////////////////// getBoardGameDetailsFromBGG Tests ////////////////////////////////////////
    // Test Plan
    // Get Board Game Details with Custom Config where Service Disabled
    // Get Board Game Details with Blank Event ID
    // Get Board Game Details with Invalid Event ID
    // Get Board Game Details with Blank Collection Name or ID
    // Get Board Game Details with Failed Result From Getting IDs
    // Get Board Game Details with No Existing Board Games
    // Get Board Game Details with Unprocessed IDs Returned
    // Get Board Game Details with One New Matching Board Game and Update Exisiting
    // Get Board Game Details with One New Matching Board Game and NOT Update Exisiting
    // Get Board Game Details with One NOT New Matching Board Game and Update Exisiting
    // Get Board Game Details with One NOT New Matching Board Game and NOT Update Exisiting

    // Get Board Game Details with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenGetBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';
        mock.mockConfig.Service_Enabled__c = false;

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                            fflib_IDGenerator.generate(Event__c.SObjectType), 
                                            'This String',
                                            false,
                                            false);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.SERVICE_NOT_ENABLED_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Get Board Game Details with Blank Event ID
    @IsTest
    public static void givenNoEventID_WhenGetBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{};

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                            null, 
                                            'This String',
                                            false,
                                            false);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.EVENT_ID_INVALID_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Get Board Game Details with Invalid Event ID
    @IsTest
    public static void givenInvalidEventID_WhenGetBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{};

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                            fflib_IDGenerator.generate(Board_Games__c.SObjectType), 
                                            'This String',
                                            false,
                                            false);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.EVENT_ID_INVALID_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Get Board Game Details with Blank Collection Name or ID
    @IsTest
    public static void givenBlankEventID_WhenGetBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{};

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                            fflib_IDGenerator.generate(Event__c.SObjectType), 
                                            null,
                                            false,
                                            false);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.COLLECTION_OR_ID_INVALID_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Get Board Game Details with Failed Result From Getting IDs
    @IsTest
    public static void givenNoBGGIDsReturned_WhenGetBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        calloutResult.resultMessage = 'No New Games Found';

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_ID_CALLOUT_RESULT => calloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                            fflib_IDGenerator.generate(Event__c.SObjectType), 
                                            'CollectionName',
                                            false,
                                            false);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('No New Games Found', errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Get Board Game Details with Failed Result From Getting Details
    @IsTest
    public static void givenErrorWhenDetailsReturned_WhenGetBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        calloutResult.resultMessage = 'Problem Getting Details';

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                            fflib_IDGenerator.generate(Event__c.SObjectType), 
                                            'CollectionName',
                                            false,
                                            false);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('Problem Getting Details', errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Get Board Game Details with No Existing Board Games
    @IsTest
    public static void givenBGGIDReturned_WhenGetBGDetailsCalledWithNoExisitingRecords_ThenNewRecordsInserted(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game'
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        wrapper.ownerName = 'My Name';
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult
        };
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                        eventId, 
                                        'CollectionName',
                                        false,
                                        false);
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.SUCCESS_MSG, new Integer[]{
                                                                        1, // # of New
                                                                        0  // # of Updated
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New method Ran Twice, 
        //Once for the Board Game and Once For the Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.sobjectWith(
                //Validate Record in Register New is the same as the Board Game in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c,
                    Board_Games__c.Name => testBoardGame.Name
                }
            ));
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.sobjectWith(
                            //Validate Record in Register New is for Library Entry
                            new Map<Schema.SObjectField, Object>{
                                //And that the Values inserted match expected
                                BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                                BG_Library_Entry__c.Event__c => eventId
                            }
                        ),
                        //Matches Relationship Field
                        fflib_Match.eqSObjectField(BG_Library_Entry__c.Board_Game__c), 
                        //Matches Object to create Relationship with
                        fflib_Match.sobjectWith(
                            //Validate Record in same as 
                            new Map<Schema.SObjectField, Object>{
                                //And that the Values inserted match expected
                                Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c
                            }
                        ) 
            );
    }

    // Get Board Game Details with Unprocessed IDs Returned
    @IsTest
    public static void givenTooManyBGGIDsReturned_WhenGetBGDetailsCalled_ThenPartialRecordsInserted(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game'
                                            );
        BGGCalloutService.CalloutResult detailCalloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        wrapper.ownerName = 'My Name';
        detailCalloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };
        detailCalloutResult.unprocessedIDs = new Set<String>{'5678'};
        BGGCalloutService.CalloutResult idCalloutResult = new BGGCalloutService.CalloutResult();
        idCalloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper,
            '5678' => new BGGCalloutService.BoardGameWrapper()
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => detailCalloutResult,
            MockParams.RETURNED_ID_CALLOUT_RESULT => idCalloutResult
        };
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                        eventId, 
                                        'CollectionName',
                                        false,
                                        false);
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.UNPROCESSED_FOUND_MSG, new Integer[]{
                                                                        1, // Total Processed
                                                                        2, // Total Found
                                                                        1, // # of New
                                                                        0  // # of Updated
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New method Still Ran Twice, 
        //Once for the Board Game and Once For the Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.sobjectWith(
                //Validate Record in Register New is the same as the Board Game in the detailCalloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c,
                    Board_Games__c.Name => testBoardGame.Name
                }
            ));
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.sobjectWith(
                            //Validate Record in Register New is for Library Entry
                            new Map<Schema.SObjectField, Object>{
                                //And that the Values inserted match expected
                                BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                                BG_Library_Entry__c.Event__c => eventId
                            }
                        ),
                        //Matches Relationship Field
                        fflib_Match.eqSObjectField(BG_Library_Entry__c.Board_Game__c), 
                        //Matches Object to create Relationship with
                        fflib_Match.sobjectWith(
                            //Validate Record in same as 
                            new Map<Schema.SObjectField, Object>{
                                //And that the Values inserted match expected
                                Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c
                            }
                        ) 
            );
    }

    // Get Board Game Details with One New Matching Board Game and Update Exisiting
    @IsTest
    public static void givenExistingBGFoundMarkedNewAndUpdateTrue_WhenGetBGDetailsCalled_ThenRecordUpdated(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = true
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame}
        };
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                        eventId, 
                                        'CollectionName',
                                        false,
                                        true); //Update Exisiting
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.SUCCESS_MSG, new Integer[]{
                                                                        0, // # of New
                                                                        1  // # of Updated
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            //Change fflib_Match.sObjectWith to sObject*S*With
            .registerDirty(fflib_Match.sObjectsWith(
                //Added this line since registerDirty applies to a List 
                new List<Map<SObjectField,Object>> {
                    //Validate Record in Register Dirty is the same as the Board Game in the calloutResult 
                    new Map<SObjectField,Object> {
                        //And that the Values updated match expected
                        Board_Games__c.Id => testBoardGame.Id,
                        Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c,
                        Board_Games__c.Name => testBoardGame.Name,
                        Board_Games__c.Is_New__c => false
                    }
                }
            ));
    }

    // Get Board Game Details with One New Matching Board Game and NOT Update Exisiting
    @IsTest
    public static void givenExistingBGFoundMarkedNewAndUpdateFalse_WhenGetBGDetailsCalled_ThenRecordUpdated(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = true
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_ID_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame}
        };
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                        eventId, 
                                        'CollectionName',
                                        false,
                                        false); //Update Exisiting
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.SUCCESS_MSG, new Integer[]{
                                                                        0, // # of New
                                                                        0  // # of Updated
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            //Change fflib_Match.sObjectWith to sObject*S*With
            .registerDirty(fflib_Match.sObjectWith(
                //Validate Record in Register Dirty is the same as the Board Game in the calloutResult 
                new Map<SObjectField,Object> {
                    //And that the Values updated match expected
                    Board_Games__c.Id => testBoardGame.Id,
                    Board_Games__c.Is_New__c => false
                }
            ));
    }

    // Get Board Game Details with One NOT New Matching Board Game and Update Exisiting
    @IsTest
    public static void givenExistingBGFoundNotMarkedNewAndUpdateTrue_WhenGetBGDetailsCalled_ThenRecordUpdated(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = false
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame}
        };
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                        eventId, 
                                        'CollectionName',
                                        false,
                                        true); //Update Exisiting
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.SUCCESS_MSG, new Integer[]{
                                                                        0, // # of New
                                                                        1  // # of Updated
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            //Change fflib_Match.sObjectWith to sObject*S*With
            .registerDirty(fflib_Match.sObjectsWith(
                //Added this line since registerDirty applies to a List 
                new List<Map<SObjectField,Object>> {
                    //Validate Record in Register Dirty is the same as the Board Game in the calloutResult 
                    new Map<SObjectField,Object> {
                        //And that the Values updated match expected
                        Board_Games__c.Id => testBoardGame.Id,
                        Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c,
                        Board_Games__c.Name => testBoardGame.Name,
                        Board_Games__c.Is_New__c => false
                    }
                }
            ));
    }

    // Get Board Game Details with One NOT New Matching Board Game and NOT Update Exisiting
    @IsTest
    public static void givenExistingBGFoundNotMarkedNewAndUpdateFalse_WhenGetBGDetailsCalled_ThenNoUpdate(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = false
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_ID_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame}
        };
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'getBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.getBoardGameDetailsFromBGG(mock.uowMock, 
                                        eventId, 
                                        'CollectionName',
                                        false,
                                        false); //Update Exisiting
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.SUCCESS_MSG, new Integer[]{
                                                                        0, // # of New
                                                                        0  // # of Updated
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New and Register Dirty did NOT run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerNew(fflib_Match.anySObject());

        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
    }

}