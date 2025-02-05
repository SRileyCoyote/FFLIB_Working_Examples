/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Event Attendee Selector
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
private class EventAttendeeSelectorTest {
    
    @IsTest
    //Standard Test Method to Test NewInstance Method, Also covers getSObjectType Method
    //getSObjectFieldList Method is covered and called by Standard Selector Methods so no indiviual Unit Test is Needed
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IEventAttendeeSelector result = EventAttendeeSelector.newInstance();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return instance');
    }

    @isTest
    //Standard Test Method for Select By ID Method
    public static void givenAttendeeID_WhenSelectByIDisCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Event_Attendee__c testRecord = TestUtil.createEventAttendee();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Event_Attendee__c> results = EventAttendeeSelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods

    @isTest
    public static void givenEventID_WhenSelectByEventIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        Event_Attendee__c testRecord = TestUtil.createEventAttendee();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<Event_Attendee__c> results = EventAttendeeSelector.newInstance().selectByEventIDs(new Set<Id>{testRecord.Event__c});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

}