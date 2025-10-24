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
public without sharing class BoardGameSelector extends fflib_SObjectSelector implements IBoardGameSelector  {
    
    //Required Method to Initialize Selector
    public static IBoardGameSelector newInstance() {
        return (IBoardGameSelector) Application.Selector.newInstance(Board_Games__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return Board_Games__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Board_Games__c.Name,
            Board_Games__c.BGG_ID__c,
            Board_Games__c.Is_New__c,
            //Need to add fields in order to compare values
            Board_Games__c.Avg_Rating__c,
            Board_Games__c.Avg_Weight__c,
            Board_Games__c.Image_URL__c,
            Board_Games__c.Thumbnail_URL__c,
            Board_Games__c.Max_Players__c,
            Board_Games__c.Min_Players__c,
            Board_Games__c.Min_Age__c,
            Board_Games__c.Playing_Time__c,
            Board_Games__c.Year_Published__c,
            Board_Games__c.Publisher__c,
            Board_Games__c.Categories__c,
            Board_Games__c.Mechanics__c
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<Board_Games__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
        return super.selectSObjectsById(recordIds);
        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkificationa and resuability
    public List<Board_Games__c> selectByBGGIDs(Set<String> bggIDs){

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('BGG_ID__c = :bggIDs');
        return (List<Board_Games__c>) Database.query(query.toSOQL());
    }
}