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
* @modified       2024-11-30
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BGGCalloutServiceTest {

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
    private static String getMockXmlResponse(String staticResourceName) {
        StaticResource staticResource = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        return staticResource.Body.toString();
    }

    //Test Plan
    //Successfully Call Collection API
    //Catch Error from Collection API 
    //Successfully Call Geeklist API
    //Catch Error from Geeklist API
    //Call Details API with no IDs
    //Call Details API with 1 ID
    //Call Details API with 20 IDs
    //Call Details API with 21 IDs
    //Call Details API with # of IDs Exceeding Callout Limit
    //Catch Error from Call Details API

    //Successfully Call Collection API
    @isTest
    static void givenCollectionName_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Collection_Example');
        
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

    //Catch Error from Collection API 
    @isTest
    static void givenCollectionName_WhenGetIDsFromBGGCalledWithBadStatusCode_ThenErrorThrown() {
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
        Assert.areEqual(service.ERROR_COLLECTION_MSG + '400: Code 400 Error', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }

    //Successfully Call Geeklist API
    @isTest
    static void givenGeeklistId_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Geeklist_Example');
        
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

    //Catch Error from Geeklist API
    @isTest
    static void givenGeekListId_WhenGetIDsFromBGGCalledWithBadStatusCode_ThenErrorThrown() {
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
        Assert.areEqual(service.ERROR_GEEKLIST_MSG + '400: Code 400 Error', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }

    //Call Details API with no IDs
    @isTest
    static void givenNoBGGIDs_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenNoResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>();
        
        // Mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockXmlResponse, 200));
        
        BGGCalloutService service = new BGGCalloutService();
        BGGCalloutService.CalloutResult result = service.getBoardGameDetailsFromBGG(testParam);
        
        Test.stopTest();
        
        // Validate the results
        Assert.areEqual(0, result.wrapperMap.size(), 'Expected no items in the wrapper map');
        Assert.areEqual(service.NO_IDS_PROVIDED_MSG, result.resultMessage, 'Returned Messages Does Not Match: '+result.resultMessage);
    }

    //Call Details API with 1 ID
    @isTest
    static void givenOneBGGID_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        BGGCalloutService.BoardGameWrapper wrapper = new BGGCalloutService.BoardGameWrapper();
        testParam.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
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

    //Call Details API with 20 IDs
    @isTest
    static void givenTwentyBGGID_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BGGCalloutService.BoardGameWrapper(),
            '176286' => new BGGCalloutService.BoardGameWrapper(),
            '172818' => new BGGCalloutService.BoardGameWrapper(),
            '233266' => new BGGCalloutService.BoardGameWrapper(),
            '314088' => new BGGCalloutService.BoardGameWrapper()
        };
        //Add Remaining IDs Needed For testing
        for (Integer i = 0; i < 15; i++){
            testParam.wrapperMap.put(i.toString(), new BGGCalloutService.BoardGameWrapper());
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

    //Call Details API with 20+ IDs
    @isTest
    static void givenOverTwentyBGGID_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenCorrectResultsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BGGCalloutService.BoardGameWrapper(),
            '176286' => new BGGCalloutService.BoardGameWrapper(),
            '172818' => new BGGCalloutService.BoardGameWrapper(),
            '233266' => new BGGCalloutService.BoardGameWrapper(),
            '314088' => new BGGCalloutService.BoardGameWrapper()
        };
        //Add Remaining IDs Needed For testing
        for (Integer i = 0; i < 20; i++){
            testParam.wrapperMap.put(i.toString(), new BGGCalloutService.BoardGameWrapper());
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

    //Call Details API with # of IDs Exceeding Callout Limit
    @isTest
    static void givenTooManyCallouts_WhenGetIDsFromBGGCalledWithCorrectStatusCode_ThenUnprocessIdsReturned() {
        // Get XML response from the Static Resource
        String mockXmlResponse = getMockXmlResponse('BGG_Details_Example');
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BGGCalloutService.BoardGameWrapper(),
            '176286' => new BGGCalloutService.BoardGameWrapper(),
            '172818' => new BGGCalloutService.BoardGameWrapper(),
            '233266' => new BGGCalloutService.BoardGameWrapper(),
            '314088' => new BGGCalloutService.BoardGameWrapper()
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
        Assert.areEqual(String.format(service.ERROR_TOO_MANY_CALLOUTS, new Integer[]{
                                                                                0,// Total Processed
                                                                                5 // Total IDs
                                                                            }), 
                                        result.resultMessage, 
                                        'Wrong Error Message Recieved: '+result.resultMessage);
        Assert.areEqual(5, result.unprocessedIDs.size(), 'Expected 5 Unprocessed IDs');
    }

    //Catch Error from Call Details API
    @isTest
    static void givenOneBGGID_WhenGetIDsFromBGGCalledWithBadStatusCode_ThenErrorThrown() {
        // Get XML response from the Static Resource
        String mockXmlResponse = 'Code 400 Error';
        BGGCalloutService.CalloutResult testParam = new BGGCalloutService.CalloutResult();
        testParam.wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>{
            //Load First 5 IDs from Details Example into Map
            '207830' => new BGGCalloutService.BoardGameWrapper()
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
        Assert.areEqual(service.ERROR_DETAILS_MSG + '400: Code 400 Error', errMessage, 'Wrong Error Message Recieved: '+errMessage);
    }

}