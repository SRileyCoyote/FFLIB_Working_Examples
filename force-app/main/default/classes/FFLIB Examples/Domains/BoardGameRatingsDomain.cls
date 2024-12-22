/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Domain Class for the Board Game Ratings Object.
*
* Domain Classes are like Service Classes in that they are where logic is performed however the 
* logic performed in the Domain Class is specific to sets of records of this Object type. While 
* this Domain currenlty only utilizes the common logic performed in the Base Domain class it extends
* any future methods for logic specific to this SObject would be contained here such as Custom 
* Validation on records given to the Domain or furhter filtering of the record list.   
*
* Domain Classes extend from the BaseDomain Class which in turn extends the fflib_SObjects Class
* and implements its own Interface which also extends the BaseDomain Interface which is vital to 
* being able to Mock and Stub the Domain Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-21
* @modified       2024-12-21
* @systemLayer    Domain
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BoardGameRatingsDomain extends BaseDomain implements IBoardGameRatingsDomain {
    
    public static IBoardGameRatingsDomain newInstance(List<Board_Game_Rating__c> recordList){
        return (IBoardGameRatingsDomain) Application.Domain.newInstance(recordList);
    }

    public BoardGameRatingsDomain(List<Board_Game_Rating__c> sObjectList) {
        super(sObjectList, Board_Game_Rating__c.SObjectType);
    }

    public List<Board_Game_Rating__c> getBoardGameRatings()
	{
		return (List<Board_Game_Rating__c>) getRecords();
	}

    public class Constructor implements fflib_IDomainConstructor {
        public fflib_SObjects construct(List<Object> objectList) {
            return new BoardGameRatingsDomain((List<SObject>) objectList);
        }
    }

}