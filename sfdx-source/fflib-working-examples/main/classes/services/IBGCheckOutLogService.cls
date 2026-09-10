public interface IBGCheckOutLogService {
    void createCheckOutLog(fflib_SObjectUnitOfWork uow, Id bgleId, Id attendeeId, Datetime checkOutTime);
    void updateCheckOutLog(fflib_SObjectUnitOfWork uow, BG_Checkout_Log__c log, Datetime checkInTime);
}