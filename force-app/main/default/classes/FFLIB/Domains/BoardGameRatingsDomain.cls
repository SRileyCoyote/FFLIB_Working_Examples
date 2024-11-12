//Needs to Implement and Extend the fflib_SObjectDomain and fflib_ISObjectDomain respecively in order to mock the Domain
//IBoardGameRatingsDomain extends fflib_ISObjectDomain but can add other methods onto it if needed
public with sharing class BoardGameRatingsDomain extends fflib_SObjectDomain implements IBoardGameRatingsDomain {
    
    private Domain_Config__mdt domainConfig;

    public static BoardGameRatingsDomain newInstance(List<Board_Game_Rating__c> sObjectList){
        return new BoardGameRatingsDomain(sObjectList);
    }

    //Actual Constructor for the Domain
    public BoardGameRatingsDomain(List<Board_Game_Rating__c> sObjectList){
        //Get Custom Metadata Type for Domain
        this(Domain_Config__mdt.getInstance('BoardGameRatingsDomain'), sObjectList);
    }

    @TestVisible
    //Constructor Used For Testing and Setting Own Config File
    private BoardGameRatingsDomain(Domain_Config__mdt config, List<Board_Game_Rating__c> sObjectList)
    {
        super(sObjectList);
        domainConfig = config;

        //Disable Triggers, if enabled 
        If(domainConfig.Bypass_Trigger__c){
            system.debug('Disabling Trigger...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).disableAll();
        }
    }

    //Required for the Domain for the Application Layer to create the Domain
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new BoardGameRatingsDomain(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        
        //Prevent Recursion on After Update, If enabled
        if(domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsDomain.class).disableAfterUpdate(); 
        }

        try{
            //Initialize Unit of Work and Service Classes from Application Layer
            fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
            IBoardGameRatingsService service = (IBoardGameRatingsService) Application.Service.newInstance(IBoardGameRatingsService.class);

            //Do Work
            service.setNewFavorite(uow, existingRecords.values());

            //Commit Records
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
                throw new BoardGameRatingsException('An Error Occured in the Board Game Ratings Domain: ' + ex.getMessage());
            }
        }
    }

    public class BoardGameRatingsException extends Exception {}

}