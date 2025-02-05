public interface IBGCheckOutLogSelector extends fflib_ISObjectSelector {
    List<BG_Checkout_Log__c> selectById(Set<Id> recordIds);
    List<BG_Checkout_Log__c> selectByBoardGameId(Set<Id> boardGameIds);
    List<BG_Checkout_Log__c> selectByLibraryEntryId(Set<Id> bgleIds);
}