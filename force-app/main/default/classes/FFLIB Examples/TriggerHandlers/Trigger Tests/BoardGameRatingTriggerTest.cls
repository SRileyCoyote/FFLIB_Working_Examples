@isTest
private class BoardGameRatingTriggerTest {

    @IsTest
    public static void triggerTest(){

        //Perform DML on Board_Game_Rating__c record
        Test.startTest();
            Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating(); //Use TestUtil to generate test data
            insert testRecord;
        Test.stopTest();

        //Trigger Logic is tested in the TriggerHandler, Domain, and Service classes
        Assert.isNotNull(testRecord.Id, 'Record ID Not Found');
    }
}