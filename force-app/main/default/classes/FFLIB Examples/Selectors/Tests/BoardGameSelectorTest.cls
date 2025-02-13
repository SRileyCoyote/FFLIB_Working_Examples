/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Board Game Selector
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
private class BoardGameSelectorTest {
    
    @IsTest
    //Standard Test Method to Test NewInstance Method, Also covers getSObjectType Method
    //getSObjectFieldList Method is covered and called by Standard Selector Methods so no indiviual Unit Test is Needed
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IBoardGameSelector result = BoardGameSelector.newInstance();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }

    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenBoardGameId_WhenSelectByIDisCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Board_Games__c testRecord = TestUtil.createBoardGame();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Board_Games__c> results = BoardGameSelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods

    @isTest
    public static void givenBGGId_WhenSelectByBGGIDsIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Board_Games__c testRecord = TestUtil.createBoardGame();
        testRecord.BGG_ID__c = '12345';
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Board_Games__c> results = BoardGameSelector.newInstance().selectByBGGIDs(new Set<String>{'12345'});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

}