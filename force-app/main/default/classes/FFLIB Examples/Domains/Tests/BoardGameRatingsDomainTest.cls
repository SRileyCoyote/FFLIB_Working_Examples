/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Board Game Ratings Domain Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* Since Currently this Domain has is only used for the Parent Domain Methods. Only Testing needed
* is to call the default methods in the Domain.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-21
* @modified       2024-12-21
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@IsTest
public class BoardGameRatingsDomainTest {
    
    //Test Plan
    // Call newInstance
    // Call Constructor
    
    // Call newInstance
    @IsTest
    public static void givenRecord_WhenNewInstanceCalled_ThenReturnInstance() {

        Board_Game_Rating__c testRecord = new Board_Game_Rating__c();
        Test.startTest();
        IBoardGameRatingsDomain result = BoardGameRatingsDomain.newInstance(new List<Board_Game_Rating__c>{testRecord});
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }

    // Call Constructor
    @isTest
    public static void givenListOfRecords_WhenConstructorClassCalled_ThenReturnsCorrectNumberOfRecords(){
        List<Board_Game_Rating__c> records = new List<Board_Game_Rating__c>{new Board_Game_Rating__c()};
        BoardGameRatingsDomain.Constructor constructor = new BoardGameRatingsDomain.Constructor();
        BoardGameRatingsDomain domain = (BoardGameRatingsDomain) constructor.construct(records);
        
        Assert.areEqual(records.size(), domain.getBoardGameRatings().size(), 'Number of Records Match');
    } 

}