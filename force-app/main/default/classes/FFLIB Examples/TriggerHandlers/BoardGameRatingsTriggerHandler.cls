/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler for all Board Games Ratings Trigger.
*
* TriggerHandlers handle all of the trigger based logic like if the trigger should fire or not.
* They will then call the call the Serice for the object to perform the actual logic for the 
* method or action against the records.
* 
* TriggerHandlers need to either implement the fflib_ISObjectDomain interface or use their own 
* Interface that extends the fflib_ISObjectDomain interface as well as extend the 
* fflib_SObjectDomain class which is needed by the line in the trigger itself which then knows 
* which trigger methods to fire. The Base Trigger Handler is already doing that for us here.
*
* The Abstract Base Trigger Handler Class we are extending here will hold all of the Base
* Logic and methods used across all triggers like determining if the trigger should fire at all 
* based on Settings from the MDT Record for this Object. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2025-02-13
* @systemLayer    Trigger Handler
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class BoardGameRatingsTriggerHandler extends BaseTriggerHandler {
    
    //Variables and Objects Used throughout the Trigger Handler
    private BoardGameRatingsService service;

    //Set Final Strings for Error Messages
    //Use Final Strings so that exact text can be used in the Test Class without worrying about text changes
    @TestVisible private static final String ERR_MESSAGE = 'An Error Occured {0} in the Board Game Ratings Trigger Handler: {1}';

    //Actual Constructor for the Trigger Handler
    public BoardGameRatingsTriggerHandler(List<Board_Game_Rating__c> sObjectList){
        //Get Custom Metadata Type for Domain
        super('BoardGameRatings', BoardGameRatingsTriggerHandler.class, sObjectList); //Calls the Constructor from the Parent Class
    }

    @TestVisible
    //Constructor Used For Testing and Setting Own Config File
    private BoardGameRatingsTriggerHandler(Domain_Config__mdt config, List<Board_Game_Rating__c> sObjectList)
    {
        super(config, BoardGameRatingsTriggerHandler.class, sObjectList); // Calls the protected constructor of BaseTriggerHandler with custom config record for Testing
    }

    //Abstract methods Must be overriden by Child Classes.
    //The Child Initialize method will be what is used in the constructor  
    protected override void initialize(){
        service = (BoardGameRatingsService) BoardGameRatingsService.newInstance();
    }

    public override void onAfterInsert(){
        //Initialize Unit of Work from Application Layer
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        
        if(this.domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).disableAfterInsert(); 
        }

        try{         
            //Do Work
            service.setNewFavorite(uow, super.getRecords());

            //Perform DML on all Registered Records
            uow.commitWork();
        }
        catch (Exception ex) 
        {
            //Bypass Error Handling, If Enabled
            if(this.domainConfig.Bypass_Error_Handling__c)
            {
                System.debug('An Error Occured After Insert: ' + ex.getMessage());
            }
            else 
            {
                throw new BGRatingsTriggerHandlerException( String.format(ERR_MESSAGE, new String[]{'After Insert', ex.getMessage()}));
            }
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        //Initialize Unit of Work from Application Layer
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        
        //Prevent Recursion on After Update, If enabled
        if(this.domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameRatingsTriggerHandler.class).disableAfterUpdate(); 
        }

        try{         
            //Do Work
            service.setNewFavorite(uow, super.getRecords(), existingRecords);

            //Perform DML on all Registered Records
            uow.commitWork();
        }
        catch (Exception ex) 
        {
            //Bypass Error Handling, If Enabled
            if(this.domainConfig.Bypass_Error_Handling__c)
            {
                System.debug('An Error Occured After Update: ' + ex.getMessage());
            }
            else 
            {
                throw new BGRatingsTriggerHandlerException( String.format(ERR_MESSAGE, new String[]{'After Update', ex.getMessage()}));
            }
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new BoardGameRatingsTriggerHandler(sObjectList);
		}
	}

    public class BGRatingsTriggerHandlerException extends Exception {}

}