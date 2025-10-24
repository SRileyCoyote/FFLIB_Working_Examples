/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Service Class for the Board Game Library Entry SObject.
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
* @created        2025-01-02
* @modified       2025-02-13
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class BGLibraryEntryService extends BaseService implements IBGLibraryEntryService{
    
    //Set Variables used throughout Service    
    private BGGCalloutService bggHttpService;
    private BGLibraryEntrySelector bgleSelector;
    private BGCheckOutLogSelector logSelector;

    //Set Final Strings for Return Messages
    //Use Final Strings so that exact text can be used in the Test Class without worrying about text changes
    @TestVisible private static final String SERVICE_NOT_ENABLED_MSG = 'This Service is Not Enabled. Please Contact a System Administrator to Enable';
    @TestVisible private static final String SUCCESS_MSG = '{0} Records Updated. {1}';
    @TestVisible private static final String NO_RECORDS_PROVIDED_MSG = 'No Records Selected';
    @TestVisible private static final String ERROR_TOO_MANY_CALLOUTS = 'Too Many Callouts. {0}';
    @TestVisible private static final String ERROR_RECORD_MISSING_SOURCE_ID = 'Board Game {0} Does Not Have a Source.';
    @TestVisible private static final String COLLECTION = 'Collection';
    @TestVisible private static final String GEEKLIST = 'GeekList';


    public static IBGLibraryEntryService newInstance(){
        return (IBGLibraryEntryService) Application.Service.newInstance(IBGLibraryEntryService.class);
    }

    public BGLibraryEntryService() {
        super('BGLibraryEntry'); //Calls the Constructor from the Parent Class
    }

    @TestVisible
    //Private Constructor for Testing to provide own Service Config
    private BGLibraryEntryService(List<Services_Config__mdt> configList){      
        super(configList, 'BGLibraryEntry'); // Calls the protected constructor of BaseService with custom config list for Testing
    }

    //Abstract Method from Parent that Must be Overridden
    //Method called in Parent Constructor
    protected override void initialize(){
        //Initialize Serivces and Selectors through Application Layer 
        //so they can be Mocked and Stubbed from the Test Class
        bgleSelector = (BGLibraryEntrySelector) BGLibraryEntrySelector.newInstance();
        bggHttpService = (BGGCalloutService) BGGCalloutService.newInstance();
        logSelector = (BGCheckOutLogSelector) BGCheckOutLogSelector.newInstance();
    }

    public String updateBGLibraryEntriesFromBGG(fflib_SObjectUnitOfWork uow, List<BG_Library_Entry__c> bgleList){
        //If Service NOT enabled, Throw Error
        if(!this.serviceEnabled('updateBGLibraryEntryFromBGG')){ //Check if this Service Method is Enabled from Parent
            throw new BGLEServiceException(SERVICE_NOT_ENABLED_MSG);
        }

        //Validate Inputs
        if(bgleList == null || bgleList.size() == 0){
            throw new BGLEServiceException(NO_RECORDS_PROVIDED_MSG);
        }

        Map<String, Set<String>> collectionIdMap  = new Map<String, Set<String>>{
            GEEKLIST => new Set<String>(),
            COLLECTION => new Set<String>()
        };

        List<String> errorMessageList = new List<String>();

        //Get List of GeekList IDs or Collection Names from given BGLEs
        for(BG_Library_Entry__c bgle : bgleList){
            if(bgle.Source_Type__c == GEEKLIST){
                collectionIdMap.get(GEEKLIST).add(bgle.Source__c);
            } else if(bgle.Source_Type__c == COLLECTION){
                collectionIdMap.get(COLLECTION).add(bgle.Source__c);
            } else {
                errorMessageList.add(String.format(ERROR_RECORD_MISSING_SOURCE_ID, new List<String>{bgle.BoardGameName__c}));
            }
        }

        List<BGGCalloutService.CalloutResult> results = new List<BGGCalloutService.CalloutResult>();
        //For Each GeekList ID or Collection Name Found, Make Callout to BGG for Collection Data
        // and place wrapperMap results into Map for Processing.
        // WARNING: While this does make a callout in a loop, a check has been added to the 
        //  getIDsFromBoardGameGeek method to return an error message if the callout limit was reached
        for(String geekListId : collectionIdMap.get(GEEKLIST)){
            results.add(bggHttpService.getIDsFromBoardGameGeek(geekListId, true));
        }
        for(String collectionId : collectionIdMap.get(COLLECTION)){
            results.add(bggHttpService.getIDsFromBoardGameGeek(collectionId, false));
        }

        Map<String, BoardGameWrapper> wrapperMap = new Map<String, BoardGameWrapper>();

        //Parse Results and get error messages recieved and Wrapper Maps from results
        for(BGGCalloutService.CalloutResult result : results){
            if(result.resultMessage == null){
                wrapperMap.putAll(result.wrapperMap);
            } else if(result.unprocessedIDs.size() > 0) {
                errorMessageList.add(String.format(ERROR_TOO_MANY_CALLOUTS, new List<String>{result.resultMessage}));
            } else {
                errorMessageList.add(result.resultMessage);
            }
        }

        Integer totalUpdated = 0;
        //Loop Through bgle List again but update BG Library Entry Record with new information
        for(BG_Library_Entry__c bgle : bgleList){
            if(wrapperMap.containsKey(bgle.BGG_Id__c)){
                bgle.Comments__c = wrapperMap.get(bgle.BGG_Id__c).comment;
                bgle.BGG_Owner__c = wrapperMap.get(bgle.BGG_Id__c).ownerName;
                uow.registerDirty(bgle);
                totalUpdated++; //Increment Total Updated for Return Message
            }
        }

        //If No Updates were made because errors occured, throw error to show error messages
        if(totalUpdated == 0 && errorMessageList.size() > 0){
            throw new BGLEServiceException(String.join(errorMessageList, ' '));
        }else{
            //Otherwise Return Success Message and include Error messages, if any
            return String.format(SUCCESS_MSG, new List<String>{
                                                            totalUpdated.toString(),
                                                            String.join(errorMessageList, ' ')
                                                        });
        }
    }

    public List<BG_Library_Entry__c> updateRemovedBoardGamesFromBGLEs(fflib_SObjectUnitOfWork uow, String temp, Set<String> tempList) {
        return null;
    }

    public void deleteRemovedBoardGamesFromBGLEs(fflib_SObjectUnitOfWork uow, BoardGameServiceResults serviceResults, Map<String, BG_Library_Entry__c> currentBGLEsMap, Set<String> bggIdsFromAPI, Boolean perserveLogs){

        List<BG_Library_Entry__c> removedBGLEs = new List<BG_Library_Entry__c>();
        serviceResults.removedBGLEs = new List<BG_Library_Entry__c>();
        serviceResults.updatedBGLEs = serviceResults.updatedBGLEs != null ? serviceResults.updatedBGLEs : new List<BG_Library_Entry__c>();

        // For Each BGG ID in the Map for BGLEs, 
        for(String bggId : currentBGLEsMap.keySet()){
            // IF the Set of Strings from the API does NOT include the current Existing BGG ID
            if(!bggIdsFromAPI.contains(bggId)){
                removedBGLEs.add(currentBGLEsMap.get(bggId)); //Add BGLE to List to be Removed
            }
        }
        
        Map<Id, List<BG_Checkout_Log__c>> bgleLogsMap = new Map<Id, List<BG_Checkout_Log__c>>();
        // Get all related Checkout Logs for BGLEs
        for(BG_Checkout_Log__c log : logSelector.selectByLibraryEntryId(new Map<ID, BG_Library_Entry__c>(removedBGLEs).keySet())){
            List<BG_Checkout_Log__c> logs = bgleLogsMap.containsKey(log.BG_Library_Entry__c) 
                                                ? bgleLogsMap.get(log.BG_Library_Entry__c) 
                                                : new List<BG_Checkout_Log__c>(); 
            logs.add(log);
            bgleLogsMap.put(log.BG_Library_Entry__c, logs);
        }

        for(BG_Library_Entry__c bgle : removedBGLEs){
            // If BGLE has related Logs
            if(bgleLogsMap.containsKey(bgle.Id)){
                // IF Preserve Logs is True
                if(perserveLogs){                
                    // Add BGLE Change to Results
                    serviceResults.bgleChanges.put(bgle.Id, new Map<String, Map<Object, Object>>{'Number of Copies' => new Map<Object, Object>{bgle.Num_of_Copies__c => 0}});    
                    bgle.Num_of_Copies__c = 0; //Set Number of Copies for BGLE to 0
                    uow.registerDirty(bgle); // Update BGLE Record
                    serviceResults.updatedBGLEs.add(bgle);
                } else { // IF Preserve Logs is False
                    uow.registerDeleted(bgleLogsMap.get(bgle.Id)); // Delete Related Logs
                    uow.registerDeleted(bgle); // Delete BGLE
                    serviceResults.removedBGLEs.add(bgle);
                }
            } else { // BGLE Does NOT have Related Logs
                uow.registerDeleted(bgle); // Delete BGLE
                serviceResults.removedBGLEs.add(bgle);
            }       
            
        }
        
    }

    public void createNewBGLEs(fflib_SObjectUnitOfWork uow, BoardGameServiceResults serviceResults, Map<String, BoardGameWrapper> wrapperMap, Map<String, Board_Games__c> newBGGIds){
        serviceResults.newBGLEs = new List<BG_Library_Entry__c>();
        //build map of new Board Games from serviceResults
        Map<String, Board_Games__c> newGames = new Map<String, Board_Games__c>();
        for(Board_Games__c bg : serviceResults.newBoardGames){
            newGames.put(bg.BGG_ID__c, bg);
        }

        for (String bggId : newBGGIds.keySet()){
            // New BGLE can be for a New Board Game or For an Existing Board Game in 
            if(wrapperMap.containsKey(bggId)){
                BG_Library_Entry__c bgle = new BG_Library_Entry__c();
                BoardGameWrapper wrapper = wrapperMap.get(bggId);
                bgle.Comments__c = wrapper.comment;
                bgle.BGG_Owner__c = wrapper.ownerName;
                bgle.Event__c = serviceResults.eventId;
                bgle.Num_of_Copies__c = 1;
                bgle.Source__c = serviceResults.sourceName;
                bgle.Source_Type__c = serviceResults.sourceType;
                if(newBGGIds.get(bggId) == null){
                    uow.registerNew(bgle, BG_Library_Entry__c.Board_Game__c, newGames.get(bggId));
                } else {
                    bgle.Board_Game__c = newBGGIds.get(bggId).Id;
                    uow.registerNew(bgle);
                }
                serviceResults.newBGLEs.add(bgle);
            }
        }
    }

    public void updateBGLEs(fflib_SObjectUnitOfWork uow, BoardGameServiceResults serviceResults, Map<String, BoardGameWrapper> wrapperMap, Map<String, BG_Library_Entry__c> existingBGLEs){        
        //Initialize Values
        serviceResults.updatedBGLEs = new List<BG_Library_Entry__c>();
        serviceResults.bgleChanges = new Map<Id,Map<String,Map<Object,Object>>>();
        
        //Make Callout to get Board Game Details for Existing Board Games
        BGGCalloutService.CalloutResult detailsResult = bggHttpService.getBoardGameDetailFromBGGIds(existingBGLEs.keySet());
        
        //Get CSV List of Fields queired from Selector
        String queriedFieldList = bgleSelector.getFieldListString();

        for(String bggId : detailsResult.wrapperMap.keySet()){
            BoardGameWrapper wrapper = wrapperMap.get(bggId);
            BG_Library_Entry__c oldValue = existingBGLEs.get(bggId).clone(true, true, true, true);
            BG_Library_Entry__c newValue = existingBGLEs.get(bggId);
            newValue.Comments__c = wrapper.comment;
            newValue.BGG_Owner__c = wrapper.ownerName;
            newValue.Source__c = serviceResults.sourceName;
            newValue.Source_Type__c = serviceResults.sourceType;
            serviceResults.bgleChanges.put(newValue.Id, compareValues(oldValue, newValue, queriedFieldList));            
            uow.registerDirty(newValue);
            serviceResults.updatedBGLEs.add(newValue);
        }
    }

    /**
     * Compares all Field Values on the given Board Game Library Entry Objects
     * @param oldGame is the Old BGLE Values
     * @param newGame is the New BGLE Values
     * @param queriedFieldList is the String CSV list of the fields to compare
     * @return Nested Map with First Key is Field Name, Second Key is Old Value, Value is New Value. 
     */
    private Map<String, Map<Object, Object>> compareValues(BG_Library_Entry__c oldGame, BG_Library_Entry__c newGame, String queriedFieldList){
        //Initialize Change Map, if not already Initialized
        Map<String, Map<Object, Object>> changeMap = new Map<String, Map<Object, Object>>();
        
        //List of Changes
        Map<String, Map<Object, Object>> changes = new Map<String, Map<Object, Object>>();

        //Split Queried Field List into List
        for(String fieldName : queriedFieldList.split(',')){
            // Get Label of Field
            String fieldLabel = BG_Library_Entry__c.SObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();

            // Convert Object to String and set value to null if empty for comparison
            String oldValue = String.isBlank(String.valueOf(oldGame.get(fieldName))) ? null : String.valueOf(oldGame.get(fieldName));
            String newValue = String.isBlank(String.valueOf(newGame.get(fieldName))) ? null : String.valueOf(newGame.get(fieldName));

            // Check if Values are Numeric (Both have already been checked as not null)
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

    public Map<String, String> getSourcesByEvent(Id eventId){
        Map<String, String> rtv = new Map<String, String>();
        for(BG_Library_Entry__c bgle : bgleSelector.selectByEventIDs(new Set<Id>{eventId})){
            rtv.put(bgle.Source__c, bgle.Source_Type__c);
        }
        return rtv;
    }


    public class BGLEServiceException extends Exception {}
}