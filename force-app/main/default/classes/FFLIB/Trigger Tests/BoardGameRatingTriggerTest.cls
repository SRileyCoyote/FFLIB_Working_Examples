@isTest
private class BoardGameRatingTriggerTest {

    @IsTest
    public static void triggerTest(){

        //Begin Mocking
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BoardGameRatingsDomain mockDomain = (BoardGameRatingsDomain) mocks.mock(BoardGameRatingsDomain.class);
        
        mocks.startStubbing();
        //Stub out the sObjectType Method to return the correct SObjectType for the SObject
        mocks.when(mockDomain.sObjectType()).thenReturn(Board_Game_Rating__c.SObjectType);
        mocks.stopStubbing();

        //Set the mockDomain to be used when the Application Class calls for the Domain Class for the Board_Game_Rating__c SObject
        Application.Domain.setMock((fflib_ISObjectDomain) mockDomain);

        //Start Actual test by Insert and Update a Board_Game_Rating__c record
        Test.startTest();
            Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating(); //Use TestUtil to generate test data
            insert testRecord;
            update testrecord;
        Test.stopTest();

        //Logic is tested in the Domain and Service classes

        //Validate that the onAfterUpdate Method was NOT called as it should have been stubbed out
        ((BoardGameRatingsDomain) mocks.verify(mockDomain, 0)).onAfterUpdate((Map<Id,SObject>) fflib_Match.anyObject());
        
        //TODO: Test Runs Successfully but Not Sure if this is doing what I am expecting it to do
        //What I want is for Domain to be stubbed so that onAfterUpdate Method is NOT called so what I can just Unit test the trigger
    }
}