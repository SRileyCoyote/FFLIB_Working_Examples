/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector for the Board Game Object
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
public without sharing class BoardGameSelector extends ApplicationSObjectSelector implements IBoardGameSelector  {
    
    //Required Method to Initialize Selector
    public static IBoardGameSelector newInstance() {
        return (IBoardGameSelector) Application.Selector.newInstance(Board_Game__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return Board_Game__c.SObjectType;
    }

    //Required Method. Replaces Abstract method in parent class.
    //Used to get Addtional Custom Fields from Object used in any Selector Method.
    //All Standard Fields already included
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getAdditionalSObjectFieldList() {
        return new List<Schema.SObjectField> {
            // Board_Game__c.BGG_ID__c,
            // Board_Game__c.Is_New__c,
            // //Need to add fields in order to compare values
            // Board_Game__c.Avg_Rating__c,
            // Board_Game__c.Avg_Weight__c,
            // Board_Game__c.Image_URL__c,
            // Board_Game__c.Thumbnail_URL__c,
            // Board_Game__c.Max_Players__c,
            // Board_Game__c.Min_Players__c,
            // Board_Game__c.Min_Age__c,
            // Board_Game__c.Playing_Time__c,
            // Board_Game__c.Year_Published__c,
            // Board_Game__c.Publisher__c,
            // Board_Game__c.Categories__c,
            // Board_Game__c.Mechanics__c
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<Board_Game__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
        return super.selectSObjectsById(recordIds);
        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkificationa and resuability
    public List<Board_Game__c> selectByBGGIDs(Set<String> bggIDs){

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('BGG_ID__c = :bggIDs');
        return (List<Board_Game__c>) Database.query(query.toSOQL());
    }
}