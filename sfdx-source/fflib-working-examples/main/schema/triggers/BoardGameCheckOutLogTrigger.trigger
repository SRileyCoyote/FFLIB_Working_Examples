trigger BoardGameCheckOutLogTrigger on BG_Checkout_Log__c (after delete, after insert, after update, before delete, before insert, before update) {
    //All Logic Moved to the Trigger Handler, Domain, and Service Class for the Object
    fflib_SObjectDomain.triggerHandler(BGCheckOutLogs.class);
}