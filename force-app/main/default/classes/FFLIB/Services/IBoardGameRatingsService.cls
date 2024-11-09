public interface IBoardGameRatingsService {
    void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> records);
}