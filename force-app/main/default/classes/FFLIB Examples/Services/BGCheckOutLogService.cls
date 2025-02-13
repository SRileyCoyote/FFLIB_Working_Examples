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
* @created        2025-01-09
* @modified       2025-02-13
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class BGCheckOutLogService extends BaseService implements IBGCheckOutLogService {
    
    //Set Variables, Domains, and Selectors used throughout Service
    private BGCheckOutLogDomain domain;
    @TestVisible private static final String SERVICE_NOT_ENABLED_MSG = 'This Service is Not Enabled. Please Contact a System Administrator to Enable';
    @TestVisible private static final String NO_BGLE_ID_ERR_MSG = 'Invalid Library Entry ID';
    @TestVisible private static final String NO_CHK_OUT_TIME_ERR_MSG = 'Check Out Time Required';
    @TestVisible private static final String FUTURE_CHK_OUT_TIME_ERR_MSG = 'Check Out Time Cannot be in the Future';
    @TestVisible private static final String NO_ATTENDEE_ID_ERR_MSG = 'Invalid Attendee ID';
    @TestVisible private static final String NO_LOG_ID_ERR_MSG = 'Invalid Check Out Log ID';
    @TestVisible private static final String NO_CHK_IN_TIME_ERR_MSG = 'Check In Time Required';
    @TestVisible private static final String INVALID_CHK_IN_TIME_ERR_MSG = 'Check In Time Cannot be Before Check Out Time';

    //Initialize Service Class
    public static IBGCheckOutLogService newInstance(){
        return (IBGCheckOutLogService) Application.Service.newInstance(IBGCheckOutLogService.class);
    }

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
        //Initialize Any Selectors through Application Layer 
        // so they can be Mocked and Stubbed from the Test Class
    }

    public void setTotalCheckOutTime(List<BG_Checkout_Log__c> records){
        setTotalCheckOutTime(records, null);
    }

    public void setTotalCheckOutTime(List<BG_Checkout_Log__c> records, Map<ID, SObject> existingRecords){
        
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
            //Set Total_Check_Out_Time_Value__c field to equal the formula field Value
            record.Total_Check_Out_Time_Value__c = record.Total_Check_Out_Time_Formula__c;
        }
    }

    public void createCheckOutLog(fflib_SObjectUnitOfWork uow, Id bgleId, Id attendeeId, Datetime checkOutTime){
        //If Not Enabled, Throw Error
        if(!this.serviceEnabled('createCheckOutLog')){ //Check if this Service Method is Enabled from Parent
            throw new BGCheckOutLogServiceException(SERVICE_NOT_ENABLED_MSG);
        }
        //Validate Inputs
        if(bgleId == null || bgleId.getSObjectType() != BG_Library_Entry__c.getSObjectType()){
            throw new BGCheckOutLogServiceException(NO_BGLE_ID_ERR_MSG);
        }
        if(attendeeId == null || attendeeId.getSObjectType() != Event_Attendee__c.getSObjectType()){
            throw new BGCheckOutLogServiceException(NO_ATTENDEE_ID_ERR_MSG);
        }
        if(checkOutTime == null){
            throw new BGCheckOutLogServiceException(NO_CHK_OUT_TIME_ERR_MSG);
        }
        if(checkOutTime > System.now()){
            throw new BGCheckOutLogServiceException(FUTURE_CHK_OUT_TIME_ERR_MSG);
        }
        
        //Create Record
        BG_Checkout_Log__c log = new BG_Checkout_Log__c();
        log.BG_Library_Entry__c = bgleId;
        log.Checked_Out_By__c = attendeeId;
        log.Check_Out_Time__c = checkOutTime;
        uow.registerNew(log);
    }

    public void updateCheckOutLog(fflib_SObjectUnitOfWork uow, BG_Checkout_Log__c log, Datetime checkInTime){
        //If Not Enabled, Throw Error
        if(!this.serviceEnabled('updateCheckOutLog')){ //Check if this Service Method is Enabled from Parent
            throw new BGCheckOutLogServiceException(SERVICE_NOT_ENABLED_MSG);
        }
        //Validate Inputs
        if(log == null || log.Id == null){
            throw new BGCheckOutLogServiceException(NO_LOG_ID_ERR_MSG);
        }
        if(checkInTime == null){
            throw new BGCheckOutLogServiceException(NO_CHK_IN_TIME_ERR_MSG);
        }
        if(checkInTime < log.Check_Out_Time__c){
            throw new BGCheckOutLogServiceException(INVALID_CHK_IN_TIME_ERR_MSG);
        }
        
        //Update Record
        log.Check_In_Time__c = checkInTime;
        uow.registerDirty(log);
    }

    public class BGCheckOutLogServiceException extends Exception {}
}