/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler for all Board Games Check Out Log Trigger.
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
* @created        2025-01-09
* @modified       2025-02-13
* @systemLayer    Trigger Handler
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class BoardGameCheckOutLogTriggerHandler extends BaseTriggerHandler {
    
    //Variables and Objects Used throughout the Trigger Handler
    private BGCheckOutLogService service;
    
    //Set Final Strings for Error Messages
    //Use Final Strings so that exact text can be used in the Test Class without worrying about text changes
    @TestVisible private static final String ERR_MESSAGE = 'An Error Occured {0} in the Board Game Check Out Logs Trigger Handler: {1}';

    //Actual Constructor for the Trigger Handler
    public BoardGameCheckOutLogTriggerHandler(List<BG_Checkout_Log__c> sObjectList){
        //Get Custom Metadata Type for Domain
        super('BGCheckOutLog', BoardGameCheckOutLogTriggerHandler.class, sObjectList); //Calls the Constructor from the Parent Class
    }

    @TestVisible
    //Constructor Used For Testing and Setting Own Config File
    private BoardGameCheckOutLogTriggerHandler(Domain_Config__mdt config, List<BG_Checkout_Log__c> sObjectList)
    {
        super(config, BoardGameCheckOutLogTriggerHandler.class, sObjectList); // Calls the protected constructor of BaseTriggerHandler with custom config record for Testing
    }

    //Abstract methods Must be overriden by Child Classes.
    //The Child Initialize method will be what is used in the constructor  
    protected override void initialize(){
        service = (BGCheckOutLogService) BGCheckOutLogService.newInstance();
    }

    public override void onBeforeInsert(){
        
        if(this.domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameCheckOutLogTriggerHandler.class).disableBeforeInsert(); 
        }

        try{         
            //Do Work
            service.setTotalCheckOutTime(super.getRecords());
        }
        catch (Exception ex) 
        {
            //Bypass Error Handling, If Enabled
            if(this.domainConfig.Bypass_Error_Handling__c)
            {
                System.debug('An Error Occured Before Insert: ' + ex.getMessage());
            }
            else 
            {
                throw new BGCheckOutLogTriggerHandlerException( String.format(ERR_MESSAGE, new String[]{'Before Insert', ex.getMessage()}));
            }
        }
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords){
        
        //Prevent Recursion on Before Update, If enabled
        if(this.domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(BoardGameCheckOutLogTriggerHandler.class).disableBeforeUpdate(); 
        }

        try{         
            //Do Work
            service.setTotalCheckOutTime(super.getRecords(), existingRecords);
        }
        catch (Exception ex) 
        {
            //Bypass Error Handling, If Enabled
            if(this.domainConfig.Bypass_Error_Handling__c)
            {
                System.debug('An Error Occured Before Update: ' + ex.getMessage());
            }
            else 
            {
                throw new BGCheckOutLogTriggerHandlerException( String.format(ERR_MESSAGE, new String[]{'Before Update', ex.getMessage()}));
            }
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new BoardGameCheckOutLogTriggerHandler(sObjectList);
		}
	}

    public class BGCheckOutLogTriggerHandlerException extends Exception {}

}