//Needs to Implement and Extend the fflib_SObjectDomain and fflib_ISObjectDomain respecively in order to mock the Domain
//IBoardGameRatingsDomain extends fflib_ISObjectDomain but can add other methods onto it if needed
public with sharing class BoardGameRatingsTriggerHandler extends fflib_SObjectDomain implements fflib_ISObjectDomain{
    
    @TestVisible
    private Domain_Config__mdt domainConfig;

    //Actual Constructor for the Domain
    public BoardGameRatingsTriggerHandler(List<Board_Game_Rating__c> sObjectList){
        //Get Custom Metadata Type for Domain
        this(Domain_Config__mdt.getInstance('BoardGameRatings'), sObjectList);
    }

    @TestVisible
    //Constructor Used For Testing and Setting Own Config File
    private BoardGameRatingsTriggerHandler(Domain_Config__mdt config, List<Board_Game_Rating__c> sObjectList)
    {
        super(sObjectList);
        domainConfig = config;

        //Disable Triggers, if enabled 
        If(domainConfig.Bypass_Trigger__c){
            system.debug('Disabling Trigger...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).disableAll();
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        //Initialize Unit of Work and Service Classes from Application Layer
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGameRatingsService service = (BoardGameRatingsService) Application.Service.newInstance(IBoardGameRatingsService.class);

        //Prevent Recursion on After Update, If enabled
        if(domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).disableAfterUpdate(); 
        }

        try{         
            //Do Work

            //super.Records gets all of the Records from the trigger from the Domain
            service.setNewFavorite(uow, super.Records, existingRecords); 

            //Perform DML on all Registered Records
            uow.commitWork();
        }
        catch (Exception ex) 
        {
            //Bypass Error Handling, If Enabled
            if(domainConfig.Bypass_Error_Handling__c)
            {
                System.debug('An Error Occured: ' + ex.getMessage());
            }
            else 
            {
                throw new BRGDomainException('An Error Occured in the Board Game Ratings Domain: ' + ex.getMessage());
            }
        }
    }

    public class BRGDomainException extends Exception {}

}