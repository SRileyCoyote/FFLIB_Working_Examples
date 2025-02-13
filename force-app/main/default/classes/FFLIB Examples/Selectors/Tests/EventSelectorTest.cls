/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Event Selector
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
private class EventSelectorTest {
    
    @IsTest
    //Standard Test Method to Test NewInstance Method, Also covers getSObjectType Method
    //getSObjectFieldList Method is covered and called by Standard Selector Methods so no indiviual Unit Test is Needed
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IEventSelector result = EventSelector.newInstance();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }
    
    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenEventRecord_WhenSelectByIDisCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Event__c testRecord = TestUtil.createEvent();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Event__c> results = EventSelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods

    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenNothing_WhenSelectAllIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Event__c testRecord = TestUtil.createEvent();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Event__c>  results = EventSelector.newInstance().selectAll();
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

}