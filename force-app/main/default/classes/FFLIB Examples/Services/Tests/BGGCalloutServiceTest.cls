/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the BoardGameGeek API Callout Service Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* As This is an API Callout Service, HTTP Callouts will be Mocked using Inner Mock Class
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
private class BGGCalloutServiceTest {

    //#region Setup
    // Mock HttpResponse class to simulate the actual HTTP response for callouts
    public class MockHttpResponse implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        
        public MockHttpResponse(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setBody(this.responseBody);
            response.setStatusCode(this.statusCode);
            return response;
        }
    }

    // Helper method to read XML response from Static Resource
    private static String getMockXmlResponseFromStaticResource(String staticResourceName) {
        StaticResource staticResource = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        return staticResource.Body.toString();
    }

    // Helper methods to generate indiviual BGG Detail XML response
    private static String generateXMLItem(Map<String, String> paramMap){        
        String xmlTemplate = '<item id="{0}">'
                                + '<name type="primary" sortindex="1" value="{1}" />'
                            + '</item>';
        return  String.format(xmlTemplate, new List<String>{
                                                        getParam('id', paramMap),
                                                        getParam('name', paramMap)
                                                    });
    }

    private static String getMockIndividualXmlResponse(List<String> xmlItems){
        return '<items>'+String.join(xmlItems, '')+'</items>';
    }

    private static String getParam(String paramName, Map<String, String> paramMap){
        return paramMap.containsKey(paramName) ? paramMap.get(paramName) : '';
    }
    //#endregion

    //Test Plan
    // Call New Instance
    // Successfully Call Collection API
    // Catch Error from Collection API 
    // Successfully Call Geeklist API
    // Catch Error from Geeklist API
    // Call Details API with no IDs
    // Call Details API with 1 ID
    // Call Details API with 20 IDs
    // Call Details API with 21 IDs
    // Call Details API with # of IDs Exceeding Callout Limit
    // Catch Error from Call Details API
    // Call Details for Specific BGG IDs with 1 BGG ID
    // Call Details for Specific BGG IDs with multiple BGG IDs
    // Call Details for Specific BGG IDs with no BGG IDs
    // Call IDs From BGG with No Collection Name or GeekList ID
    // Call IDs from BGG with Collection Name Exceeding Call Limit 
    // Call IDs from BGG with GeekList ID Exceeding Call Limit 
    // Call GeekList API with Status Code 202
    // Call Collection API with Invalid Collection Name
    // Call Collection API with No Items Returned

    //Start Testing
    // Call New Instance
    @IsTest
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IBGGCalloutService result = BGGCalloutService.newInstance();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }
    
    //#region ///////////////////////////////// GetIDsFromBoardGameGeek ///////////////////////////////////////////

    // Successfully Call Collection API
    @isTest
    public static void givenCollectionName_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Collection_Example');
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('testUser', false);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(5, result.wrapperMap.size(), 'Expected 5 items in the wrapper map');
        Assert.areEqual('207830', result.wrapperMap.keySet().iterator().next(), 'Expected BGG ID to be 207830');
        Assert.areEqual('testUser', result.wrapperMap.get('207830').ownerName, 'Owner name mismatch');
        Assert.areEqual('Backed On Kickstarter', result.wrapperMap.get('207830').comment, 'Comment mismatch');
    }

    // Catch Error from Collection API 
    @isTest
    public static void givenCollectionName_WhenGetIDsFromBGGCalledWithBadStatusCode_ThenErrorThrown() {
        // Get XML response from the Static Resource
        String mockXmlResponse = 'Code 400 Error';
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 400));
        
        String errMessage = 'No Error Message';
        BGGCalloutService service = new BGGCalloutService();
        try{
            BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('testUser', false);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(BGGCalloutService.ERROR_COLLECTION_MSG + '400: Code 400 Error', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }

    // Successfully Call Geeklist API
    @isTest
    public static void givenGeeklistId_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Geeklist_Example');
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('12345', true);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(13, result.wrapperMap.size(), 'Expected 5 items in the wrapper map');
        Assert.areEqual('315610', result.wrapperMap.keySet().iterator().next(), 'Expected BGG ID to be 315610');
        Assert.areEqual('az933k', result.wrapperMap.get('315610').ownerName, 'Owner name mismatch');
    }

    // Catch Error from Geeklist API
    @isTest
    public static void givenGeekListId_WhenGetBoardGameDetailsFromBGGCalledWithBadStatusCode_ThenErrorThrown() {
        // Get XML response from the Static Resource
        String mockXmlResponse = 'Code 400 Error';
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 400));
        
        String errMessage = 'No Error Message';
        BGGCalloutService service = new BGGCalloutService();
        try{
            BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('12345', true);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(BGGCalloutService.ERROR_GEEKLIST_MSG + '400: Code 400 Error', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }
    //#endregion

    //#region ///////////////////////////////// GetBoardGameDetailsFromBGG ///////////////////////////////////////////

    // Call Details API with no IDs
    @isTest
    public static void givenNoBGGIDs_WhenGetBoardGameDetailsFromBGGCalledWithCorrectStatusCode_ThenNoResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BoardGameWrapper>();
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(0, result.wrapperMap.size(), 'Expected no items in the wrapper map');
        Assert.areEqual(BGGCalloutService.NO_IDS_PROVIDED_MSG, result.resultMessage, 'Returned Messages Does Not Match: '+result.resultMessage);
    }

    // Call Details API with 1 ID
    @isTest
    public static void givenOneBGGID_WhenGetBoardGameDetailsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        BoardGameWrapper wrapper = new BoardGameWrapper();
        testParam.wrapperMap = new Map<String, BoardGameWrapper>{
            '207830' => wrapper
        };
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
        
        Test.stopTest();
        
        // Validate the results
        // Results from Callout will still be 5 since 5 Records are in the example XML
        Assert.areEqual(5, result.wrapperMap.size(), 'Expected 5 items in the wrapper map');
    }

    // Call Details API with 20 IDs
    @isTest
    public static void givenTwentyBGGID_WhenGetBoardGameDetailsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BoardGameWrapper(),
            '176286' => new BoardGameWrapper(),
            '172818' => new BoardGameWrapper(),
            '233266' => new BoardGameWrapper(),
            '314088' => new BoardGameWrapper()
        };
        //Add Remaining IDs Needed For testing
        for (Integer i = 0; i < 15; i++){
            testParam.wrapperMap.put(i.toString(), new BoardGameWrapper());
        }
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(20, result.wrapperMap.size(), 'Expected 20 items in the wrapper map');
    }

    // Call Details API with 20+ IDs
    @isTest
    public static void givenOverTwentyBGGID_WhenGetBoardGameDetailsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BoardGameWrapper(),
            '176286' => new BoardGameWrapper(),
            '172818' => new BoardGameWrapper(),
            '233266' => new BoardGameWrapper(),
            '314088' => new BoardGameWrapper()
        };
        //Add Remaining IDs Needed For testing
        for (Integer i = 0; i < 20; i++){
            testParam.wrapperMap.put(i.toString(), new BoardGameWrapper());
        }
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(25, result.wrapperMap.size(), 'Expected 20 items in the wrapper map');
    }

    // Call Details API with # of IDs Exceeding Callout Limit
    @isTest
    public static void givenTooManyCallouts_WhenGetBoardGameDetailsFromBGGCalledWithCorrectStatusCode_ThenUnprocessIdsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BoardGameWrapper(),
            '176286' => new BoardGameWrapper(),
            '172818' => new BoardGameWrapper(),
            '233266' => new BoardGameWrapper(),
            '314088' => new BoardGameWrapper()
        };
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        service.totalCallouts = 1; //Mock Callouts already made
        service.maxCalloutLimit = 1; //Mock Limit of Callouts Reached
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(String.format(BGGCalloutService.ERROR_TOO_MANY_CALLOUTS, new Integer[]{
                                                                                0,// Total Processed
                                                                                5 // Total IDs
                                                                            }), 
                                        result.resultMessage, 
                                        'Wrong Error Message Recieved: '+result.resultMessage);
        Assert.areEqual(5, result.unprocessedIDs.size(), 'Expected 5 Unprocessed IDs');
    }

    // Catch Error from Call Details API
    @isTest
    public static void givenOneBGGID_WhenGetBoardGameDetailsFromBGGCalledWithBadStatusCode_ThenErrorThrown() {
        // Get XML response from the Static Resource
        String mockXmlResponse = 'Code 400 Error';
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BoardGameWrapper()
        };

        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 400));
        
        String errMessage = 'No Error Message';
        BGGCalloutService service = new BGGCalloutService();
        try{
            BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(BGGCalloutService.ERROR_DETAILS_MSG + '400: Code 400 Error', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }
    //#endregion

    //#region ///////////////////////////////// GetBoardGameDetailFromBGGIds ///////////////////////////////////////////

    // Call Details for Specific BGG IDs with 1 BGG ID
    @isTest
    public static void givenOneBGGId_WhenGetBoardGameDetailFromBGGIdsIsCalled_ThenCorrectResultsReturned() {
        // Generate XML Item
        String xmlItem = generateXMLItem(new Map<String, String>{
                                                                'id' => '12345',
                                                                'name' => 'My Board Game'
                                                                });

        //Create XML Response
        String mockXmlResponse = getMockIndividualXmlResponse(new List<String>{xmlItem});
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailFromBGGIds(new Map<Id, String>{
                                        fflib_IDGenerator.generate(Board_Games__c.sObjectType) => '12345'
                                    });
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(1, result.wrapperMap.size(), 'Expected 1 items in the wrapper map');
        Assert.areEqual('My Board Game', result.wrapperMap.get('12345').boardGame.Name, 'Name does not Match Expected Result');
    }

    // Call Details for Specific BGG IDs with multiple BGG IDs
    @isTest
    public static void givenMultipleBGGIds_WhenGetBoardGameDetailFromBGGIdsIsCalled_ThenCorrectResultsReturned() {
        // Generate XML Items
        String xmlItem1 = generateXMLItem(new Map<String, String>{
                                                                'id' => '12345',
                                                                'name' => 'My First Board Game'
                                                                });
        String xmlItem2 = generateXMLItem(new Map<String, String>{
                                                                'id' => '23456',
                                                                'name' => 'My Second Board Game'
                                                                });

        //Create XML Response
        String mockXmlResponse = getMockIndividualXmlResponse(new List<String>{xmlItem1,xmlItem2});
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailFromBGGIds(new Map<Id, String>{
                                        fflib_IDGenerator.generate(Board_Games__c.sObjectType) => '12345',
                                        fflib_IDGenerator.generate(Board_Games__c.sObjectType) => '23456'
                                    });
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(2, result.wrapperMap.size(), 'Expected 2 items in the wrapper map');
        Assert.areEqual('My First Board Game', result.wrapperMap.get('12345').boardGame.Name, 'Name does not Match Expected Result');
        Assert.areEqual('My Second Board Game', result.wrapperMap.get('23456').boardGame.Name, 'Name does not Match Expected Result');
    }

    // Call Details for Specific BGG IDs with no BGG IDs
    @isTest
    public static void givenNoBGGIds_WhenGetBoardGameDetailFromBGGIdsIsCalled_ThenNoResultsReturned() {
        // Generate XML Items
        String xmlItem1 = generateXMLItem(new Map<String, String>{
                                                                'id' => '12345',
                                                                'name' => 'My First Board Game'
                                                                });
        String xmlItem2 = generateXMLItem(new Map<String, String>{
                                                                'id' => '23456',
                                                                'name' => 'My Second Board Game'
                                                                });

        //Create XML Response
        String mockXmlResponse = getMockIndividualXmlResponse(new List<String>{xmlItem1,xmlItem2});
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailFromBGGIds(new Map<Id, String>());
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(0, result.wrapperMap.size(), 'Expected no items in the wrapper map');
        Assert.areEqual(BGGCalloutService.NO_IDS_PROVIDED_MSG, result.resultMessage, 'Return Message Does Not Match Expected Result');
    }
    //#endregion

    //#region ///////////////////////////////// GetIDsFromBoardGameGeek ///////////////////////////////////////////

    // Call IDs From BGG with No Collection Name or GeekList ID
    @isTest
    public static void givenNoCollectionNameOrGeekListId_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectMessageReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Collection_Example');
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek(null, false);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(0, result.wrapperMap.size(), 'Expected no items in the wrapper map');
        Assert.areEqual(BGGCalloutService.ERROR_SOURCE_ID_MISSING, result.resultMessage, 'Incorrect Message Returned: '+result.resultMessage);
    }

    // Call IDs from BGG with Collection Name Exceeding Call Limit 
    @isTest
    public static void givenTooManyCalloutsForCollection_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenUnprocessedIdsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Collection_Example');
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        service.totalCallouts = 1; //Mock Callouts already made
        service.maxCalloutLimit = 1; //Mock Limit of Callouts Reached

        BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('CollectionName', false);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(0, result.wrapperMap.size(), 'Expected no items in the wrapper map');
        Assert.areEqual(1, result.unprocessedIDs.size(), 'Expected 1 items in the unprocessedIds List');
        Assert.areEqual(String.format(BGGCalloutService.ERROR_COLLECTION_NOT_RETRIEVED,
                                        new List<String>{
                                            BGGCalloutService.COLLECTION,
                                            'CollectionName' 
                                        }
                                    ), 
                        result.resultMessage, 'Incorrect Message Returned: '+result.resultMessage);
    }

    // Call IDs from BGG with GeekList ID Exceeding Call Limit 
    @isTest
    public static void givenTooManyCalloutsForGeekList_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenUnprocessedIdsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Collection_Example');
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        service.totalCallouts = 1; //Mock Callouts already made
        service.maxCalloutLimit = 1; //Mock Limit of Callouts Reached

        BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('GeekListId', true);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(0, result.wrapperMap.size(), 'Expected no items in the wrapper map');
        Assert.areEqual(1, result.unprocessedIDs.size(), 'Expected 1 items in the unprocessedIds List');
        Assert.areEqual(String.format(BGGCalloutService.ERROR_COLLECTION_NOT_RETRIEVED,
                                        new List<String>{
                                            BGGCalloutService.GEEKLIST,
                                            'GeekListId' 
                                        }
                                    ), 
                        result.resultMessage, 'Incorrect Message Returned: '+result.resultMessage);
    }

    // Call GeekList API with Status Code 202 
    @isTest
    public static void givenGeekListId_WhenGetIDsFromBoardGameGeekCalledWithStatusCode202_ThenErrorThrown() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponseFromStaticResource('BGG_Status202_Example');
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 202));
        
        String errMessage = 'No Error Message';
        BGGCalloutService service = new BGGCalloutService();
        try{
            BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('12345', true);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMessage = ex.getMessage();
        }        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(BGGCalloutService.ERROR_GEEKLIST_MSG + 'This is the Message Recieved for a Status 202 Error.', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }

    // Call Collection API with Invalid Collection Name
    @isTest
    public static void givenInvalidCollectionName_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectMessageReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = '<errors><error><message>Invalid username specified</message></error></errors>';
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        String errMessage = 'No Error Message';
        BGGCalloutService service = new BGGCalloutService();
        try{
            BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('testCollectionName', false);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMessage = ex.getMessage();
        }        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(BGGCalloutService.ERROR_COLLECTION_MSG + 'Invalid username specified', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }


    // Call Collection API with No Items Returned
    @isTest
    public static void givenCollectionNameWithNoItems_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectMessageReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = '<items totalitems="0"> </items>';
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        String errMessage = 'No Error Message';
        BGGCalloutService service = new BGGCalloutService();
        try{
            BGGCalloutService.CalloutResult result = service.getIDsFromBoardGameGeek('testCollectionName', false);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMessage = ex.getMessage();
        }        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(BGGCalloutService.ERROR_COLLECTION_MSG + BGGCalloutService.ERROR_NO_ITEMS_IN_COLLECTION, errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }
    //#endregion
}