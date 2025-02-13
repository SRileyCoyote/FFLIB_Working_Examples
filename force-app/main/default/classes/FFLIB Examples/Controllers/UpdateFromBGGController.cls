/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex Controller for the UpdateGameFromBGG and UpdateCollectionFromBGG LWCs. This maybe should be
* seperate Controllers, but as they are doing the similar things, it was easier to just reuse 
* this Controller for both LWCs
*
* All Logic passed along to the Service Layer
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-26
* @modified       2025-02-13
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class UpdateFromBGGController {

    @AuraEnabled
    public static string updateGameRecordFromBGG(ID recordId, String bggId){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGamesService service = (BoardGamesService) BoardGamesService.newInstance();

        String resultMsg;
        
        try {
            //Do Work
            //Call Service passing UOW as Parameter for Updates
            // Service Method accepts a Map instead of single individual values so that 
            // the process can be done in bulk and is Scaleable
            resultMsg = service.updateBoardGameDetailsFromBGG(uow, new Map<ID, String>{recordId => bggId});
            uow.commitWork();
        } catch (Exception e) {
            System.debug('Error Thrown in Controller: ' + e);
            //AuraHandledExceptions are quirky in that, regardless of the message given,
            // the message on the exception is "Script-thrown exception"
            // Setting the message this way passes along the correct message recieved
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }

        return resultMsg;
    }

    @AuraEnabled
    public static string updateLibraryEntryRecordFromBGG(ID recordId, BG_Library_Entry__c bgle){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BGLibraryEntryService service = (BGLibraryEntryService) BGLibraryEntryService.newInstance();

        String resultMsg;
        
        try {
            //Do Work
            //Call Service passing UOW as Parameter for Updates
            // Service Method accepts a List instead of single individual values so that 
            // the process can be done in bulk and is Scaleable
            resultMsg = service.updateBGLibraryEntriesFromBGG(uow, new List<BG_Library_Entry__c>{bgle});
            uow.commitWork();
        } catch (Exception e) {
            System.debug('Error Thrown in Controller: ' + e);
            //AuraHandledExceptions are quirky in that, regardless of the message given,
            // the message on the exception is "Script-thrown exception"
            // Setting the message this way passes along the correct message recieved
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }

        return resultMsg;
    }
}