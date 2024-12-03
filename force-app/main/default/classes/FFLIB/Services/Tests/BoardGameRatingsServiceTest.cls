/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Rating Service Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* Makes use of the MockSetup Test Pattern to stub out the Selectors used in the Controller.
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
private class BoardGameRatingsServiceTest {

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
        RETURNED_BOARD_GAME_RATINGS
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_BOARD_GAME_RATINGS => List<Board_Game_Rating__c>.class
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
            IBoardGameRatingSelector mockBGRSelector = (IBoardGameRatingSelector) mocks.mock(BoardGameRatingSelector.class);
            
            mockConfig = new Services_Config__mdt(
                                        Domain_Config__r = new Domain_Config__mdt(
                                            DeveloperName = 'BoardGameRatings'),
                                        Service_Enabled__c = true
                                    );
            
            mocks.startStubbing();
            //Stubbing the BGR Selector
            //IMPORTANT: Stubbing the SObjectType is REQUIRED or the mocking of the Selector WILL Fail
            mocks.when(mockBGRSelector.SObjectType()).thenReturn(Board_Game_Rating__c.SObjectType);
            //Stub out each Selector Method that the Service calls using calls
            mocks.when(mockBGRSelector.selectFavoriteRatingByAttendeeIdExcludingRecordID(
                                            //Using fflib_Match here tells the mock to replace this method
                                            //Regardless of what values are given to the method  
                                            (Set<Id>) fflib_Match.anyObject(),
                                            (Set<Id>) fflib_Match.anyObject()
                ))
                // The Mocked Selector will BYPASS calling of the actual method and instead just return
                // the Value in the Params Map that was passed in for the Enum Key RETURNED_BOARD_GAME_RATINGS
                // If no value was provided, a newInstance of the Object (List<Board_Game_Rating__c>) was created
                // and we will return that here instead
                .thenReturn((List<Board_Game_Rating__c>) params.get(MockParams.RETURNED_BOARD_GAME_RATINGS));
            //Any Methods of the Selector that are NOT Stubbed will return a NULL value if called
            mocks.stopStubbing();

            // Set the Selector Mock and UOW Mock created as the classes to be used 
            // when the Selector and UOW Classes are initialized from the Application Layer instead of the normal classes
            Application.UnitOfWork.setMock(uowMock);
            Application.Selector.setMock(mockBGRSelector);
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
        BoardGameRatingsService service = new BoardGameRatingsService();
        Test.stopTest(); 

