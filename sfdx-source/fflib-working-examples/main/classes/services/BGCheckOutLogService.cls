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
public inherited sharing class BGCheckOutLogService implements IBGCheckOutLogService {
    
    @TestVisible private static final String NO_BGLE_ID_ERR_MSG = 'Invalid Library Entry ID';
    @TestVisible private static final String NO_CHK_OUT_TIME_ERR_MSG = 'Check Out Time Required';
    @TestVisible private static final String FUTURE_CHK_OUT_TIME_ERR_MSG = 'Check Out Time Cannot be in the Future';
    @TestVisible private static final String NO_ATTENDEE_ID_ERR_MSG = 'Invalid Attendee ID';
    @TestVisible private static final String NO_LOG_ID_ERR_MSG = 'Invalid Check Out Log ID';
    @TestVisible private static final String NO_CHK_IN_TIME_ERR_MSG = 'Check In Time Required';
    @TestVisible private static final String INVALID_CHK_IN_TIME_ERR_MSG = 'Check In Time Cannot be Before Check Out Time';

    public void createCheckOutLog(fflib_SObjectUnitOfWork uow, Id bgleId, Id attendeeId, Datetime checkOutTime){
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