/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector for the Board Game Library Entry Object
*
* Selectors are reusable classes that perform all of the SOQL calls for an application.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-11
* @modified       2024-12-11
* @systemLayer    Selector
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@SuppressWarnings('PMD.SOQLInjection') //PMD Incorrectly identifies Queries made in Selectors to have possible SOQL Injection. This Suppresses that Warning
//Without Sharing is needed in order to always return all values of a query
public without sharing class BGLibraryEntrySelector extends fflib_SObjectSelector implements IBGLibraryEntrySelector {
    //Required Method to Initialize Selector
    public static IBGLibraryEntrySelector newInstance() {
        return (IBGLibraryEntrySelector) Application.Selector.newInstance(BG_Library_Entry__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return BG_Library_Entry__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            BG_Library_Entry__c.Id,
            BG_Library_Entry__c.Name,
            BG_Library_Entry__c.Event__c,
            BG_Library_Entry__c.Board_Game__c
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<BG_Library_Entry__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
        return super.selectSObjectsById(recordIds);
        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkificationa and resuability
    public List<BG_Library_Entry__c> selectByEventIDs(Set<Id> eventIds){

        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Board_Game__r.BGG_ID__c'); //Add Field here in order to retrieve From Related Object
        query.setCondition('Event__c = :eventIds');
        return (List<BG_Library_Entry__c>) Database.query(query.toSOQL());
    }
}