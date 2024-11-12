@isTest
private class BoardGameRatingTriggerTest {

    @IsTest
    public static void triggerTest(){

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectDomain mockDomain = (fflib_ISObjectDomain) mocks.mock(fflib_ISObjectDomain.class);
        Application.Domain.setMock(mockDomain);

        mocks.startStubbing();
        mocks.stopStubbing();

        Test.startTest();
            Board_Game_Rating__c testRecord = TestUtil.createBoardGameRating();
            insert testRecord;
            update testrecord;
        Test.stopTest();

        //Logic is tested in the Domain and Service classes
        ((BoardGameRatingsDomain) mocks.verify(mockDomain, 0)).onAfterUpdate((Map<Id,SObject>) fflib_Match.anyObject());

    }
}