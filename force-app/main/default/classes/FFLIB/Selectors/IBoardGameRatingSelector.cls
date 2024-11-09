public interface IBoardGameRatingSelector extends fflib_ISObjectSelector {
    List<Board_Game_Rating__c> selectFavoriteRatingByUserIdExcludingRecordID(ID userId, ID excludeRecordId);
}