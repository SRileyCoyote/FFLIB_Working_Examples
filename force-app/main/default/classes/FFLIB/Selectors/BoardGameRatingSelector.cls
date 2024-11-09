@SuppressWarnings('PMD.SOQLInjection')
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
    
    //Required Method. Basic Select By ID Query
    public List<Board_Game_Rating__c> selectById(Set<Id> recordIds){
        // Query Factory Options (Optional):
        // AssertCRUD: Disabled By Default, Determines if CRUD Permissions are Enforced.
        // enforceFLS: Disabled By Default, Determines if Field Level Secrity is Enforced.
        // includeSelectorFields: Enabled By Default, Query Uses Fields from getSObjectFieldList Method. Disable to limit to only own selected fields
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Board_Game__r.Name'); //selectField is Only way to include fields from Parent Objects
        query.setCondition('ID := recordIds');
        return (List<Board_Game_Rating__c>) Database.query(query.toSOQL());
    }
    
    public List<Board_Game_Rating__c> selectFavoriteRatingByUserIdExcludingRecordID(ID userId, ID excludeRecordId){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Event_Attendee__c = :userId AND ID != :excludeRecordId');
        return (List<Board_Game_Rating__c>) Database.query(query.toSOQL());
    }
}