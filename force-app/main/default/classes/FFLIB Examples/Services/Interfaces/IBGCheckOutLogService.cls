public interface IBGCheckOutLogService {
    void setTotalCheckOutTime(fflib_SObjectUnitOfWork uow, List<BG_Checkout_Log__c> records);
    void setTotalCheckOutTime(fflib_SObjectUnitOfWork uow, List<BG_Checkout_Log__c> records, Map<Id,SObject> existingRecords);
}