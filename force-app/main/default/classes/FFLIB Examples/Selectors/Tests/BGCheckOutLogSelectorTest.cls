/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Check Out Log Selector
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-02-05
* @modified       2025-02-05
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BGCheckOutLogSelectorTest {
    
    @IsTest
    //Standard Test Method to Test NewInstance Method, Also covers getSObjectType Method
    //getSObjectFieldList Method is covered and called by Standard Selector Methods so no indiviual Unit Test is Needed
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IBGCheckOutLogSelector result = BGCheckOutLogSelector.newInstance();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return instance');
    }

    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenLogID_WhenSelectByIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        BG_Checkout_Log__c testRecord = TestUtil.createBoardGameCheckOutLog();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = BGCheckOutLogSelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods

    @isTest
    public static void givenBoardGameId_WhenSelectByBoardGameIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        BG_Library_Entry__c testBGLE = TestUtil.createBoardGameLibraryEntry();
        insert testBGLE;

        BG_Checkout_Log__c testRecord = TestUtil.createBoardGameCheckOutLog(testBGLE.Id);
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = BGCheckOutLogSelector.newInstance().selectByBoardGameId(new Set<Id>{testBGLE.Board_Game__c});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    @isTest
    public static void givenBGLEId_WhenSelectByLibraryEntryIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        BG_Checkout_Log__c testRecord = TestUtil.createBoardGameCheckOutLog();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<BG_Checkout_Log__c> results = BGCheckOutLogSelector.newInstance().selectByLibraryEntryId(new Set<Id>{testRecord.BG_Library_Entry__c});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

}