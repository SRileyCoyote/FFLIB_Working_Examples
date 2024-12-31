/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex Controller for the Update From BGG LWC and the Update From BGG Flow. This maybe should be
* two seperate Controllers, one for the LWC and one for the Flow but as they are doing the same
* thing, just in seperate areas, it was easier to just reuse this Controller
*
* All Logic passed along to the Service Layer
*
* With Sharing is REQUIRED for the InvocableMethod used by the Flow to be visible as an Action. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-26
* @modified       2024-12-30
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class UpdateFromBGGController {

    @AuraEnabled
    public static string UpdateRecordFromBGG(ID recordId, String bggId){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGamesService service = (BoardGamesService) Application.Service.newInstance(IBoardGamesService.class);

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

    //Invocable Methods Required a List of Parameters to be passed in
    // and a List of Values to be returned. By Using the input Parameter of a Wrapper
    // class. We can make the variables in the wrapper visible to the flow by using the
    // InvocableVariable annotation which will allow us to set the variables in the Flow  
    @InvocableMethod(label='Update Records From BGG' description='Updates Given Board Game Values from BoardGameGeek API' category='BoardGameGeeek API')
    public static List<String> UpdateRecordsFromBGG(List<InputWrapper> inputs){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGamesService service = (BoardGamesService) Application.Service.newInstance(IBoardGamesService.class);

        //Convert Input Values into Map
        Map<ID, String> boardGameIdMap = new Map<ID, String>();

        for(InputWrapper input : inputs){
            for(Board_Games__c game : input.boardGames){
                boardGameIdMap.put(game.Id, game.BGG_Id__c);
            }
        }   

        String resultMsg;
        
        try {
            //Do Work
            // Call Service passing UOW as Parameter for Updates
            // Reusing the same method used for the LWC as it has already been built to
            // accept Bulk Inputs.
            resultMsg = service.updateBoardGameDetailsFromBGG(uow, boardGameIdMap);
            uow.commitWork();
        } catch (Exception e) {
            System.debug('Error Thrown in Controller: ' + e);
            throw new FlowException(e.getMessage());
        }

        return new List<String>{resultMsg};
    }

    public class InputWrapper {
        @InvocableVariable(required=true label='Board Game List')
        public List<Board_Games__c> boardGames;
    }
    
}