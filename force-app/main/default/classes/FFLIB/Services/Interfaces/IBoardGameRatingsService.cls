public interface IBoardGameRatingsService {
    void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> newRecords, Map<Id,SObject> existingRecords);
}