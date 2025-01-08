trigger BoardGameCheckOutLogTrigger on BG_Checkout_Log__c (before insert, after insert, before update, after update) {

    //All Logic Moved to the Trigger Handler, Domain, and Service Class for the Object
    fflib_SObjectDomain.triggerHandler(BoardGameCheckOutLogTriggerHandler.class);

}