/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex Controller for the checkOutGame, chekInGame, and checkOutLogContainer LWCs. This maybe should be
* seperate Controllers, but as they are doing the similar things, it was easier to just reuse 
* this Controller for all LWCs
*
* All Logic passed along to the Service and Selector Layers
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-02-05
* @modified       2025-02-05
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class checkOutLogController {
    
    //cacheable needs to be true for SOQL Calls
    @AuraEnabled(cacheable=true)
    public static List<Event_Attendee__c> getEventAttendeesByEventId(Id eventId){
        AuraHandledException auraEx = new AuraHandledException('Message');
        //Validate Inputs
        if (String.isBlank(eventId)) {
            auraEx.setMessage('Event ID cannot be null or empty.');
            throw auraEx;
        }
        try {
            EventAttendeeSelector selector = (EventAttendeeSelector) EventAttendeeSelector.newInstance();
            List<Event_Attendee__c> results = selector.selectByEventIDs(new Set<Id>{eventId});
            //If No results returned, throw error instead of an empty list
            if (results.isEmpty()) {
                auraEx.setMessage('No Event Attendees found for this event.');
                throw auraEx;
            }
            return results;
        } catch (Exception e) {
            System.debug('Error Thrown in Controller: ' + e);
            //AuraHandledExceptions are quirky in that, regardless of the message given,
            // the message on the exception is "Script-thrown exception"
            // Setting the message this way passes along the correct message recieved
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<BG_Library_Entry__c> getBGLEs(Id recordId, string sObjectType){
        AuraHandledException auraEx = new AuraHandledException('Message');
        try {
            BGLibraryEntrySelector bgleSelector = (BGLibraryEntrySelector) BGLibraryEntrySelector.newInstance();
            
            switch on sObjectType {
                when 'BG_Library_Entry__c' {
                    return bgleSelector.selectById(new Set<Id>{recordId});
                }
                when 'Board_Games__c' {
                    return bgleSelector.selectByBoardGameId(new Set<Id>{recordId});
                }
                when 'Board_Game_Rating__c' {
                    BoardGameRatingSelector bgrSelector = (BoardGameRatingSelector) BoardGameRatingSelector.newInstance();
                    List<Board_Game_Rating__c> records = bgrSelector.selectById(new Set<Id>{recordId});
                    return records.size() > 0 ? bgleSelector.selectByBoardGameId(new Set<Id>{records[0].Board_Game__c}) : new List<BG_Library_Entry__c>();
                }
                when 'BG_Checkout_Log__c' {
                    BGCheckOutLogSelector logSelector = (BGCheckOutLogSelector) BGCheckOutLogSelector.newInstance();
                    List<BG_Checkout_Log__c> records = logSelector.selectById(new Set<Id>{recordId});
                    return records.size() > 0 ? bgleSelector.selectById(new Set<Id>{records[0].BG_Library_Entry__c}) : new List<BG_Library_Entry__c>();
                }
                when else {
                    auraEx.setMessage('Invalid SObject Type.');
                    throw auraEx;        
                }
            }
        } catch (Exception e) {
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<BG_Checkout_Log__c> getCheckOutLogs(Id recordId, string sObjectType){
        AuraHandledException auraEx = new AuraHandledException('Message');
        try {
            BGCheckOutLogSelector logSelector = (BGCheckOutLogSelector) BGCheckOutLogSelector.newInstance();

            switch on sObjectType {
                when 'BG_Library_Entry__c' {
                    return logSelector.selectByLibraryEntryId(new Set<Id>{recordId});
                }
                when 'Board_Games__c' {
                    return logSelector.selectByBoardGameId(new Set<Id>{recordId});
                }
                when 'Board_Game_Rating__c' {
                    BoardGameRatingSelector bgrSelector = (BoardGameRatingSelector) BoardGameRatingSelector.newInstance();
                    List<Board_Game_Rating__c> records = bgrSelector.selectById(new Set<Id>{recordId});
                    return records.size() > 0 ? logSelector.selectByBoardGameId(new Set<Id>{records[0].Board_Game__c}) : new List<BG_Checkout_Log__c>();
                }
                when 'BG_Checkout_Log__c' {
                    return logSelector.selectById(new Set<Id>{recordId});
                }
                when else {
                    auraEx.setMessage('Invalid SObject Type.');
                    throw auraEx;        
                }
            }
        } catch (Exception e) {
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    //cacheable needs to be false (default) if method has DML
    @AuraEnabled
    public static void createCheckOutLog(Id bgleId, Id attendeeId, Datetime checkOutDate){
        try {
            //Input Validation Handled in Service
            fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
            BGCheckOutLogService service = (BGCheckOutLogService) Application.Service.newInstance(IBGCheckOutLogService.class);
            service.createCheckOutLog(uow, bgleId, attendeeId, checkoutDate);
            uow.commitWork();
        } catch (Exception e) {
            System.debug('Error Thrown in Controller: ' + e);
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static void updateCheckOutLog(BG_Checkout_Log__c log, Datetime checkInDate){
        try {
            //Input Validation Handled in Service
            fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
            BGCheckOutLogService service = (BGCheckOutLogService) Application.Service.newInstance(IBGCheckOutLogService.class);
            service.updateCheckOutLog(uow, log, checkInDate);
            uow.commitWork();
        } catch (Exception e) {
            System.debug('Error Thrown in Controller: ' + e);
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }
}