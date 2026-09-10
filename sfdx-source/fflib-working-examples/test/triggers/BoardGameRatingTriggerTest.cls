/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Rating Trigger
*
* Trigger Logic is tested in the TriggerHandler, Domain, and Service classes. Minimal Testing
* needed here mostly to ensure that DML on records process normally.
*
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