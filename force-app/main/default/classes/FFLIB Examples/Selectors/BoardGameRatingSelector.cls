/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector for the Board Game Rating Object
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
public without sharing class BoardGameRatingSelector extends fflib_SObjectSelector implements IBoardGameRatingSelector  {
    
    //Required Method to Initialize Selector
    public static IBoardGameRatingSelector newInstance() {
        return (IBoardGameRatingSelector) Application.Selector.newInstance(Board_Game_Rating__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return Board_Game_Rating__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Board_Game_Rating__c.Board_Game__c,
            Board_Game_Rating__c.Event_Attendee__c,
            Board_Game_Rating__c.is_Favorite__c
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<Board_Game_Rating__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
        return super.selectSObjectsById(recordIds);
        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkificationa and resuability
    public List<Board_Game_Rating__c> selectFavoriteRatingByAttendeeIdExcludingRecordID(Set<Id> attendeeIds, Set<Id> excludeRecordIds){

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Event_Attendee__c = :attendeeIds '
                            + ' AND ID != :excludeRecordIds '
                            + ' AND is_Favorite__c = true');
        return (List<Board_Game_Rating__c>) Database.query(query.toSOQL());
    }
}