        // Validate that serviceConfigMap not only contains values for the BoardGameRatingsService
        // But also contains a config record for each of the methods of the Service 
        Assert.areNotEqual(0, service.serviceConfigMap.size(), 'No Service Configs Found for BoardGameRatingsDomain');
        Assert.isTrue(service.serviceConfigMap.containsKey('setNewFavorite'), 'Service Config for setNewFavorite Method Not Found');
    }

    ////////////////////////////// SetNewFavorite Tests ////////////////////////////////////////
    // Test Plan
    // Call Service with Custom Config where Service Disabled
    // BGR Set As Fav with no other Fav BGRs
    // BGR Set as Fav with 1 Favorite BGR
    // BGR NOT Set as Fav with 1 Favorite BGR
    // BGR Set as Fav with multiple Favorite BGR 
    // Multiple BGRs Set as Fav with 1 Favorite BGR
    // Multiple BGRs Set as Fav for Multiple Attendees each with 1 Favorite BGR

    // Call setNewFavorite Service Method with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenSetNewFavoriteCalled_ThenNothingHappens(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BOARD_GAME_RATINGS => new List<Board_Game_Rating__c>{new Board_Game_Rating__c(
                                                        Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                        is_Favorite__c = true
                                                    )}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';
        mock.mockConfig.Service_Enabled__c = false;

        // Setup Test Data without DML that would be updated if the service was enabled to validate no change is made
        
        // Create testRecord Using sObject_Fabricator
            // Test Records CAN be created the same way using just new Board_Game_Rating__c() and get the same result
            // However since read-only or calcuated fields like formula fields or rollups cannot be set using that method
            // sObject_Fabricator can be used to mock those values without performing the DML
        Board_Game_Rating__c testNewRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        // For the Existing Record we only need to see the Is_Favorite__c value was false
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
        service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewRecord}, 
                                new Map<Id,SObject>{testNewRecord.Id => testOldRecord});
        Test.stopTest();

        //Validate Data
        //Verify that UOW Register Dirty method did NOT run
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
    }

    // BGR Set As Fav with no other Fav BGRs
    @IsTest
    public static void givenNoOtherBGRRecords_WhenFavoriteBGRRecordUpdated_ThenNoUpdate(){

        //Setup Test Data and Mocking
        //Setup Return Values
        //By Not addeding Anything to the Params Map, the return value from the Selector will be an emptry list
        Map<MockParams, Object> params = new Map<MockParams, Object>{};

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';

        // Setup Test Data 
            //(Once Test Data is setup in a method, it is Copied Over from Previous Method 
            // with minor tweaks made based on the Tested Use Case)
        Board_Game_Rating__c testNewRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
        service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewRecord}, 
                                new Map<Id,SObject>{testNewRecord.Id => testOldRecord});
        Test.stopTest();

        //Validate Data
        //Verify that UOW Register Dirty method did NOT run
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
    }

    // BGR Set as Fav with 1 Favorite BGR
    @IsTest
    public static void given1FavBGRRecord_WhenFavoriteBGRRecordUpdated_ThenGivenRecordUpdated(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Board_Game_Rating__c returnedBGR = new Board_Game_Rating__c(
                                                Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                is_Favorite__c = true
                                            );

        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BOARD_GAME_RATINGS => new List<Board_Game_Rating__c>{returnedBGR}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';

        // Setup Test Data
            // (Once Test Data is setup in a method, it is Copied Over from Previous Method 
            // with minor tweaks made based on the Tested Use Case)
        Board_Game_Rating__c testNewRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
        service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewRecord}, 
                                new Map<Id,SObject>{testNewRecord.Id => testOldRecord});
        Test.stopTest();

        //Validate Data
        //Verify that UOW RegisterDirty Ran Only Once
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    //Validate Record in Register Dirty is the same record returned from the Selector
                    //And that the Values updated (is Favorite) is set to false
                    Board_Game_Rating__c.Id => returnedBGR.Id,
                    Board_Game_Rating__c.is_Favorite__c => false
                }
            ));
    }

    // BGR NOT Set as Fav with 1 Favorite BGR
    @IsTest
    public static void given1FavBGRRecord_WhenNonFavoriteBGRRecordUpdated_ThenNoUpdate(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Board_Game_Rating__c returnedBGR = new Board_Game_Rating__c(
                                                Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                is_Favorite__c = true
                                            );

        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BOARD_GAME_RATINGS => new List<Board_Game_Rating__c>{returnedBGR}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';

        // Setup Test Data
            // (Once Test Data is setup in a method, it is Copied Over from Previous Method 
            // with minor tweaks made based on the Tested Use Case)
        Board_Game_Rating__c testNewRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
        service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewRecord}, 
                                new Map<Id,SObject>{testNewRecord.Id => testOldRecord});
        Test.stopTest();

        //Validate Data
        //Verify that UOW Register Dirty method did NOT run
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
    }

    // BGR Set as Fav with multiple Favorite BGR 
    @IsTest
    public static void givenMultipleFavBGRRecord_WhenFavoriteBGRRecordUpdated_ThenUpdateAllGivenRecords(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Board_Game_Rating__c returnedBGR1 = new Board_Game_Rating__c(
                                                Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                is_Favorite__c = true
                                            );
        Board_Game_Rating__c returnedBGR2 = new Board_Game_Rating__c(
                                                Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                is_Favorite__c = true
                                            );

        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BOARD_GAME_RATINGS => new List<Board_Game_Rating__c>{returnedBGR1, returnedBGR2}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';

        // Setup Test Data
            // (Once Test Data is setup in a method, it is Copied Over from Previous Method 
            // with minor tweaks made based on the Tested Use Case)
        Board_Game_Rating__c testNewRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
        service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewRecord}, 
                                new Map<Id,SObject>{testNewRecord.Id => testOldRecord});
        Test.stopTest();

        //Validate Data
        //Verify that UOW Register Dirty method Ran Twice
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    //Validate Record in Register Dirty is the same as the first record returned from the Selector
                    //And that the Values updated (is Favorite) is set to false
                    Board_Game_Rating__c.Id => returnedBGR1.Id,
                    Board_Game_Rating__c.is_Favorite__c => false
                }
            ));
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    //Validate Record in Register Dirty is the same as the second record returned from the Selector
                    //And that the Values updated (is Favorite) is set to false
                    Board_Game_Rating__c.Id => returnedBGR2.Id,
                    Board_Game_Rating__c.is_Favorite__c => false
                }
            ));
    }

    // Multiple BGRs Set as Fav with 1 Favorite BGR
    @IsTest
    public static void givenFavBGRRecord_WhenFavAndNonFavBGRRecordUpdated_ThenUpdateAllGivenRecords(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Board_Game_Rating__c returnedBGR = new Board_Game_Rating__c(
                                                Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                is_Favorite__c = true
                                            );

        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BOARD_GAME_RATINGS => new List<Board_Game_Rating__c>{returnedBGR}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';

        // Setup Test Data
            // (Once Test Data is setup in a method, it is Copied Over from Previous Method 
            // with minor tweaks made based on the Tested Use Case)
        Board_Game_Rating__c testNewFavRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testNewNonFavRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, 
                                                fflib_IDGenerator.generate(Event_Attendee__c.SObjectType))
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
        service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewFavRecord, testNewNonFavRecord}, 
                                new Map<Id,SObject>{testNewFavRecord.Id => testOldRecord,
                                                    testNewNonFavRecord.Id => testOldRecord 
                                                });
        Test.stopTest();

        //Validate Data
        //Verify that UOW Register Dirty method Ran Twice
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    //Validate Record in Register Dirty is the same as the first record returned from the Selector
                    //And that the Values updated (is Favorite) is set to false
                    Board_Game_Rating__c.Id => returnedBGR.Id,
                    Board_Game_Rating__c.is_Favorite__c => false
                }
            ));
    }

    // Multiple BGRs Set as Fav for Multiple Attendees each with 1 Favorite BGR
    @IsTest
    public static void givenFavBGRRecord_WhenMultipleFavBGRRecordsUpdated_ThenThrowError(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Board_Game_Rating__c returnedBGR = new Board_Game_Rating__c(
                                                Id = fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType),
                                                is_Favorite__c = true
                                            );


        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_BOARD_GAME_RATINGS => new List<Board_Game_Rating__c>{returnedBGR}
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'setNewFavorite';

        // Setup Test Data
            // (Once Test Data is setup in a method, it is Copied Over from Previous Method 
            // with minor tweaks made based on the Tested Use Case)
        Id eventAttendeeId = fflib_IDGenerator.generate(Event_Attendee__c.SObjectType);
        Board_Game_Rating__c testNewFavRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, eventAttendeeId)
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testNew2ndFavRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, true)
                                    .setField(Board_Game_Rating__c.Event_Attendee__c, eventAttendeeId)
                                    .setField(Board_Game_Rating__c.Id,
                                                fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType))
                                    .toSObject();
        Board_Game_Rating__c testOldRecord = (Board_Game_Rating__c) new sfab_FabricatedSObject(Board_Game_Rating__c.class)
                                    .setField(Board_Game_Rating__c.is_Favorite__c, false)
                                    .toSObject();

        //Run Test
        Test.startTest();
        String errMsg = 'No Error Found';
        try {
            BoardGameRatingsService service = new BoardGameRatingsService(new List<Services_Config__mdt>{mock.mockConfig});
            service.setNewFavorite(mock.uowMock, 
                                new List<Board_Game_Rating__c>{testNewFavRecord, testNew2ndFavRecord}, 
                                new Map<Id,SObject>{testNewFavRecord.Id => testOldRecord,
                                                    testNew2ndFavRecord.Id => testOldRecord 
                                                });
            Assert.isTrue(false, 'Error Not Caught');
        } catch (Exception ex) {
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        //Verify the Error was caught
        Assert.areEqual('Duplicate Favorite Found', errMsg, 'Incorrect Error Message: '+errMsg);
    }

    ////////////////////////////// End SetNewFavorite Tests ////////////////////////////////////////

}