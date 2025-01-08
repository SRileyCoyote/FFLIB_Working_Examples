public interface IBGCheckOutLogDomain extends IBaseDomain {
    //Interface extends IBaseDomain interface 
    // which extends the fflib_ISObjectDomain interface 
    // which is needed for Mocking the Domain
    //Any Additional Methods specific to the BGCheckOutLogDomain should go here
    Boolean validateTimeOutValue(BG_Checkout_Log__c record);
    List<BG_Checkout_Log__c> getCompletedCheckOutLogs(List<BG_Checkout_Log__c> records);
}