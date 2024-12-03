/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex Controller for the Board Game Importer LWC
*
* All Logic passed along to the Service Layer
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2024-11-30
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BoardGameImporterController {
    
    // Method to get a list of events
    // Method is Cacheable to improve runtime performance and is not performing any DML
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getEventList() {
        EventSelector eventSelector = (EventSelector) Application.Selector.newInstance(Event__c.sObjectType);
        return eventSelector.selectAll(); //Get all Events (In a real scenario this might need to be filtered by date or by owner or something similiar)
    }

    //Method to Call the Board Game Service to perform actual logic on import
    @AuraEnabled
    public static String importFromBGG(ID eventId, String collectionNameOrGeekListId, Boolean isGeekList, Boolean updateExisiting){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGamesService service = (BoardGamesService) Application.Service.newInstance(IBoardGamesService.class);
        
        String returnResult = service.getBoardGameDetailsFromBGG(uow, 
                                                                eventId, 
                                                                collectionNameOrGeekListId, 
                                                                isGeekList, 
                                                                updateExisiting);

        uow.commitWork(); //All DMLs for method are actually performed here
        return returnResult;
        
    }
}