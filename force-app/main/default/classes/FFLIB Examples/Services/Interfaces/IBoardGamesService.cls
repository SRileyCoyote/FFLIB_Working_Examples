public interface IBoardGamesService {
    BoardGameServiceResults getBoardGameDetailsFromBGG(fflib_SObjectUnitOfWork uow, Map<String, Object> params);
    String updateBoardGameDetailsFromBGG(fflib_SObjectUnitOfWork uow, Map<ID, String> recordIdToBGGIdMap);

}