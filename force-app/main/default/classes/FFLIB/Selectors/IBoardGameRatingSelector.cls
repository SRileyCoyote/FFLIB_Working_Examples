public interface IBoardGameRatingSelector extends fflib_ISObjectSelector {
    List<Board_Game_Rating__c> selectById(Set<Id> recordIds);
    List<Board_Game_Rating__c> selectFavoriteRatingByUserIdExcludingRecordID(Set<Id> attendeeIds, Set<Id> excludeRecordIds);
}