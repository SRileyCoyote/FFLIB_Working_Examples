public interface IBoardGameSelector extends fflib_ISObjectSelector{
    List<Board_Games__c> selectById(Set<Id> recordIds);
    List<Board_Games__c> selectByBGGIDs(Set<String> bggIDs);
}