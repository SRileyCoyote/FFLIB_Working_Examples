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
* @modified       2025-02-13
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BoardGameImporterController {
    
    // Method to get a list of events
    // Method is Cacheable to improve runtime performance and is not performing any DML
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getEventList() {
        EventSelector eventSelector = (EventSelector) EventSelector.newInstance();
        return eventSelector.selectAll(); //Get all Events (In a real scenario this might need to be filtered by date or by owner or something similiar)
    }

    // Method to get a list of Existing Collections and Geeklist Ids
    // Method is Cacheable to improve runtime performance and is not performing any DML
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getEventSources(Id eventId) {
        if (String.isBlank(eventId)) {
            return new Map<String, String>();
        }
    
        BGLibraryEntryService service = (BGLibraryEntryService) BGLibraryEntryService.newInstance();
        return service.getSourcesByEvent(eventId); 
    }


    //Method to Call the Board Game Service to perform actual logic on import
    @AuraEnabled
    public static String importFromBGG(ID eventId, 
                                            String collectionNameOrGeekListId, 
                                            Boolean isGeekList, 
                                            Boolean updateExisiting,
                                            Boolean deleteRemoved){
        
        //Initializing Unit of Work here and Passing as variable to Service
        //Done this way so that all DMLs are performed in this method
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
        BoardGamesService service = (BoardGamesService) BoardGamesService.newInstance();
        BGLibraryEntrySelector bgleSelecter = (BGLibraryEntrySelector) BGLibraryEntrySelector.newInstance();

        Map<String, Object> params = new Map<String,Object>{
            'collectionNameOrGeekListId' => collectionNameOrGeekListId,
            'eventId' => eventId,
            'isGeekList' => isGeekList,
            'updateExisting' => updateExisiting,
            'updateRemoved' => deleteRemoved
        };
        
        BoardGameServiceResults returnResult = service.getBoardGameDetailsFromBGG(uow, params);

        uow.commitWork(); //All DMLs for method are actually performed here

        //Get Updated Board Game and BGLE Information
        returnResult.newBGLEs = returnResult.newBGLEs != null && returnResult.newBGLEs.size() > 0 ? bgleSelecter.selectById(new Map<Id, BG_Library_Entry__c>(returnResult.newBGLEs).keySet()) : returnResult.newBGLEs;
        returnResult.updatedBGLEs = returnResult.updatedBGLEs != null && returnResult.updatedBGLEs.size() > 0 ? bgleSelecter.selectById(new Map<Id, BG_Library_Entry__c>(returnResult.updatedBGLEs).keySet()) : returnResult.updatedBGLEs;
        returnResult.removedBGLEs = returnResult.removedBGLEs != null && returnResult.removedBGLEs.size() > 0 ? bgleSelecter.selectById(new Map<Id, BG_Library_Entry__c>(returnResult.removedBGLEs).keySet()) : returnResult.removedBGLEs;

        System.debug(returnResult.newBGLEs);
        return JSON.serialize(returnResult);
        
    }
}