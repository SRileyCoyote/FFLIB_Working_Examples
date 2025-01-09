public interface IBGCheckOutLogService {
    void setTotalCheckOutTime(List<BG_Checkout_Log__c> records);
    void setTotalCheckOutTime(List<BG_Checkout_Log__c> records, Map<Id,SObject> existingRecords);
}