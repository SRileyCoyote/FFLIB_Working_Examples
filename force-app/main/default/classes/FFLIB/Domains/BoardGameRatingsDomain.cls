public class BoardGameRatingsDomain extends fflib_SObjects implements IBoardGameRatingsDomain {
    
    public static IBoardGameRatingsDomain newInstance(List<Board_Game_Rating__c> recordList){
        return (IBoardGameRatingsDomain) Application.Domain.newInstance(recordList);
    }

    public BoardGameRatingsDomain(List<SObject> sObjectList) {
        super(sObjectList, Board_Game_Rating__c.SObjectType);
    }

    public class Constructor implements fflib_IDomainConstructor {
        public fflib_SObjects construct(List<Object> objectList) {
            return new BoardGameRatingsDomain((List<SObject>) objectList);
        }
    }

}