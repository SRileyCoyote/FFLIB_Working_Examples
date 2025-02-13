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
        bggHttpService = (BGGCalloutService) BGGCalloutService.newInstance();
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

        Map<String, BGGCalloutService.BoardGameWrapper> wrapperMap = new Map<String, BGGCalloutService.BoardGameWrapper>();

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

    public class BGLEServiceException extends Exception {}
}