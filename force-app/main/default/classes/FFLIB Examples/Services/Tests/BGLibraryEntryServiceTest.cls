/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Library Entry Service Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* This Test Class has a dozen Test Methods which might seem like a LOT but once the first test method is
* written, it can then be copied over to the next one and only slight variation needs to be made
* for the next test class based on the inputs changed and the different results. 
*
* Makes use of the MockSetup Test Pattern to stub out the Selectors 
* and BGG API Callout Service used in the Service.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-03
* @modified       2025-02-13
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public with sharing class BGLibraryEntryServiceTest {
    
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
        RETURNED_GEEKLIST_CALLOUT_RESULT,
        RETURNED_COLLECTION_CALLOUT_RESULT
    }

    static Map<MockParams, Type> paramTypes {
        get {
            return new Map<MockParams, Type>{
                MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => BGGCalloutService.CalloutResult.class,                
                MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => BGGCalloutService.CalloutResult.class
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
            uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
            IBGGCalloutService mockCalloutService = (IBGGCalloutService) mocks.mock(BGGCalloutService.class);
            
            mockConfig = new Services_Config__mdt(
                                        Domain_Config__r = new Domain_Config__mdt(
                                            DeveloperName = 'BGLibraryEntry'),
                                        Service_Enabled__c = true
                                    );
            
            mocks.startStubbing();
            
            //Stubbing the BGGCalloutService
            mocks.when(mockCalloutService.getIDsFromBoardGameGeek(
                                            fflib_Match.anyString(),
                                            fflib_Match.eqBoolean(true)
                                        ))
                .thenReturn((BGGCalloutService.CalloutResult) params.get(MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT));
            mocks.when(mockCalloutService.getIDsFromBoardGameGeek(
                                            fflib_Match.anyString(),
                                            fflib_Match.eqBoolean(false)
                                        ))
                //Using Seperate Return Value for the Second Callout 
                .thenReturn((BGGCalloutService.CalloutResult) params.get(MockParams.RETURNED_COLLECTION_CALLOUT_RESULT));
            mocks.stopStubbing();
            
            //Set the Service Mock and UOW Mock created as the classes to be used 
            // when the Service and UOW Classes are initialized from the Application Layer instead of the normal classes
            Application.UnitOfWork.setMock(uowMock);
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
        IBGLibraryEntryService result = BGLibraryEntryService.newInstance();
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
        BGLibraryEntryService service = new BGLibraryEntryService();
        Test.stopTest(); 

        // Validate that serviceConfigMap not only contains values for the BoardGamesService
        // But also contains a config record for each of the methods of the Service 
        Assert.areNotEqual(0, service.serviceConfigMap.size(), 'No Service Configs Found for BGLibraryEntry Domain');
        Assert.isTrue(service.serviceConfigMap.containsKey('updateBGLibraryEntryFromBGG'), 'Service Config for updateBGLibraryEntryFromBGG Method Not Found');
    }
    //#endregion

    //#region //////////////////////////// updateBGLibraryEntryFromBGG Tests ////////////////////////////////////////
    //Test Plan
    // Update BGLE Details with Custom Config where Service Disabled
    // Update BGLE Details with Empty List
    // Update BGLE Details with No Source and with No Results Returned
    // Update BGLE Details with GeekList Source with Error Results Returned
    // Update BGLE Details with Collection Source with Error Results Returned
    // Update BGLE Details with Both GeekList and Collection Sources with Error Results Returned
    // Update BGLE Details with GeekList Source with Correct Results Returned
    // Update BGLE Details with Collection Source with Correct Results Returned
    // Update BGLE Details with Both Sources with Correct Results Returned
    // Update BGLE Details with Both Sources with Mix of Correct Results Returned and Error Messages
    // Update BGLE Details with No Matching BBG IDs

    //Start Testing
    // Get Board Game Details with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenUpdateBGLECalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';
        mock.mockConfig.Service_Enabled__c = false;

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBGLibraryEntriesFromBGG(mock.uowMock, 
                                                    new List<BG_Library_Entry__c>());
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(BGLibraryEntryService.SERVICE_NOT_ENABLED_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update BGLE Details with Empty List
    @IsTest
    public static void givenEmptyList_WhenUpdateBGLECalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBGLibraryEntriesFromBGG(mock.uowMock, 
                                                    new List<BG_Library_Entry__c>());
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(BGLibraryEntryService.NO_RECORDS_PROVIDED_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update BGLE Details with No Source and with No Results Returned
    @IsTest
    public static void givenBGLEntryGeekListRecordWithoutSource_WhenUpdateBGLECalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '98765') // This is a Formula Field
                                                                 .toSObject();
        
        BGGCalloutService.CalloutResult result = new BGGCalloutService.CalloutResult();

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => result
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBGLibraryEntriesFromBGG(mock.uowMock, 
                                                    new List<BG_Library_Entry__c>{testBGLEntry});
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.ERROR_RECORD_MISSING_SOURCE_ID, 
                                        new List<String>{
                                            testBGLEntry.BoardGameName__c
                                        }
                                    ), errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update BGLE Details with GeekList Source with Error Results Returned
    @IsTest
    public static void givenBGLEntryGeekListRecordWithSource_WhenUpdateBGLECalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Source__c, '12345')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.GEEKLIST)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '98765') // This is a Formula Field
                                                                 .toSObject();
                                                                 
        
        BGGCalloutService.CalloutResult geekListResult = new BGGCalloutService.CalloutResult();
        geekListResult.resultMessage = 'Too Many Callouts';
        geekListResult.unprocessedIDs.add('6789');

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => geekListResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBGLibraryEntriesFromBGG(mock.uowMock, 
                                                    new List<BG_Library_Entry__c>{testBGLEntry});
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.ERROR_TOO_MANY_CALLOUTS, 
                                        new List<String>{
                                            geekListResult.resultMessage
                                        }
                                    ), errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update BGLE Details with Collection Source with Error Results Returned
    @IsTest
    public static void givenBGLEntryCollectionRecordWithSource_WhenUpdateBGLECalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Source__c, '12345')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.COLLECTION)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '98765') // This is a Formula Field
                                                                 .toSObject();
                                                                 
        
        BGGCalloutService.CalloutResult collectionResult = new BGGCalloutService.CalloutResult();
        collectionResult.resultMessage = 'Too Many Callouts';
        collectionResult.unprocessedIDs.add('6789');

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => collectionResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBGLibraryEntriesFromBGG(mock.uowMock, 
                                                    new List<BG_Library_Entry__c>{testBGLEntry});
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.ERROR_TOO_MANY_CALLOUTS, 
                                        new List<String>{
                                            collectionResult.resultMessage
                                        }
                                    ), errMessage, 'Error Message Does Not Match: '+ errMessage);
    }

    // Update BGLE Details with Both GeekList and Collection Sources with Error Results Returned
    @IsTest
    public static void givenBGLEntryCollectionAndGeekListRecordsWithSources_WhenUpdateBGLECalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testGeekListBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Source__c, 'GeekID')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.GEEKLIST)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '12345') // This is a Formula Field
                                                                 .toSObject();
        
        BG_Library_Entry__c testCollectionBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                 .setField(BG_Library_Entry__c.Source__c, 'ColName')
                                                                 .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.COLLECTION)
                                                                 .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                 .setField(BG_Library_Entry__c.BGG_Id__c, '98765') // This is a Formula Field
                                                              .toSObject();

        
        BGGCalloutService.CalloutResult collectionResult = new BGGCalloutService.CalloutResult();
        collectionResult.resultMessage = 'Collection Error.';
        collectionResult.unprocessedIDs.add('CollectionID');

        BGGCalloutService.CalloutResult geekListResult = new BGGCalloutService.CalloutResult();
        geekListResult.resultMessage = 'GeekList Error.';
        geekListResult.unprocessedIDs.add('GeekID');        

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => collectionResult,
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => geekListResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.updateBGLibraryEntriesFromBGG(mock.uowMock, 
                                                    new List<BG_Library_Entry__c>{testGeekListBGLEntry, testCollectionBGLEntry});
            Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.ERROR_TOO_MANY_CALLOUTS, 
                                        new List<String>{
                                            geekListResult.resultMessage //GeekList Message 1st
                                        })
                + ' ' + String.Format(BGLibraryEntryService.ERROR_TOO_MANY_CALLOUTS, 
                                        new List<String>{
                                            collectionResult.resultMessage //Collection Message 2nd
                                        }),
                                    errMessage, 'Error Message Does Not Match');
    }

    // Update BGLE Details with GeekList Source with Correct Results Returned
    @IsTest
    public static void givenBGLEntryGeekListRecordWithSource_WhenUpdateBGLECalled_ThenCorrectResultsReturned(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        String bggId = '12345';
        BG_Library_Entry__c testBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                    .setField(BG_Library_Entry__c.Source__c, 'GeekID')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.GEEKLIST)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, bggId) // This is a Formula Field
                                                                 .toSObject();

        BGGCalloutService.CalloutResult geekListResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.comment = 'This is my Comment';
        wrapper.ownerName = 'My Name';
        geekListResult.wrapperMap.put(bggId, wrapper);

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => geekListResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBGLibraryEntriesFromBGG(mock.uowMock, new List<BG_Library_Entry__c>{testBGLEntry});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.SUCCESS_MSG, 
                                        new List<String>{
                                            '1', //Total Updated
                                            ''   //Error Messages
                                        }),
                                        result, 'Return Result Message Does Not Match: '+ result);
        
        //Verify that UOW Register Dirty did Run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Ran For the Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => bggId,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));
    }

    // Update BGLE Details with Collection Source with Correct Results Returned
    @IsTest
    public static void givenBGLEntryCollectionRecordWithSource_WhenUpdateBGLECalled_ThenCorrectResultsReturned(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        String bggId = '12345';
        BG_Library_Entry__c testBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                    .setField(BG_Library_Entry__c.Source__c, 'CollectionId')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.COLLECTION)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, bggId) // This is a Formula Field
                                                                 .toSObject();

        BGGCalloutService.CalloutResult collectionResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.comment = 'This is my Comment';
        wrapper.ownerName = 'My Name';
        collectionResult.wrapperMap.put(bggId, wrapper);

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => collectionResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBGLibraryEntriesFromBGG(mock.uowMock, new List<BG_Library_Entry__c>{testBGLEntry});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.SUCCESS_MSG, 
                                        new List<String>{
                                            '1', //Total Updated
                                            ''   //Error Messages
                                        }),
                                        result, 'Return Result Message Does Not Match: '+ result);
        
        //Verify that UOW Register Dirty did Run, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Ran For the Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => bggId,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));
    }

    // Update BGLE Details with Both Sources with Correct Results Returned
    @IsTest
    public static void givenBGLEntryCollectionAndGeekListRecordsWithSources_WhenUpdateBGLECalled_ThenCorrectResultsReturned(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testGeekListBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                    .setField(BG_Library_Entry__c.Source__c, 'GeekID')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.GEEKLIST)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '12345') // This is a Formula Field
                                                                 .toSObject();
        BG_Library_Entry__c testCollectionBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                 .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                 .setField(BG_Library_Entry__c.Source__c, 'CollectionId')
                                                                 .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.COLLECTION)
                                                                 .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                 .setField(BG_Library_Entry__c.BGG_Id__c, '67890') // This is a Formula Field
                                                              .toSObject();

        BGGCalloutService.CalloutResult collectionResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.CalloutResult geekListResult = new BGGCalloutService.CalloutResult();

        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.comment = 'This is my Comment';
        wrapper.ownerName = 'My Name';
        collectionResult.wrapperMap.put('67890', wrapper);
        geekListResult.wrapperMap.put('12345', wrapper);

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => collectionResult,
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => geekListResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBGLibraryEntriesFromBGG(mock.uowMock, new List<BG_Library_Entry__c>{testCollectionBGLEntry, testGeekListBGLEntry});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.SUCCESS_MSG, 
                                        new List<String>{
                                            '2', //Total Updated
                                            ''   //Error Messages
                                        }),
                                        result, 'Return Result Message Does Not Match: '+ result);
        
        //Verify that UOW Register Dirty did Ran twice, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 2))
            .registerDirty(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Ran For the Geeklist Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testGeekListBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => testGeekListBGLEntry.BGG_Id__c,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));

        //Verify that UOW Register Dirty method Ran For the Collection Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testCollectionBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => testCollectionBGLEntry.BGG_Id__c,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));
    }

    // Update BGLE Details with Both Sources with Mix of Correct Results Returned and Error Messages
    @IsTest
    public static void givenBGLEntryCollectionAndGeekListRecordsWithSources_WhenUpdateBGLECalled_ThenMixedResultsReturned(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testGeekListBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                    .setField(BG_Library_Entry__c.Source__c, 'GeekID')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.GEEKLIST)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '12345') // This is a Formula Field
                                                                 .toSObject();
        BG_Library_Entry__c testCollectionBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                 .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                 .setField(BG_Library_Entry__c.Source__c, 'CollectionId')
                                                                 .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.COLLECTION)
                                                                 .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                 .setField(BG_Library_Entry__c.BGG_Id__c, '67890') // This is a Formula Field
                                                              .toSObject();

        BGGCalloutService.CalloutResult collectionResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.CalloutResult geekListResult = new BGGCalloutService.CalloutResult();

        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.comment = 'This is my Comment';
        wrapper.ownerName = 'My Name';
        collectionResult.wrapperMap.put('67890', wrapper);
        geekListResult.wrapperMap.put('12345', wrapper);

        collectionResult.resultMessage = 'Error Occured';

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => collectionResult,
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => geekListResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBGLibraryEntriesFromBGG(mock.uowMock, new List<BG_Library_Entry__c>{testCollectionBGLEntry, testGeekListBGLEntry});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.SUCCESS_MSG, 
                                        new List<String>{
                                            '1', //Total Updated
                                            'Error Occured'   //Error Messages
                                        }),
                                        result, 'Return Result Message Does Not Match: '+ result);
        
        //Verify that UOW Register Dirty did Ran twice, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Ran For the Geeklist Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testGeekListBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => testGeekListBGLEntry.BGG_Id__c,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));

        //Verify that UOW Register Dirty method did NOT Run For the Collection Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testCollectionBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => testCollectionBGLEntry.BGG_Id__c,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));
    }

    // Update BGLE Details with No Matching BBG IDs
    @IsTest
    public static void givenBGLEntryCollectionAndGeekListRecordsWithSourcesAndNonMatchingBBGIds_WhenUpdateBGLECalled_ThenNoUpdates(){

        //Setup Test Data and Mocking
        // Using SFabricatedObject instead of normal mocking because the Service will be using a formula
        // field in the mocking of its data. SFabricatedObject allows us to mock formula fields in a way
        // that normal mocking of an object cannot.
        BG_Library_Entry__c testGeekListBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                    .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                    .setField(BG_Library_Entry__c.Source__c, 'GeekID')
                                                                    .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.GEEKLIST)
                                                                    .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                    .setField(BG_Library_Entry__c.BGG_Id__c, '12345') // This is a Formula Field
                                                                 .toSObject();
        BG_Library_Entry__c testCollectionBGLEntry = (BG_Library_Entry__c) new sfab_FabricatedSObject(BG_Library_Entry__c.class)
                                                                 .setField(BG_Library_Entry__c.Id, fflib_IDGenerator.generate(BG_Library_Entry__c.sObjectType))
                                                                 .setField(BG_Library_Entry__c.Source__c, 'CollectionId')
                                                                 .setField(BG_Library_Entry__c.Source_Type__c, BGLibraryEntryService.COLLECTION)
                                                                 .setField(BG_Library_Entry__c.BoardGameName__c, 'My Board Game') // This is a Formula Field
                                                                 .setField(BG_Library_Entry__c.BGG_Id__c, '67890') // This is a Formula Field
                                                              .toSObject();

        BGGCalloutService.CalloutResult collectionResult = new BGGCalloutService.CalloutResult();
        BGGCalloutService.CalloutResult geekListResult = new BGGCalloutService.CalloutResult();

        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        wrapper.comment = 'This is my Comment';
        wrapper.ownerName = 'My Name';
        collectionResult.wrapperMap.put('98765', wrapper);
        geekListResult.wrapperMap.put('54321', wrapper);

        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>{
            MockParams.RETURNED_COLLECTION_CALLOUT_RESULT => collectionResult,
            MockParams.RETURNED_GEEKLIST_CALLOUT_RESULT => geekListResult
        };

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'updateBGLibraryEntryFromBGG';

        //Run Test
        Test.startTest();
        BGLibraryEntryService service = new BGLibraryEntryService(new List<Services_Config__mdt>{mock.mockConfig});
        String result = service.updateBGLibraryEntriesFromBGG(mock.uowMock, new List<BG_Library_Entry__c>{testCollectionBGLEntry, testGeekListBGLEntry});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(String.Format(BGLibraryEntryService.SUCCESS_MSG, 
                                        new List<String>{
                                            '0', //Total Updated
                                            ''   //Error Messages
                                        }),
                                        result, 'Return Result Message Does Not Match: '+ result);
        
        //Verify that UOW Register Dirty did Ran twice, 
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.anySObject());
            
        //Verify that UOW Register Dirty method Ran For the Geeklist Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testGeekListBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => testGeekListBGLEntry.BGG_Id__c,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));

        //Verify that UOW Register Dirty method did NOT Run For the Collection Library Entry
        ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 0))
            .registerDirty(fflib_Match.sobjectWith(
                //Validate Record in Register Dirty is the same as the Library Entry in the calloutResult 
                new Map<Schema.SObjectField, Object>{
                    //And that the Values inserted match expected
                    BG_Library_Entry__c.Id => testCollectionBGLEntry.Id,
                    BG_Library_Entry__c.BGG_ID__c => testCollectionBGLEntry.BGG_Id__c,
                    BG_Library_Entry__c.BGG_Owner__c => wrapper.ownerName,
                    BG_Library_Entry__c.Comments__c => wrapper.comment                }
            ));
    }
    //#endregion

}