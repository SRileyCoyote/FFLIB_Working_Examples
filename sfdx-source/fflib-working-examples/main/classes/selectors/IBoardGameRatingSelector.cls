public interface IBoardGameRatingSelector extends IApplicationSObjectSelector {
    List<Board_Game_Rating__c> selectById(Set<Id> recordIds);
    List<Board_Game_Rating__c> selectFavoriteRatingByAttendeeIdExcludingRecordID(Set<Id> attendeeIds, Set<Id> excludeRecordIds);
}