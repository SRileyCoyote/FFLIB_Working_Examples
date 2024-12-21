public interface IBoardGameRatingsService {
    void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> records);
    void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> records, Map<Id,SObject> existingRecords);
}