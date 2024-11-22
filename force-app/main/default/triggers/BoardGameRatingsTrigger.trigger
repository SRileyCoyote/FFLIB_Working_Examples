trigger BoardGameRatingsTrigger on Board_Game_Rating__c (before insert, after insert, before update, after update) {

    //All Logic Moved to the Trigger Handler, Domain, and Serivec Class for the Object
    fflib_SObjectDomain.triggerHandler(BoardGameRatingsTriggerHandler.class);

}