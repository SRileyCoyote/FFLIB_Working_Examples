public interface IBGCheckOutLogService {
    void setTotalCheckOutTime(List<BG_Checkout_Log__c> records);
    void setTotalCheckOutTime(List<BG_Checkout_Log__c> records, Map<Id,SObject> existingRecords);
    void createCheckOutLog(fflib_SObjectUnitOfWork uow, Id bgleId, Id attendeeId, Datetime checkOutTime);
    void updateCheckOutLog(fflib_SObjectUnitOfWork uow, BG_Checkout_Log__c log, Datetime checkInTime);
}