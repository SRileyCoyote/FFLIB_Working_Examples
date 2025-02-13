/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Service Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* This Test Class has dozens of Test Methods which might seem like a LOT but once the first test method is
* written, it can then be copied over to the next one and only slight variation needs to be made
* for the next test class based on the inputs changed and the different results. 
*
* Makes use of the MockSetup Test Pattern to stub out the Selectors 
* and BGG API Callout Service used in the Service.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2025-02-13
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BoardGamesServiceTest {

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
        RETURNED_BOARD_GAMES,
        RETURNED_BG_LIBRARY_ENTRIES,
        RETURNED_ID_CALLOUT_RESULT,
        RETURNED_DETAILS_CALLOUT_RESULT
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_BOARD_GAMES => List<Board_Games__c>.class,
                MockParams.RETURNED_BG_LIBRARY_ENTRIES => List<BG_Library_Entry__c>.class,
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
            IBGLibraryEntrySelector mockBGLEntrySelector = (IBGLibraryEntrySelector) mocks.mock(BGLibraryEntrySelector.class);
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
                // the Value in the Params Map that was passed in for the Enum Key RETURNED_BOARD_GAMES
                // If no value was provided, a newInstance of the Object (List<Board_Games__c>) was created
                // and we will return that here instead
                .thenReturn((List<Board_Games__c>) params.get(MockParams.RETURNED_BOARD_GAMES));
            //Any Methods of the Selector that are NOT Stubbed will return a NULL value if called

            //Stubbing the Board Game Library Entry Selector
            mocks.when(mockBGLEntrySelector.SObjectType()).thenReturn(BG_Library_Entry__c.SObjectType);
            mocks.when(mockBGLEntrySelector.selectByEventIDs(
                                            (Set<ID>) fflib_Match.anyObject()
                                        ))
                .thenReturn((List<BG_Library_Entry__c>) params.get(MockParams.RETURNED_BG_LIBRARY_ENTRIES));

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
            mocks.when(mockCalloutService.getBoardGameDetailFromBGGIds(
                                            (Map<Id, String>) fflib_Match.anyObject()
                                        ))
                .thenReturn((BGGCalloutService.CalloutResult) params.get(MockParams.RETURNED_DETAILS_CALLOUT_RESULT));
            mocks.stopStubbing();

            // Set the Selector Mock, Service Mock, and UOW Mock created as the classes to be used 
            // when the Selector, Service, and UOW Classes are initialized from the Application Layer instead of the normal classes
            Application.UnitOfWork.setMock(uowMock);
            Application.Selector.setMock(mockBoardGameSelector);
            Application.Selector.setMock(mockBGLEntrySelector);
            Application.Service.setMock(IBGGCalloutService.class, mockCalloutService);
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
        IBoardGamesService result = BoardGamesService.newInstance();
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
        BoardGamesService service = new BoardGamesService();
        Test.stopTest(); 

        // Validate that serviceConfigMap not only contains values for the BoardGamesService
        // But also contains a config record for each of the methods of the Service 
        Assert.areNotEqual(0, service.serviceConfigMap.size(), 'No Service Configs Found for BoardGames Domain');
        Assert.isTrue(service.serviceConfigMap.containsKey('getBoardGameDetailsFromBGG'), 'Service Config for getBoardGameDetailsFromBGG Method Not Found');
        Assert.isTrue(service.serviceConfigMap.containsKey('updateBoardGameDetailsFromBGG'), 'Service Config for updateBoardGameDetailsFromBGG Method Not Found');
    }
    //#endregion

    //#region //////////////////////////// getBoardGameDetailsFromBGG Tests ////////////////////////////////////////
    // Test Plan
    // Get Board Game Details with Custom Config where Service Disabled
    // Get Board Game Details with Blank Event ID
    // Get Board Game Details with Invalid Event ID
    // Get Board Game Details with Blank Collection Name or ID
    // Get Board Game Details with Failed Result From Getting IDs
    // Get Board Game Details with No Existing Board Games
    // Get Board Game Details with Unprocessed IDs Returned
    // Get Board Game Details with One New Matching Board Game, No Library Entry, and Update Exisiting
    // Get Board Game Details with One New Matching Board Game, No Library Entry, and NOT Update Exisiting
    // Get Board Game Details with One Matching Board Game NOT marked New, No Library Entry, and Update Exisiting
    // Get Board Game Details with One Matching Board Game NOT marked New, No Library Entry, and NOT Update Exisiting
    // Get Board Game Details with One New Matching Board Game, One Library Entry, and Update Exisiting
    // Get Board Game Details with One New Matching Board Game, One Library Entry, and NOT Update Exisiting
    // Get Board Game Details with One Matching Board Game NOT marked New, One Library Entry, and Update Exisiting
    // Get Board Game Details with One Matching Board Game NOT marked New, One Library Entry, and NOT Update Exisiting

    //Start Testing
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
        wrapper.comment = 'This is My Comment';
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '1', // # of New
                                                                        '0', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty did NOT Run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
            
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
                                BG_Library_Entry__c.Comments__c => wrapper.comment,
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
        String unprocessedMsg = String.format(service.UNPROCESSED_FOUND_MSG, new Integer[]{
                                                                                1, // Total Unprocessed
                                                                                2  // Total Found
                                                                            });
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                    '1', // # of New
                                                    '0', // # of Updated
                                                    unprocessedMsg // Unprocessed Message
                                                }), 
                                        result,  
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty Did Not Run,
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
            
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

    // Get Board Game Details with One New Matching Board Game, No Library Entry, and Update Exisiting
    @IsTest
    public static void givenExistingBGFoundMarkedNewAndUpdateTrueAndNoLibEntry_WhenGetBGDetailsCalled_ThenRecordUpdatedAndLibEntryCreated(){

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
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '1', // # of Updated
                                                                        '' // Unprocessed Message
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
        
        //Verify that UOW Register New method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerNew(fflib_Match.sObjectWith(
            //Validate Record in Register New is the same as the Library Entry for the Board Game
            //With comments from the Wrapper 
            new Map<SObjectField,Object> {
                //And that the Values updated match expected
                BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                BG_Library_Entry__c.Event__c => eventId,
                BG_Library_Entry__c.Comments__c => wrapper.comment,
                BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName
            }
        ));
    }

    // Get Board Game Details with One New Matching Board Game, No Library Entry, and NOT Update Exisiting
    @IsTest
    public static void givenExistingBGFoundMarkedNewAndUpdateFalseAndNoLibEntry_WhenGetBGDetailsCalled_ThenRecordUpdatedAndLibEntryCreated(){

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
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '0', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New and Register Dirty Ran the correct Number of Times, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.anySObject());

        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sObjectWith(
                //Validate Record in Register Dirty is the same as the Board Game 
                new Map<SObjectField,Object> {
                    //And that the Values updated match expected
                    Board_Games__c.Id => testBoardGame.Id,
                    Board_Games__c.Is_New__c => false
                }
            ));

        //Verify that UOW Register New method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerNew(fflib_Match.sObjectWith(
            //Validate Record in Register New is the same as the Library Entry for the Board Game
            //With comments from the Wrapper 
            new Map<SObjectField,Object> {
                //And that the Values updated match expected
                //While BGL Entry SHOULD Exist for the Board Game, if it DOESNT
                //Comments and Owner should be null
                BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                BG_Library_Entry__c.Event__c => eventId,
                BG_Library_Entry__c.Comments__c => null,
                BG_Library_Entry__c.BGG_Owner__c => null
            }
        ));
    }

    // Get Board Game Details with One Matching Board Game Not Marked New, No Library Entry, and Update Exisiting
    @IsTest
    public static void givenExistingBGFoundNotMarkedNewAndUpdateTrueAndNoLibEntry_WhenGetBGDetailsCalled_ThenRecordUpdatedAndLibEntryCreated(){

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
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '1', // # of Updated
                                                                        '' // Unprocessed Message
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
            
            //Verify that UOW Register New method Runs Once, 
            ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.sObjectWith(
                //Validate Record in Register New is the same as the Library Entry for the Board Game
                //With comments from the Wrapper 
                new Map<SObjectField,Object> {
                    //And that the Values updated match expected
                    BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                    BG_Library_Entry__c.Event__c => eventId,
                    BG_Library_Entry__c.Comments__c => wrapper.comment,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName
                }
            ));
    }

    // Get Board Game Details with One Matching Board Game Not Marked New, No Library Entry, and NOT Update Exisiting
    @IsTest
    public static void givenExistingBGFoundNotMarkedNewAndUpdateFalseAndNoLibEntry_WhenGetBGDetailsCalled_ThenNoUpdateAndLibEntryCreated(){

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
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '0', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        ///Verify that UOW Register Dirty Did NOT Run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
        .registerDirty(fflib_Match.anySObject());
        
        //Verify that UOW Register New method Ran for the Library Entry, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerNew(fflib_Match.sObjectWith(
            //Validate Record in Register New is the same as the Library Entry for the Board Game
            //With comments from the Wrapper 
            new Map<SObjectField,Object> {
                //And that the Values updated match expected
                BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                BG_Library_Entry__c.Event__c => eventId,
                BG_Library_Entry__c.Comments__c => null,
                BG_Library_Entry__c.BGG_Owner__c => null
            }
        ));
    }

    // Get Board Game Details with One New Matching Board Game, One Library Entry, and Update Exisiting
    @IsTest
    public static void givenExistingBGFoundMarkedNewAndUpdateTrueAndLibEntry_WhenGetBGDetailsCalled_ThenRecordUpdatedAndLibEntryUpdated(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = true
                                            );
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        BG_Library_Entry__c testLibraryEntry = new BG_Library_Entry__c(
                                                ID = fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType),
                                                Board_Game__c = testBoardGame.Id,
                                                //Because we are not actually performing an insert
                                                //This is how we mock a Parent Relationship to the Board Game
                                                Board_Game__r = new Board_Games__c(
                                                    ID = testBoardGame.Id,
                                                    BGG_ID__c = testBoardGame.BGG_ID__c
                                                ),
                                                Comments__c = 'My Old Comment',
                                                BGG_Owner__c = 'OG Owner',
                                                Event__c = eventId
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame},
            MockParams.RETURNED_BG_LIBRARY_ENTRIES => new List<BG_Library_Entry__c>{testLibraryEntry}
        };
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '1', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New and Register Dirty Ran the correct Number of Times, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerNew(fflib_Match.anySObject());
        
        //Verify that UOW Register Dirty method Runs Once for the Board Game, 
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
        
        //Verify that UOW Register Dirty method Runs Once for BGL Entry, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerDirty(fflib_Match.sObjectWith(
            //Validate Record in Register Dirty is the same as the Library Entry for the Board Game
            //With comments from the Wrapper 
            new Map<SObjectField,Object> {
                //And that the Values updated match expected
                BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                BG_Library_Entry__c.Event__c => eventId,
                BG_Library_Entry__c.Comments__c => wrapper.comment,
                BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName
            }
        ));
    }
    
    // Get Board Game Details with One New Matching Board Game, One Library Entry, and NOT Update Exisiting
    @IsTest
    public static void givenExistingBGFoundMarkedNewAndUpdateFalseAndLibEntry_WhenGetBGDetailsCalled_ThenOnlyBGRecordUpdated(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = true
                                            );
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        BG_Library_Entry__c testLibraryEntry = new BG_Library_Entry__c(
                                                ID = fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType),
                                                Board_Game__c = testBoardGame.Id,
                                                //Because we are not actually performing an insert
                                                //This is how we mock a Parent Relationship to the Board Game
                                                Board_Game__r = new Board_Games__c(
                                                    ID = testBoardGame.Id,
                                                    BGG_ID__c = testBoardGame.BGG_ID__c
                                                ),
                                                Comments__c = 'My Old Comment',
                                                BGG_Owner__c = 'OG Owner',
                                                Event__c = eventId
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_ID_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame},
            MockParams.RETURNED_BG_LIBRARY_ENTRIES => new List<BG_Library_Entry__c>{testLibraryEntry}
        };
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '0', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New and Register Dirty Ran the correct Number of Times, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerNew(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Runs Once for Board Game
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sObjectWith(
                //Validate Record in Register Dirty is the same as the Board Game 
                new Map<SObjectField,Object> {
                    //And that the Values updated match expected
                    Board_Games__c.Id => testBoardGame.Id,
                    Board_Games__c.Is_New__c => false
                }
            ));

        //Verify that UOW Register Dirty method did NOT Run for BGL Entry, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
        .registerDirty(fflib_Match.sObjectWith(
            //Validate Record in Register Dirty is the same as the Library Entry for the Board Game
            //With comments from the Wrapper 
            new Map<SObjectField,Object> {
                //And that the Values updated match expected
                BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                BG_Library_Entry__c.Event__c => eventId,
                BG_Library_Entry__c.Comments__c => wrapper.comment,
                BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName
            }
        ));
    }

    // Get Board Game Details with One Matching Board Game Not Marked New, One Library Entry, and Update Exisiting
    @IsTest
    public static void givenExistingBGFoundNotMarkedNewAndUpdateTrueAndLibEntry_WhenGetBGDetailsCalled_ThenRecordUpdatedAndLibEntryUpdated(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = false
                                            );
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        BG_Library_Entry__c testLibraryEntry = new BG_Library_Entry__c(
                                                ID = fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType),
                                                Board_Game__c = testBoardGame.Id,
                                                //Because we are not actually performing an insert
                                                //This is how we mock a Parent Relationship to the Board Game
                                                Board_Game__r = new Board_Games__c(
                                                    ID = testBoardGame.Id,
                                                    BGG_ID__c = testBoardGame.BGG_ID__c
                                                ),
                                                Comments__c = 'My Old Comment',
                                                BGG_Owner__c = 'OG Owner',
                                                Event__c = eventId
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame},
            MockParams.RETURNED_BG_LIBRARY_ENTRIES => new List<BG_Library_Entry__c>{testLibraryEntry}
        };
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '1', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);
        
        //Verify that UOW Register New method did NOT Run
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerNew(fflib_Match.anySObject());         

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
            
        //Verify that UOW Register New method Runs Once, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sObjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry for the Board Game
                //With comments from the Wrapper 
                new Map<SObjectField,Object> {
                    //And that the Values updated match expected
                    BG_Library_Entry__c.Board_Game__c => testBoardGame.Id,
                    BG_Library_Entry__c.Event__c => eventId,
                    BG_Library_Entry__c.Comments__c => wrapper.comment,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName
                }
            ));
    }
    
    // Get Board Game Details with One Matching Board Game Not Marked New, One Library Entry, and NOT Update Exisiting
    @IsTest
    public static void givenExistingBGFoundNotMarkedNewAndUpdateFalseAndLibEntry_WhenGetBGDetailsCalled_ThenNoUpdate(){

        //Setup Test Data and Mocking
        Board_Games__c testBoardGame = new Board_Games__c(
                                                ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                                BGG_ID__c = '1234',
                                                Name = 'My Board Game',
                                                Is_New__c = false
                                            );
        ID eventId = fflib_IDGenerator.generate(Event__c.SObjectType);
        BG_Library_Entry__c testLibraryEntry = new BG_Library_Entry__c(
                                                ID = fflib_IDGenerator.generate(BG_Library_Entry__c.SObjectType),
                                                Board_Game__c = testBoardGame.Id,
                                                //Because we are not actually performing an insert
                                                //This is how we mock a Parent Relationship to the Board Game
                                                Board_Game__r = new Board_Games__c(
                                                    ID = testBoardGame.Id,
                                                    BGG_ID__c = testBoardGame.BGG_ID__c
                                                ),
                                                Comments__c = 'My Old Comment',
                                                BGG_Owner__c = 'OG Owner',
                                                Event__c = eventId
                                            );
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = testBoardGame;
        wrapper.comment = 'This is My Comment';
        wrapper.ownerName = 'OwnerName';
        calloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            testBoardGame.BGG_ID__c => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_ID_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult,
            MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame},
            MockParams.RETURNED_BG_LIBRARY_ENTRIES => new List<BG_Library_Entry__c>{testLibraryEntry}
        };
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
        Assert.areEqual(String.format(service.SUCCESS_MSG, new String[]{
                                                                        '0', // # of New
                                                                        '0', // # of Updated
                                                                        '' // Unprocessed Message
                                                                    }), 
                                        result, 
                                        'Result Message does not match Expected: '+result);

        ///Verify that UOW Register Dirty Did NOT Run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
        .registerDirty(fflib_Match.anySObject());
        
        //Verify that UOW Register New Did NOT Run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
        .registerNew(fflib_Match.anySObject());
    }
    //#endregion

    //#region //////////////////////////// updateBoardGameDetailsFromBGG Tests ////////////////////////////////////////
    //Test Plan
    // Update Board Game Details with Custom Config where Service Disabled
    // Update Board Game Details with Empty or Null ID/String Map
    // Update Board Game Details with Failed Result Message from HTTP Service
    // Update Board Game Details with Unprocessed IDs
    // Update Board Game Details with No Results returned from HTTP Service
    // Update Board Game Details with Results Returned
    // Update Board Game Details with Multiple Results Returned
    
    //Start Testing
    // Update Board Game Details with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenUpdateBGDetailsCalled_ThenErrorThrown(){
        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';
        mock.mockConfig.Service_Enabled__c = false;

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBoardGameDetailsFromBGG(mock.uowMock, 
                                            new Map<Id,String>{
                                                fflib_IDGenerator.generate(Board_Games__c.SObjectType) => '12345'
                                            });
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.SERVICE_NOT_ENABLED_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update Board Game Details with Empty or Null ID/String Map
    @IsTest
    public static void givenNoIDs_WhenUpdateBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{};

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBoardGameDetailsFromBGG(mock.uowMock, null);
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.NO_RECORD_IDS_PROVIDED_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update Board Game Details with Failed Result Message from HTTP Service
    @IsTest
    public static void givenNoBGGDetailsReturned_WhenUpdateBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult calloutResult = new BGGCalloutService.CalloutResult();
        calloutResult.resultMessage = 'No New Games Found';

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => calloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBoardGameDetailsFromBGG(mock.uowMock, 
                                            new Map<Id,String>{
                                                fflib_IDGenerator.generate(Board_Games__c.SObjectType) => '12345'
                                            });
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual('No New Games Found', errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update Board Game Details with Unprocessed IDs
    @IsTest
    public static void givenUnprocessedIds_WhenUpdateBGDetailsCalled_ThenCorrectMessageReturned(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult detailCalloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper processedWrapper = new BGGCalloutService.BoardGameWrapper();
        processedWrapper.boardGame = new Board_Games__c(
                                        ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                        BGG_ID__c = '12345',
                                        Name = 'My Board Game',
                                        Is_New__c = true
                                    );
    
        BGGCalloutService.BoardGameWrapper unprocessedWrapper = new BGGCalloutService.BoardGameWrapper();
        unprocessedWrapper.boardGame = new Board_Games__c(
                                        ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                        BGG_ID__c = '56789',
                                        Name = 'My Unprocessed Board Game',
                                        Is_New__c = true
                                    );

        detailCalloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            '12345' => processedWrapper,
            '56789' => unprocessedWrapper
        };
        detailCalloutResult.unprocessedIDs = new Set<String>{'56789'};

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => detailCalloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBoardGameDetailsFromBGG(mock.uowMock, 
                                            new Map<Id,String>{
                                                fflib_IDGenerator.generate(Board_Games__c.SObjectType) => '12345'
                                            });
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        String unprocessedMsg = String.format(service.UNPROCESSED_FOUND_MSG, new Integer[]{
                                                                                1, // Total Unprocessed
                                                                                2  // Total Found
                                                                            });
        Assert.areEqual(String.format(service.UPDATE_RECORD_SUCCESS_MSG, new String[]{
                                                                                processedWrapper.boardGame.Name, //List of Board Game Names
                                                                                unprocessedMsg // Unprocessed Message
                                                                            }), 
                                        result,  
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register New Did Not Run,
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerNew(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Ran Once for the Board Game
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register dirty is the same as the Board Game in the detailCalloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    Board_Games__c.ID => processedWrapper.boardGame.Id,
                    Board_Games__c.BGG_ID__c => processedWrapper.boardGame.BGG_ID__c,
                    Board_Games__c.Name => processedWrapper.boardGame.Name,
                    Board_Games__c.Is_New__c => false
                }
            ));

        //Verify that UOW Register Dirty method DID NOT Run for the Unprocessed Board Game
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is NOT the same as the Unprocessed 
                // Board Game in the detailCalloutResult 
                new Map<Schema.SObjectField, Object>{
                    Board_Games__c.ID => unprocessedWrapper.boardGame.Id,
                    Board_Games__c.BGG_ID__c => unprocessedWrapper.boardGame.BGG_ID__c,
                    Board_Games__c.Name => unprocessedWrapper.boardGame.Name,
                    Board_Games__c.Is_New__c => false
                }
            ));
    }

    // Update Board Game Details with No Results returned from HTTP Service
    @IsTest
    public static void givenNoUpdatedBGGDetailsReturned_WhenUpdateBGDetailsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult detailCalloutResult = new BGGCalloutService.CalloutResult();   
        detailCalloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>();

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => detailCalloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBoardGameDetailsFromBGG(mock.uowMock, 
                                            new Map<Id,String>{
                                                fflib_IDGenerator.generate(Board_Games__c.SObjectType) => '12345'
                                            });
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.NO_RECORDS_UPDATED_ERR_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);

        //Verify that UOW Register Dirty Did Not Run,
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
    }

    // Update Board Game Details with Results Returned
    @IsTest
    public static void givenUpdatedBGGDetailsReturned_WhenUpdateBGDetailsCalled_ThenBoardGameUpdated(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult detailCalloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.boardGame = new Board_Games__c(
                                        ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                        BGG_ID__c = '12345',
                                        Name = 'My Board Game',
                                        Is_New__c = true
                                    );
    
        detailCalloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            '12345' => wrapper
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => detailCalloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBoardGameDetailsFromBGG(mock.uowMock, 
                                            new Map<Id,String>{
                                                fflib_IDGenerator.generate(Board_Games__c.SObjectType) => '12345'
                                            });
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        Assert.areEqual(String.format(service.UPDATE_RECORD_SUCCESS_MSG, new String[]{
                                                                                wrapper.boardGame.Name, //List of Board Game Names
                                                                                '' // Unprocessed Message
                                                                            }), 
                                        result,  
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty method Ran Once for the Board Game
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register dirty is the same as the Board Game in the detailCalloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    Board_Games__c.ID => wrapper.boardGame.Id,
                    Board_Games__c.BGG_ID__c => wrapper.boardGame.BGG_ID__c,
                    Board_Games__c.Name => wrapper.boardGame.Name,
                    Board_Games__c.Is_New__c => false
                }
            ));
    }

    // Update Board Game Details with Multiple Results Returned
    @IsTest
    public static void givenMultipleUpdatedBGGDetailsReturned_WhenUpdateBGDetailsCalled_ThenMultipleBoardGamesUpdated(){

        //Setup Test Data and Mocking
        BGGCalloutService.CalloutResult detailCalloutResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper1 = new BGGCalloutService.BoardGameWrapper();
        wrapper1.boardGame = new Board_Games__c(
                                        ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                        BGG_ID__c = '12345',
                                        Name = 'My First Board Game',
                                        Is_New__c = true
                                    );
        BGGCalloutService.BoardGameWrapper wrapper2 = new BGGCalloutService.BoardGameWrapper();
        wrapper2.boardGame = new Board_Games__c(
                                        ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                        BGG_ID__c = '67890',
                                        Name = 'My Second Board Game',
                                        Is_New__c = true
                                    );
                        
    
        detailCalloutResult.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            '12345' => wrapper1,
            '67890' => wrapper2
        };

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_DETAILS_CALLOUT_RESULT => detailCalloutResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBoardGameDetailsFromBGG';

        //Run Test
        Test.startTest();
        BoardGamesService service = new BoardGamesService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBoardGameDetailsFromBGG(mock.uowMock, 
                                            new Map<Id,String>{
                                                fflib_IDGenerator.generate(Board_Games__c.SObjectType) => '12345'
                                            });
        Test.stopTest();

        //Validate Data
        //Verify Result Message
        List<String> names = new List<String>{wrapper1.boardGame.Name, wrapper2.boardGame.Name};
        Assert.areEqual(String.format(service.UPDATE_RECORD_SUCCESS_MSG, new String[]{
                                                                                String.join(names, ', '), //List of Board Game Names
                                                                                '' // Unprocessed Message
                                                                            }), 
                                        result,  
                                        'Result Message does not match Expected: '+result);

        //Verify that UOW Register Dirty method Ran for the First Board Game
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register dirty is the same as the Board Game in the detailCalloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    Board_Games__c.ID => wrapper1.boardGame.Id,
                    Board_Games__c.BGG_ID__c => wrapper1.boardGame.BGG_ID__c,
                    Board_Games__c.Name => wrapper1.boardGame.Name,
                    Board_Games__c.Is_New__c => false
                }
            ));
        
        //Verify that UOW Register Dirty method Ran for the Second Board Game
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
        .registerDirty(fflib_Match.sobjectWith(
            //Validate Record in Register dirty is the same as the Board Game in the detailCalloutResult 
            new Map<Schema.SObjectField, Object>{
                //And that the Values inserted match expected
                Board_Games__c.ID => wrapper2.boardGame.Id,
                Board_Games__c.BGG_ID__c => wrapper2.boardGame.BGG_ID__c,
                Board_Games__c.Name => wrapper2.boardGame.Name,
                Board_Games__c.Is_New__c => false
            }
        ));
    }
    //#endregion

}