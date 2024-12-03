public interface IBGGCalloutService {
    BGGCalloutService.CalloutResult getIDsFromBoardGameGeek(String nameOrId, Boolean isGeekList);
    BGGCalloutService.CalloutResult getBoardGameDetailsFromBGG(BGGCalloutService.CalloutResult result);
}