public interface IBGLibraryEntrySelector extends fflib_ISObjectSelector {
    List<BG_Library_Entry__c> selectById(Set<Id> recordIds);
    List<BG_Library_Entry__c> selectByEventIDs(Set<Id> eventIds);
    List<BG_Library_Entry__c> selectByBoardGameId(Set<Id> boardGameIds);
}