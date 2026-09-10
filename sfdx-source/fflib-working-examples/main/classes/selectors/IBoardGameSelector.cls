public interface IBoardGameSelector extends IApplicationSObjectSelector{
    List<Board_Game__c> selectById(Set<Id> recordIds);
    List<Board_Game__c> selectByBGGIDs(Set<String> bggIDs);
}