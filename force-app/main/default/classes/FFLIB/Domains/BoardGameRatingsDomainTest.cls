@IsTest
public class BoardGameRatingsDomainTest {
    //Test Class just for the Board Game Rating Trigger and Domain Class
    //Testing for actual Logic in the Triggers are tested in the Service Class Tests, 
    //so these are true Unit Tests to make sure that the Trigger and Domain Classes are working as intended

    //Create the MockSetup Class which we will use to handle all of our mocking and stubbing in our test methods 
    class MockSetup{

        public fflib_ApexMocks mocks = new fflib_ApexMocks();
        public fflib_SobjectUnitOfWork uowMock;
        
        //Constructor with Booleon if Errors Should be thrown
        private MockSetup(Boolean throwErrors){
            mocks = new fflib_ApexMocks();

            //Initialize the Mocks
            uowMock = (fflib_SobjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);

            IBoardGameRatingsService mockBGRService = (IBoardGameRatingsService) mocks.mock(IBoardGameRatingsService.class);

            mocks.startStubbing();
            if(throwErrors){
                ((IBoardGameRatingsService) mocks.doThrowWhen(new BoardGameRatingsDomain.BoardGameRatingsException('Thrown Exception'),
                                                mockBGRService)).setNewFavorite((fflib_SObjectUnitOfWork) fflib_Match.anyObject(), (List<SObject>) fflib_Match.anyObject());
                // mocks.doThrowWhen(new DmlException('Thrown Exception'), mockBGRService);
            }
            mocks.stopStubbing();

            //Whenever the BoardGameRatingsService is created using the Application Class, 
            //Replace that class and all of its methods with our Mock Service with stubbed methods
            //Any Methods not set with a specific value, will return null
            Application.Service.setMock(IBoardGameRatingsService.class, mockBGRService); 
            Application.UnitOfWork.setMock(uowMock);
        }
    } 

    @IsTest
    public static void givenEmptyBGRRecord_WhenBGRRecordIsInsertedAndUpdated_ThenNoErrors(){

        //Initialize and Setup Mocks to not throw errors
        MockSetup mock = new MockSetup(false);

        Test.startTest();
            Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating();
            insert testRecord;
            update testRecord;
        Test.stopTest();

        //Validate that the After Update Method was called
        //TODO: Use mocks.verify to count number of times AfterUpdate is Called
    }

    // TODO: Figure out how to throw an error to get into the Exception Block

    // @IsTest
    // public static void givenEmptyBGRRecord_WhenBGRRecordIsInsertedAndUpdated_ThenThrowErrors(){

    //     Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating();
    //     insert testRecord;

    //     //Initialize and Setup Mocks to Throw Errors
    //     MockSetup mock = new MockSetup(true);
        

    //     Test.startTest();
    //         String errMessage = 'No Message';
    //         try{
                
    //             update testRecord; //Test Should Throw Error
    //             Assert.isTrue(false, 'Error Not Thrown');
    //         }
    //         catch (Exception ex){
    //             errMessage = ex.getMessage();
    //         }
    //     Test.stopTest();

    //     Assert.areEqual('Thrown Exception', errMessage, 'Wrong Error Message Recieved: '+ errMessage);
    // }
    
}