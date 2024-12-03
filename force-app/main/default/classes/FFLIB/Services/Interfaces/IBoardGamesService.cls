public interface IBoardGamesService {
    String getBoardGameDetailsFromBGG(fflib_SObjectUnitOfWork uow, ID eventId, String collectionNameOrGeekListId, Boolean isGeekList, Boolean updateExisiting);
}