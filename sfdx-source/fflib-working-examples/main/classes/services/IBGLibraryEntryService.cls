public interface IBGLibraryEntryService {
    String updateBGLibraryEntriesFromBGG(fflib_SObjectUnitOfWork uow, List<BG_Library_Entry__c> bgleList);
    Map<String, String> getSourcesByEvent(Id eventId);
}