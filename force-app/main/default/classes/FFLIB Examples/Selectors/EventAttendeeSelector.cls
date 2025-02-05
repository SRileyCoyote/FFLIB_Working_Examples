/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector for the Event Attendee SObject
*
* Selectors are reusable classes that perform all of the SOQL calls for an application.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-02-05
* @modified       2025-02-05
* @systemLayer    Selector
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@SuppressWarnings('PMD.SOQLInjection') //PMD Incorrectly identifies Queries made in Selectors to have possible SOQL Injection. This Suppresses that Warning
//Without Sharing is needed in order to always return all values of a query
public without sharing class EventAttendeeSelector extends fflib_SObjectSelector implements IEventAttendeeSelector {
    //Required Method to Initialize Selector
    public static IEventAttendeeSelector newInstance() {
        return (IEventAttendeeSelector) Application.Selector.newInstance(Event_Attendee__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return Event_Attendee__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Event_Attendee__c.Id,
            Event_Attendee__c.Attendee_Name__c,
            Event_Attendee__c.Attendee_Email__c,
            Event_Attendee__c.Event__c
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<Event_Attendee__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
        return super.selectSObjectsById(recordIds);
        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkificationa and resuability
    public List<Event_Attendee__c> selectByEventIDs(Set<Id> eventIds){

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Event__c = :eventIds');
        return (List<Event_Attendee__c>) Database.query(query.toSOQL());
    }
}