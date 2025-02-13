/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Board Game Library Entry Selector
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2025-02-05
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BGLibraryEntrySelectorTest {
    
    @IsTest
    //Standard Test Method to Test NewInstance Method, Also covers getSObjectType Method
    //getSObjectFieldList Method is covered and called by Standard Selector Methods so no indiviual Unit Test is Needed
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IBGLibraryEntrySelector result = BGLibraryEntrySelector.newInstance();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }

    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenBGLibEntryID_WhenSelectByIDisCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        BG_Library_Entry__c testRecord = TestUtil.createBoardGameLibraryEntry();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<BG_Library_Entry__c> results = BGLibraryEntrySelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods

    @isTest
    public static void givenEventID_WhenSelectByEventIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        BG_Library_Entry__c testRecord = TestUtil.createBoardGameLibraryEntry();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<BG_Library_Entry__c> results = BGLibraryEntrySelector.newInstance().selectByEventIDs(new Set<Id>{testRecord.Event__c});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    @isTest
    public static void givenBoardGameID_WhenSelectByBoardGameIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        BG_Library_Entry__c testRecord = TestUtil.createBoardGameLibraryEntry();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<BG_Library_Entry__c> results = BGLibraryEntrySelector.newInstance().selectByBoardGameId(new Set<Id>{testRecord.Board_Game__c});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }


}