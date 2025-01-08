/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class just for the Board Game Check Out Log Trigger
*
* Trigger Logic is tested in the TriggerHandler, Domain, and Service classes. Minimal Testing
* needed here mostly to ensure that DML on records process normally.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-07
* @modified       2024-01-07
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BoardGameCheckOutLogTriggerTest {

    @IsTest
    public static void triggerTest(){

        //Perform DML on Board_Game_Rating__c record
        Test.startTest();
            BG_Checkout_Log__c testRecord = TestUtil.createBoardGameCheckOutLog(); //Use TestUtil to generate test data
            insert testRecord;
        Test.stopTest();

        //Trigger Logic is tested in the TriggerHandler, Domain, and Service classes
        Assert.isNotNull(testRecord.Id, 'Record ID Not Found');
    }
}