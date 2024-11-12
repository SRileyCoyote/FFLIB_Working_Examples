public with sharing class BoardGameRatingsDomain extends fflib_SObjectDomain {
    
    @TestVisible
    private Domain_Config__mdt domainConfig;

    public static BoardGameRatingsDomain newInstance(List<Board_Game_Rating__c> sObjectList){
        return new BoardGameRatingsDomain(sObjectList);
    }

    public BoardGameRatingsDomain(List<Board_Game_Rating__c> sObjectList)
    {
        super(sObjectList);

        //Get Custom Metadata Type for Domain
        domainConfig = Domain_Config__mdt.getInstance('BoardGameRatingsDomain');

        //Disable Triggers, if enabled 
        If(domainConfig.Bypass_Trigger__c && !System.Test.isRunningTest()){
            system.debug('Disabling Trigger...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).disableAll();
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new BoardGameRatingsDomain(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        
        //Prevent Recursion on After Update, If enabled
        if(domainConfig.Prevent_Recursion__c  || System.Test.isRunningTest())
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).disableAfterUpdate(); 
        }

        // try{
            //Initialize Unit of Work and Service Classes from Application Layer
            fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
            IBoardGameRatingsService service = (IBoardGameRatingsService) Application.Service.newInstance(IBoardGameRatingsService.class);

            //Do Work
            service.setNewFavorite(uow, existingRecords.values());

            //Commit Records
            uow.commitWork();
        // }
        // catch (Exception ex) 
        // {
        //     //Bypass Error Handling, If Enabled
        //     if(domainConfig.Bypass_Error_Handling__c && !System.Test.isRunningTest())
        //     {
        //         System.debug('An Error Occured: ' + ex.getMessage());
        //     }
        //     else 
        //     {
        //         throw new BoardGameRatingsException('An Error Occured in the Board Game Ratings Domain: ' + ex.getMessage());
        //     }
        // }
    }

    public class BoardGameRatingsException extends Exception {}

}