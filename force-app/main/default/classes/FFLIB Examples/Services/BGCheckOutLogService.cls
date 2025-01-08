/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Service Class for the Board Game Check Out Log Object.
*
* Service Classes are where all of the method logic is completed. UnitOfWork Objects 
* as well as any other parameters are passed into each method as needed. A Config MDT record
* should exist for each Service Method.
*
* Service Classes Extend from a Base Service Class that houses the common logic for 
* retrieving and checking if services are enabled.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-08
* @modified       2025-01-08
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class BGCheckOutLogService extends BaseService implements IBGCheckOutLogService {
    
    //Set Variables, Domains, and Selectors used throughout Service
    private BGCheckOutLogDomain domain;

    //Initialize Service Class
    public BGCheckOutLogService(){
        super('BGCheckOutLog'); //Calls the Constructor from the Parent Class
    }

    @TestVisible
    //Private Constructor for Testing to provide own Service Config
    private BGCheckOutLogService(List<Services_Config__mdt> configList){
        super(configList, 'BGCheckOutLog');  // Calls the protected constructor of BaseService with custom config list
    }

    //Abstract Method from Parent that Must be implemented
    protected override void initialize(){
        //Initialize Selectors through Application Layer 
        // so they can be Mocked and Stubbed from the Test Class
    }

    public void setTotalCheckOutTime(fflib_SObjectUnitOfWork uow, List<BG_Checkout_Log__c> records){
        setTotalCheckOutTime(uow, records, null);
    }

    public void setTotalCheckOutTime(fflib_SObjectUnitOfWork uow, List<BG_Checkout_Log__c> records, Map<ID, SObject> existingRecords){
        
        domain = (BGCheckOutLogDomain) Application.Domain.newInstance(records);
        domain.setExistingRecords(existingRecords);

        //If Not Enabled, Do Nothing
        if(!this.serviceEnabled('setTotalCheckOutTime')){ //Check if this Service Method is Enabled from Parent
            return;
        }

        //Filter given Records to only those where Time In Value is Changed 
        records = domain.getChanged('Check_In_Time__c');
        //Filter Given Records to only those where Check Out Log is Completed
        records = domain.getCompletedCheckOutLogs(records);

        for(BG_Checkout_Log__c record : records){
            //Set Total_Min_Checked_Out__c field to equal the formula field Value
            record.Total_Min_Checked_Out__c = record.Total_Check_Out_Time__c;
            uow.registerDirty(record);
        }

    }

    public class BGCheckOutLogServiceException extends Exception {}
}