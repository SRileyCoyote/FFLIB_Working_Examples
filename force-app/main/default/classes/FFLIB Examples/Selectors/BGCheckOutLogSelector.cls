/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector for the Board Game Check Out Log Object
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
public without sharing class BGCheckOutLogSelector extends fflib_SObjectSelector implements IBGCheckOutLogSelector {
    //Required Method to Initialize Selector
    public static IBGCheckOutLogSelector newInstance() {
        return (IBGCheckOutLogSelector) Application.Selector.newInstance(BG_Checkout_Log__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return BG_Checkout_Log__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            BG_Checkout_Log__c.Id,
            BG_Checkout_Log__c.Attendee_Name__c,
            BG_Checkout_Log__c.BG_Library_Entry__c,
            BG_Checkout_Log__c.Board_Game_Name__c,
            BG_Checkout_Log__c.Check_Out_Time__c,
            BG_Checkout_Log__c.Check_In_Time__c,
            BG_Checkout_Log__c.Event_Name__c            
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<BG_Checkout_Log__c> selectById(Set<Id> recordIds){
        // Optionally, this method can just use and return the line:
            // return super.selectSObjectsById(recordIds);

        //If Any Customization is needed for this method, replace this with a normal QueryFactory Query
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('BG_Library_Entry__r.BoardGameName__c');
        query.selectField('BG_Library_Entry__r.Board_Game_Image_URL__c');
        query.selectField('BG_Library_Entry__r.Event__r.Name');
        query.selectField('BG_Library_Entry__r.Event_Logo_URL__c');
        query.selectField('Checked_Out_By__r.Attendee_Name__c');
        query.setCondition('Id = :recordIds');
        return (List<BG_Checkout_Log__c>) Database.query(query.toSOQL());

    }
    
    //Names of Selector Methods Should describe all of the Conditions for the Query
    //Return Value should always be a List of the Selector's Object
    //Input Parameters should always be Sets of the value type for bulkificationa and resuability
    public List<BG_Checkout_Log__c> selectByBoardGameId(Set<Id> boardGameIds){
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('BG_Library_Entry__r.BoardGameName__c');
        query.selectField('BG_Library_Entry__r.Board_Game_Image_URL__c');
        query.selectField('BG_Library_Entry__r.Event__r.Name');
        query.selectField('BG_Library_Entry__r.Event_Logo_URL__c');
        query.selectField('Checked_Out_By__r.Attendee_Name__c');
        query.setCondition('BG_Library_Entry__r.Board_Game__c = :boardGameIds');
        return (List<BG_Checkout_Log__c>) Database.query(query.toSOQL());
    }

    public List<BG_Checkout_Log__c> selectByLibraryEntryId(Set<Id> bgleIds){
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('BG_Library_Entry__r.BoardGameName__c');
        query.selectField('BG_Library_Entry__r.Board_Game_Image_URL__c');
        query.selectField('BG_Library_Entry__r.Event__r.Name');
        query.selectField('BG_Library_Entry__r.Event_Logo_URL__c');
        query.selectField('Checked_Out_By__r.Attendee_Name__c');
        query.setCondition('BG_Library_Entry__c = :bgleIds');
        return (List<BG_Checkout_Log__c>) Database.query(query.toSOQL());
    }

}