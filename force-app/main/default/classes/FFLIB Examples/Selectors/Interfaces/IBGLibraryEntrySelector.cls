public interface IBGLibraryEntrySelector extends fflib_ISObjectSelector {
    List<BG_Library_Entry__c> selectById(Set<Id> recordIds);
    List<BG_Library_Entry__c> selectByEventIDs(Set<Id> eventIds);
    List<BG_Library_Entry__c> selectByEventIDsAndSources(Set<Id> eventIds, Set<String> sources);
    List<BG_Library_Entry__c> selectByBoardGameId(Set<Id> boardGameIds);
    List<BG_Library_Entry__c> selectBySources(Set<String> sources);   
}