/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Service Class for the Board Game Rating Object.
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
public without sharing class BoardGameRatingsService extends BaseService implements IBoardGameRatingsService {
    
    //Set Variables, Domains, and Selectors used throughout Service
    private BoardGameRatingsDomain domain;
    private BoardGameRatingSelector bgRatingSelector;

    //Initialize Service Class
    public BoardGameRatingsService(){
        super('BoardGameRatings'); //Calls the Constructor from the Parent Class
    }

    @TestVisible
    //Private Constructor for Testing to provide own Service Config
    private BoardGameRatingsService(List<Services_Config__mdt> configList){
        super(configList, 'BoardGameRatings');  // Calls the protected constructor of BaseService with custom config list
    }

    //Abstract Method from Parent that Must be implemented
    protected override void initialize(){
        //Initialize Selectors through Application Layer 
        //so they can be Mocked and Stubbed from the Test Class
        bgRatingSelector = (BoardGameRatingSelector) Application.Selector.newInstance(Board_Game_Rating__c.sObjectType);
    }
    public void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> records){
        setNewFavorite(uow, records, null);
    }

    public void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> records, Map<ID, SObject> existingRecords){
        
        domain = (BoardGameRatingsDomain) Application.Domain.newInstance(records);
        domain.setExistingRecords(existingRecords);

        //If Not Enabled, Do Nothing
        if(!this.serviceEnabled('setNewFavorite')){ //Check if this Service Method is Enabled from Parent
            return;
        }
        records = domain.getChanged('Is_Favorite__c');
        //If No Favorited Records provided, Do Nothing
        if(records.size() == 0){
            return;
        }

        //Creat Map where the Attendee ID will be the Key and the Rating Id will be the value
        Map<Id, Id> favRatingMap = new Map<Id, Id>();

        //We must treat the records being passed in as if it was done in bulk
        //For Each Rating is Records,
        for(Board_Game_Rating__c thisRating : records){

            //Check if Attendee Fav not yet added
            If(!favRatingMap.containsKey(thisRating.Event_Attendee__c)){
                //Place Fav Record ID into Map using the Attendee ID as key
                favRatingMap.put(thisRating.Event_Attendee__c, thisRating.Id);
            }
            else {
                //Throw Exception for Duplicate Favorites in the same update
                throw new BGRServiceException('Duplicate Favorite Found');
            }   
        }

        // Get All Favorite Ratings for All Attendees in update that marked the record as Favorite, 
        // Excluding the Favorited Records
        for(Board_Game_Rating__c thisRating : bgRatingSelector.selectFavoriteRatingByAttendeeIdExcludingRecordID(
                                                                favRatingMap.keySet(), //Attendee IDs
                                                                new Set<Id>(favRatingMap.values()) //Exclude these Ratings IDs
                                                            )){
            thisRating.is_Favorite__c = false; //Set Each Rating As False
            uow.registerDirty(thisRating); //Register Rating to be Updated, No DML Performed yet
        }
    }

    public class BGRServiceException extends Exception {}
}