/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Service Class for the Board Game Object.
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
* @created        2024-11-30
* @modified       2025-02-13
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class BoardGamesService extends BaseService implements IBoardGamesService {
    
    //Set Variables used throughout Service    
    private BGGCalloutService bggHttpService;
    private BoardGameSelector bgSelector;
    private BGLibraryEntrySelector bgleSelector;
    private BGLibraryEntryService bgleService;

    //Set Final Strings for Return Messages
    //Use Final Strings so that exact text can be used in the Test Class without worrying about text changes
    @TestVisible private final String SERVICE_NOT_ENABLED_MSG = 'This Service is Not Enabled. Please Contact a System Administrator to Enable';
    @TestVisible private final String SUCCESS_MSG = '{0} New Games Added. {1} Games Updated. {2}';
    @TestVisible private final String UNPROCESSED_FOUND_MSG = '{0} of {1} Board Games Unprocessed.';
    @TestVisible private final String EVENT_ID_INVALID_MSG = 'Invalid Event. Please Select a Valid Event';
    @TestVisible private final String MISSING_COLLECTION_NAME = 'Collection Name Required';
    @TestVisible private final String MISSING_GEEK_ID = 'Geek List ID Required';
    @TestVisible private final String NO_RECORD_IDS_PROVIDED_MSG = 'No Record IDs or BGG IDs Found';
    @TestVisible private final String UPDATE_RECORD_SUCCESS_MSG = 'The Following Board Games have been Refreshed: {0}. {1}';
    @TestVisible private final String NO_RECORDS_UPDATED_ERR_MSG = 'BGG Game ID Not Found in BoardGameGeek. Please Check the BGG ID and Try Again';
    @TestVisible private final String COLLECTION = 'Collection';
    @TestVisible private final String GEEKLIST = 'GeekList';

    //Initialize Service Class
    public static IBoardGamesService newInstance(){
        return (IBoardGamesService) Application.Service.newInstance(IBoardGamesService.class);
    }

    public BoardGamesService(){
        super('BoardGames'); //Calls the Constructor from the Parent Class
    }

    @TestVisible
    //Private Constructor for Testing to provide own Service Config
    private BoardGamesService(List<Services_Config__mdt> configList){      
        super(configList, 'BoardGames'); // Calls the protected constructor of BaseService with custom config list for Testing
    }

    //Abstract Method from Parent that Must be Overridden
    //Method called in Parent Constructor
    protected override void initialize(){
        //Initialize Serivces and Selectors through Application Layer 
        //so they can be Mocked and Stubbed from the Test Class
        bggHttpService = (BGGCalloutService) BGGCalloutService.newInstance();
        bgleService = (BGLibraryEntryService) BGLibraryEntryService.newInstance();
        bgSelector = (BoardGameSelector) BoardGameSelector.newInstance();
        bgleSelector = (BGLibraryEntrySelector) BGLibraryEntrySelector.newInstance();
    }

    /**
     * Makes callout to BGG API to get all of the BGG IDs for a given collection or geeklist. 
     * For Each Returned ID, determines if that ID is a new Board Game to be added or if the Board Game should be updated.
     * Also determines if a new Library Entry needs to be added or updated for the given Event.
     * Finally, if the Board Game is no longer in the given collection, removes the Library Entry from Event if requested 
     * @param uow is the UnitOfWork Object that holds the DML transactions to be commited
     * @param params is a map of generic objects passes to the method using the key of the map as the attribute name
     * @return a custom Object that holds multiple lists of records that were created or updated. Object contatins the following information
         * - List of Games Created 
         * - List of Games Updated 
         *      - Map of Values Updated
         * - List of BGLEs Created 
         * - List of BGLEs Updated 
         *      - Map of Values Updated
         * - List of BGLEs Removed 
         * - If Error Occured
         *      - List of Error Messages
         *      - Number of BGG IDs Unprocessed
     */
    public BoardGameServiceResults getBoardGameDetailsFromBGG(fflib_SObjectUnitOfWork uow, Map<String, Object> params){
        
        //If Service NOT enabled, Throw Error
        if(!this.serviceEnabled('getBoardGameDetailsFromBGG')){ //Check if this Service Method is Enabled from Parent
            throw new BGServiceException(SERVICE_NOT_ENABLED_MSG);
        }
        
        //Validate Inputs
        Id eventId = params.containsKey('eventId') ? (Id) params.get('eventId') : null;
        if(eventId == null || eventId.getSObjectType().getDescribe().getName() != 'Event__c'){
            throw new BGServiceException(EVENT_ID_INVALID_MSG);
        }

        Boolean isGeekList = params.containsKey('isGeekList') ? (Boolean) params.get('isGeekList') : false;
        if(!params.containsKey('collectionNameOrGeekListId')){
            throw new BGServiceException( isGeekList ? MISSING_GEEK_ID : MISSING_COLLECTION_NAME);
        }

        //Set Return Value
        BoardGameServiceResults rtv = new BoardGameServiceResults();
        rtv.eventId = eventId;
        rtv.sourceType = isGeekList ? GEEKLIST : COLLECTION;
        rtv.sourceName = (String) params.get('collectionNameOrGeekListId');

        //Get All BGG IDs for Collection or Geek List
        BGGCalloutService.CalloutResult calloutResult = bggHttpService.getIDsFromBoardGameGeek((String) params.get('collectionNameOrGeekListId'), isGeekList);
        checkForErrors(calloutResult, rtv);

        Set<String> bggIds = calloutResult.wrapperMap.keySet();

        //Get All Exisiting Board Games Based on BGG IDs
        //Create Map Based on BGG Id
        Map<String, Board_Games__c> mapBoardGames = new Map<String, Board_Games__c>();
        for(Board_Games__c thisBG : bgSelector.selectByBGGIDs(bggIds)){
            mapBoardGames.put(thisBG.BGG_ID__c, thisBG);
        }

        //Get All Existing BGLEs for Event and Given Source
        //Create Map Based on BBG ID
        Map<String, BG_Library_Entry__c> mapBGLEs = new Map<String, BG_Library_Entry__c>();
        //Get All BGLEs for Given Source and Given Evnet
        for(BG_Library_Entry__c bgle : bgleSelector.selectByEventIDsAndSources(new Set<Id>{eventId}, new Set<String>{rtv.sourceName})){
            mapBGLEs.put(bgle.Board_Game__r.BGG_ID__c, bgle);
        }
      
        // Seperate New and Exisiting BBG IDs for both Board Games and BGLEs
        Set<String> newBGGIdsForBG = new Set<String>();
        Map<String, Board_Games__c> newBGGIdsForBGLE = new Map<String, Board_Games__c>();
        Map<String, Board_Games__c> existingBoardGames = new Map<String, Board_Games__c>();
        Map<String, BG_Library_Entry__c> existingBGLEs = new Map<String, BG_Library_Entry__c>();

        for(String bggId : bggIds){
            // Seperate New and Exisiting Board Games
            if(!mapBoardGames.containsKey(bggId)){
                newBGGIdsForBG.add(bggId);
            }
            else{
                existingBoardGames.put(bggId, mapBoardGames.get(bggId));
            }

            // Seperate New and Exisiting BGLEs
            if(!mapBGLEs.containsKey(bggId)){
                newBGGIdsForBGLE.put(bggId, mapBoardGames.get(bggId));// Add Existing Board Game, if one Exists
            }
            else{
                existingBGLEs.put(bggId, mapBGLEs.get(bggId));
            }
        }
        
        //If Brand New Game to System, Create board game Record
        addNewBoardGames(uow, rtv, newBGGIdsForBG);
        //If New BGLE for Event, Create BGLE for Event
        bgleService.createNewBGLEs(uow, rtv, calloutResult.wrapperMap, newBGGIdsForBGLE);        

        //If Update Existing Option was Checked, Update Existing Board Games and BGLEs
        if(params.containsKey('updateExisting') && (Boolean) params.get('updateExisting')){
            updateExistingBoardGames(uow, rtv, existingBoardGames);
            bgleService.updateBGLEs(uow, rtv, calloutResult.wrapperMap, existingBGLEs);
        }

        //If Update Removed Option was Checked, Update Existing BGLEs to be removed
        if(params.containsKey('updateRemoved') && (Boolean) params.get('updateRemoved')){
            Boolean perserveLogs = params.containsKey('perserveLogs') ? (Boolean) params.get('perserveLogs') : true;
            bgleService.deleteRemovedBoardGamesFromBGLEs(uow, rtv, mapBGLEs, bggIds, perserveLogs);
        }

        /**
         * Return: 
         * - List of Games Created 
         *      - Show List As New
         * - List of Games Updated 
         *      - Show Values Updated
         * - List of BGLEs Created 
         *      - Show List As New
         * - List of BGLEs Updated 
         *      - Show Values Updated
         * - List of BGLEs Removed 
         *      - Show List As Removed
         * - Count of Unprocessed Ids
         * - If Error Occured
         *      - List of Error Messages
         *      - Number of BGG IDs Unprocessed
         */
        return rtv;
    }    

    /**
     * 
     */
    private void addNewBoardGames(fflib_SObjectUnitOfWork uow, BoardGameServiceResults results, Set<String> newBGGIds){

        //Make Callout to get Board Game Details for New Board Games
        BGGCalloutService.CalloutResult detailsResult = bggHttpService.getBoardGameDetailFromBGGIds(newBGGIds);
        System.debug('detailsResult: '+ detailsResult);
        //Initialize Values
        results.newBoardGames = results.newBoardGames == null ? new List<Board_Games__c>() : results.newBoardGames;

        //Check for Errors
        checkForErrors(detailsResult, results);

        //For Each New Board Game returned, 
        // Create Board Game Record and add BG Library Entry for Event for Board 
        for(BoardGameWrapper wrapper : detailsResult.wrapperMap.values()){
            uow.registerNew(wrapper.boardGame);
            results.newBoardGames.add(wrapper.boardGame);
        }
    }

    /**
     * 
     */
    private void updateExistingBoardGames(fflib_SObjectUnitOfWork uow, BoardGameServiceResults results, Map<String, Board_Games__c> existingBoardGames){
                
        //Make Callout to get Board Game Details for Existing Board Games
        BGGCalloutService.CalloutResult detailsResult = bggHttpService.getBoardGameDetailFromBGGIds(existingBoardGames.keySet());
        
        //Initialize Values
        results.boardGameChanges = new Map<Id,Map<String,Map<Object,Object>>>();
        
        //Check for Errors
        checkForErrors(detailsResult, results);

        //Get CSV List of Fields queired from Selector
        String queriedFieldList = bgSelector.getFieldListString();

        for(String bggId : detailsResult.wrapperMap.keySet()){
            Board_Games__c oldValue = existingBoardGames.get(bggId);
            Board_Games__c newValue = detailsResult.wrapperMap.get(bggId).boardGame;
            newValue.Id = oldValue.Id;
            results.boardGameChanges.put(newValue.Id, compareValues(oldValue, newValue, queriedFieldList));
            uow.registerDirty(newValue);
            results.updatedBoardGames.add(newValue);
        }
    }

    /**
     * Checks the given Callout Result Object for Errors and Appends them to the Result Object
     * @param calloutResult is the Returned CallOutResult Object Given from the Callout Made
     * @param results is the current ServiceResults Object to Append Error Messages to.
     */
    private void checkForErrors(BGGCalloutService.CalloutResult calloutResult, BoardGameServiceResults results){
        
        results.unprocessedIds = results.unprocessedIds == null ? new Set<String>() : results.unprocessedIds;

        System.debug('Callout Result from Check Errors: '+ calloutResult);
        if(calloutResult.hasError){
            results.errorOccured = true;
            results.errorMessages.add(calloutResult.resultMessage);
            results.unprocessedIds.addAll(calloutResult.unprocessedIDs);
        }
    }

    /**
     * Compares all Field Values on the given Board Game Library Entry Objects
     * @param oldGame is the Old BGLE Values
     * @param newGame is the New BGLE Values
     * @param queriedFieldList is the String CSV list of the fields to compare
     * @return Nested Map with First Key is Field Name, Second Key is Old Value, Value is New Value. 
     */
    private Map<String, Map<Object, Object>> compareValues(Board_Games__c oldGame, Board_Games__c newGame, String queriedFieldList){
        //Initialize Change Map, if not already Initialized
        Map<String, Map<Object, Object>> changeMap = new Map<String, Map<Object, Object>>();
        
        //List of Changes
        Map<String, Map<Object, Object>> changes = new Map<String, Map<Object, Object>>();

        //Split Queried Field List into List
        for(String fieldName : queriedFieldList.split(',')){
            // Get Label of Field
            String fieldLabel = Board_Games__c.SObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();

            // Convert Object to String and set value to null if empty for comparison
            String oldValue = String.isBlank(String.valueOf(oldGame.get(fieldName))) ? null : String.valueOf(oldGame.get(fieldName));
            String newValue = String.isBlank(String.valueOf(newGame.get(fieldName))) ? null : String.valueOf(newGame.get(fieldName));

            // Check if Values are Numeric
            If(isNumber(oldValue) && isNumber(newValue)){
                //Convert Strings to Numbers for comparison
                Decimal oldNum = Decimal.valueOf(oldValue);
                Decimal newNum = Decimal.valueOf(newValue);
                if(oldNum != newNum){
                    changeMap.put(fieldLabel, new Map<Object, Object>{oldNum => newNum});
                }
          
            // != won't detect differences between different instances of equal values (e.g., same text), 
            // while equals() ensures accurate comparison
            } else if((oldValue == null && newValue != null) || (oldValue != null && !oldValue.equals(newValue))){
                changeMap.put(fieldLabel, new Map<Object, Object>{(oldValue == null ? '(Blank)' : oldValue) => (newValue == null ? '(Blank)' : newValue)});
            }
        }
        return changeMap;    
    }

    private Boolean isNumber(String val){
        if (String.isBlank(val)) return false;
        try {
            Decimal test = Decimal.valueOf(val);
            return true;
        } catch (Exception e) {
            return false;
        }    
    }

    /**
     * Updates Board Game Information from BGG for Individual Games
     * @param uow is the UnitOfWork Object that will record all of the DML Transactions
     * @param recordIdToBGGIdMap Map of Board Game IDs to Update. Key is the Board Game Record ID and Value is the BGG ID
     * @return Returns String Message of Results
     */
    public String updateBoardGameDetailsFromBGG(fflib_SObjectUnitOfWork uow, Map<ID, String> recordIdToBGGIdMap){
        //If Service NOT enabled, Throw Error
        if(!this.serviceEnabled('updateBoardGameDetailsFromBGG')){ //Check if this Service Method is Enabled from Parent
            throw new BGServiceException(SERVICE_NOT_ENABLED_MSG);
        }

        //Validate Inputs
        if(recordIdToBGGIdMap == null || recordIdToBGGIdMap.size() == 0){
            throw new BGServiceException(NO_RECORD_IDS_PROVIDED_MSG);
        }

        //Call HttpService to Get Details 
        BGGCalloutService.CalloutResult result = bggHttpService.getBoardGameDetailFromBGGIds(recordIdToBGGIdMap);
        
        //If Result Message exists from an error
        // And NOT from unprocessed IDs
        // Return Result message back to User as Error
        if(result.resultMessage != null && result.unprocessedIDs.size() == 0){
            throw new BGServiceException(result.resultMessage);
        }

        //Otherwise, Update Board Game Records in Map
        List<String> updatedGameNames = new List<String>();
        For(BoardGameWrapper wrapper : result.wrapperMap.values()){
            //IF BGG ID is Not included in  Unprocessed IDs, 
            // AND Board Game Name on Board Game is NOT NULL 
            // Update Board Game
            if(!result.unprocessedIDs.contains(wrapper.boardGame.BGG_ID__c)
                && wrapper.boardGame.Name != null){
                wrapper.boardGame.Is_New__c = false;
                updatedGameNames.add(wrapper.boardGame.Name);
                uow.registerDirty(wrapper.boardGame);
            }
        }

        //If List of Update Board Game Names is Empty, 
        // Then No Board Games were Returned for the IDs Given
        // So Throw Error
        if(updatedGameNames.isEmpty()){
            throw new BGServiceException(NO_RECORDS_UPDATED_ERR_MSG);
        }

        String unprocessedMsg ='';
        if(result.unprocessedIDs.size() > 0){
            unprocessedMsg = String.format(UNPROCESSED_FOUND_MSG, 
                                                        new Integer[]{
                                                            result.unprocessedIDs.size(), 
                                                            result.wrapperMap.size()
                                                        } );
        }

        return String.format(UPDATE_RECORD_SUCCESS_MSG, new List<String>{
                                                            String.join(updatedGameNames, ', '),  //CSV List of Names of Games Updated
                                                            unprocessedMsg //Result of Unprocessed Games
                                                        });
    }

    public class BGServiceException extends Exception {}

}