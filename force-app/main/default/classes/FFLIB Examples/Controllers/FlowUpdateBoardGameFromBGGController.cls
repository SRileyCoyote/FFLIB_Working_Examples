/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex Controller for the UpdateRecordFromBGG Flow.
*
* All Logic passed along to the Service Layer
*
* With Sharing is REQUIRED for the InvocableMethod used by the Flow to be visible as an Action. 
* Classes are limited to ONE InvocableMethod per class  
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-03
* @modified       2025-02-13
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class FlowUpdateBoardGameFromBGGController {

    //Invocable Methods Required a List of Parameters to be passed in
    // and a List of Values to be returned. By Using the input Parameter of a Wrapper
    // class. We can make the variables in the wrapper visible to the flow by using the
    // InvocableVariable annotation which will allow us to set the variables in the Flow  
    @InvocableMethod(label='Update Game Records From BGG' description='Updates Given Board Game Values from BoardGameGeek API' category='BoardGameGeeek API')
    public static List<String> updateMultipleGameRecordsFromBGG(List<InputWrapper> inputs){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGamesService service = (BoardGamesService) BoardGamesService.newInstance();

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