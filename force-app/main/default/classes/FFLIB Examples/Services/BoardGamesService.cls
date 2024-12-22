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
* @modified       2024-12-21
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class BoardGamesService extends BaseService implements IBoardGamesService {
    
    //Set Variables used throughout Service    
    private BGGCalloutService bggHttpService;
    private BoardGameSelector bgSelector;
    private BGLibraryEntrySelector bgleSelector;

    //Set Final Strings for Return Messages
    //Use Final Strings so that exact text can be used in the Test Class without worrying about text changes
    @TestVisible private final String SERVICE_NOT_ENABLED_MSG = 'This Service is Not Enabled. Please Contact a System Administrator to Enable';
    @TestVisible private final String SUCCESS_MSG = '{0} New Games Added. {1} Games Updated.';
    @TestVisible private final String UNPROCESSED_FOUND_MSG = '{0} of {1} Board Games Found and Processed. {2} New Games Added. {3} Games Updated.';
    @TestVisible private final String EVENT_ID_INVALID_MSG = 'Invalid Event ID';
    @TestVisible private final String COLLECTION_OR_ID_INVALID_MSG = 'Invalid Collection or Geek ID';

    //Initialize Service Class
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
        bggHttpService = (BGGCalloutService) Application.Service.newInstance(IBGGCalloutService.class);
        bgSelector = (BoardGameSelector) Application.Selector.newInstance(Board_Games__c.SObjectType);
        bgleSelector = (BGLibraryEntrySelector) Application.Selector.newInstance(BG_Library_Entry__c.sObjectType);
    }

    public String getBoardGameDetailsFromBGG(fflib_SObjectUnitOfWork uow,
                                            ID eventId, 
                                            String collectionNameOrGeekListId, 
                                            Boolean isGeekList, 
                                            Boolean updateExisiting){

            //If Service NOT enabled, Throw Error
            if(!this.serviceEnabled('getBoardGameDetailsFromBGG')){ //Check if this Service Method is Enabled from Parent
                throw new BGServiceException(SERVICE_NOT_ENABLED_MSG);
            }

            //Validate Inputs
            if(eventId == null || eventId.getSObjectType().getDescribe().getName() != 'Event__c'){
                throw new BGServiceException(EVENT_ID_INVALID_MSG);
            }

            if(collectionNameOrGeekListId == null){
                throw new BGServiceException(COLLECTION_OR_ID_INVALID_MSG);
            }

            //Call HttpService to Get IDs
            BGGCalloutService.CalloutResult result = bggHttpService.getIDsFromBoardGameGeek(collectionNameOrGeekListId, isGeekList);
            
            //If Result Message exists then an error occured
            //Return Result message back to User
            if(result.resultMessage != null){
                throw new BGServiceException(result.resultMessage);
            }

            //If No Message, keep going
            //Get all BGG IDs from the Map in the Result
            Set<String> bggIDs = result.wrapperMap.keySet();

            //Get All Exisiting Board Games Based on BGGIDs
            List<Board_Games__c> existingBoardGames = bgSelector.selectByBGGIDs(bggIDs);

            //If NOT Update Exisiting, Only get Board Game Details for NEW Board Games
            If(!updateExisiting){
                //So Remove exisiting Board Games from Wrapper Map
                for(Board_Games__c thisBG : existingBoardGames){
                    if(result.wrapperMap.containsKey(thisBG.BGG_ID__c)){
                        result.wrapperMap.remove(thisBG.BGG_ID__c);
                    }
                }
            }

            //Make Callout to get Board Game Details
            result = bggHttpService.getBoardGameDetailsFromBGG(result);

            //Once Again, If Result Message exists from an error
            // And NOT from unprocessed IDs
            // Return Result message back to User
            if(result.resultMessage != null 
                && result.unprocessedIDs.size() == 0){
                    throw new BGServiceException(result.resultMessage);
            }

            //Creating Seperate List for Updates to count number of updates
            List<Board_Games__c> bgToUpdate = new List<Board_Games__c>();

            //Get All Related Library Entries for Event
            Map<String, BG_Library_Entry__c> bglEntries = new Map<String, BG_Library_Entry__c>();
            //Load Map with all Related Board Game Library Entires for Event
            For(BG_Library_Entry__c entry : bgleSelector.selectByEventIDs(new Set<Id>{eventId})){
                bglEntries.put(entry.Board_Game__r.BGG_ID__c, entry);
            } 

            For(Board_Games__c thisBG : existingBoardGames){
                //If Match Found in wrapper Map AND Update Exisitng Records                    
                BGGCalloutService.BoardGameWrapper wrapper = result.wrapperMap.get(thisBG.BGG_ID__c);
                if(updateExisiting){
                    //Get Matching Board Game Record from Wrapper
                    Board_Games__c bg = wrapper.boardGame;
                    bg.Id = thisBG.Id; //Set ID to Existing BG ID
                    bg.Is_New__c = false; //Uncheck the Is New Flag
                    bgToUpdate.add(bg); //Add to Update List

                    //Get Matching Library Entry Record and Update Comments and Owner Name
                    if(bglEntries.containsKey(thisBG.BGG_ID__c)){
                        BG_Library_Entry__c bge = bglEntries.get(thisBG.BGG_ID__c);
                        bge.Comments__c = wrapper.comment;
                        bge.BGG_Owner__c = wrapper.ownerName;
                        uow.registerDirty(bge); //Register Board Game Library Entry for Update 
                    }
                } 
                //If NOT Update Exisiting,
                else {                
                    //Check if IS NEW is Checked, and set it to false if it is
                    if (thisBG.Is_New__c) {
                        thisBG.Is_New__c = false;
                        uow.registerDirty(thisBG); //Register Update without list, dont need to track this number of updates
                    }
                }
                
                //If Matching Library Entry NOT found for Record, Add New Library Entry for Event
                if(!bglEntries.containsKey(thisBG.BGG_ID__c)){
                    BG_Library_Entry__c bge = new BG_Library_Entry__c();
                    bge.Event__c = eventId;
                    bge.Comments__c = wrapper?.comment;
                    bge.BGG_Owner__c = wrapper?.ownerName;
                    bge.Board_Game__c = thisBG.Id;
                    uow.registerNew(bge);
                }

                result.wrapperMap.remove(thisBG.BGG_ID__c); //Remove Updated Record From Wrapper
            }   
            
            uow.registerDirty(bgToUpdate); //Register Games for Update  

            //Any Remaining Board Games in Wrapper Map are new Board Games
            For(BGGCalloutService.BoardGameWrapper wrapper : result.wrapperMap.values()){
                uow.registerNew(wrapper.boardGame);
                //Create Board Game Library Entry for New Board Game
                BG_Library_Entry__c bge = new BG_Library_Entry__c();
                bge.Event__c = eventId;
                bge.Comments__c = wrapper.comment;
                bge.BGG_Owner__c = wrapper.ownerName;
                //Register new Board Game Library Entry with Relationship to new Board Game
                uow.registerNew(bge, BG_Library_Entry__c.Board_Game__c, wrapper.boardGame); 
            }

            //Using String Format to use Final Strings with Alterations based on result numbers
            if(result.unprocessedIDs.size() > 0){
                Integer totalProcessed = bggIDs.size() - result.unprocessedIDs.size();
                return String.format(UNPROCESSED_FOUND_MSG, 
                                        new Integer[]{totalProcessed, bggIDs.size(), result.wrapperMap.size(), bgToUpdate.size()} );
            }else{
                return String.format(SUCCESS_MSG, 
                                        new Integer[]{result.wrapperMap.size(), bgToUpdate.size()} );
            }
    }

    public class BGServiceException extends Exception {}

}