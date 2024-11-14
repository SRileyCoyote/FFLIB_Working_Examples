@isTest
private class BoardGameRatingSelectorTest {
    
    @IsTest
    //Standard Test Method to Test NewInstance Method, Also covers getSObjectType Method
    //getSObjectFieldList Method is covered and called by Standard Selector Methods so no indiviual Unit Test is Needed
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IBoardGameRatingSelector result = BoardGameRatingSelector.newInstance();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return instance');
    }

    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenBGRFavoriteRecord_WhenSelectByIDisCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Board_Game_Rating__c> results = BoardGameRatingSelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods
    @isTest
    public static void givenBGRFavoriteRecord_WhenSelectFavoriteRatingByAttendeeIdExcludingRecordIDisCalled_ThenReturnResults() {
        
        //Create Test Data (Use Test Util Class where possible)
        Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating();
        testRecord.is_Favorite__c = true;
        insert testRecord;

        //Perform Test
        Test.startTest();
        List<Board_Game_Rating__c> results = BoardGameRatingSelector.newInstance().selectFavoriteRatingByAttendeeIdExcludingRecordID(new Set<Id>{testRecord.Event_Attendee__c}, 
                                                                                                                                    //Generate ID that is NOT the TestRecord ID
                                                                                                                                    new Set<Id>{fflib_IDGenerator.generate(Board_Game_Rating__c.SObjectType)});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');    
    }
}