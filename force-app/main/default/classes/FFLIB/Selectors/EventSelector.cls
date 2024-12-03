/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector for the Event Object
*
* Selectors are reusable classes that perform all of the SOQL calls for an application.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2024-11-30
* @systemLayer    Selector
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@SuppressWarnings('PMD.SOQLInjection') //PMD Incorrectly identifies Queries made in Selectors to have possible SOQL Injection. This Suppresses that Warning
//Without Sharing is needed in order to always return all values of a query
public without sharing class EventSelector extends fflib_SObjectSelector implements IEventSelector  {
    
    //Required Method to Initialize Selector
    public static IEventSelector newInstance() {
        return (IEventSelector) Application.Selector.newInstance(Event__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return Event__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Event__c.Id,
            Event__c.Name
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<Event__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
        return super.selectSObjectsById(recordIds);
        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkification and resuability
    public List<Event__c> selectAll(){
        fflib_QueryFactory query = newQueryFactory();
        return (List<Event__c>) Database.query(query.toSOQL());
    }
}