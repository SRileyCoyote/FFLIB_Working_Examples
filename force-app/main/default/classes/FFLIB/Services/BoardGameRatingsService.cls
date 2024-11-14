public without sharing class BoardGameRatingsService implements IBoardGameRatingsService {
    
    //Set Variables used throughout Service
    @TestVisible 
    private Map<String, Services_Config__mdt> serviceConfigMap = new Map<String, Services_Config__mdt>(); 
    private BoardGameRatingSelector bgRatingSelector;

    //Initialize Service Class
    public BoardGameRatingsService(){
        this(Services_Config__mdt.getAll().values());
    }

    @TestVisible
    //Private Constructor for Testing to provide own Service Config
    private BoardGameRatingsService(List<Services_Config__mdt> configList){
        //Initialize Selectors
        bgRatingSelector = (BoardGameRatingSelector) BoardGameRatingSelector.newInstance();
        
        //Get All Service Config Records without SOQL Call, Filter By Domain
        for(Services_Config__mdt config : configList){
            if(config.Domain_Config__r.DeveloperName == 'BoardGameRatingsDomain'){
                serviceConfigMap.put(config.DeveloperName, config);
            }
        }
    }

    public void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> newRecords, Map<Id,SObject> existingRecords){
        
        //If Service Config for Method Found AND Service Method is Enabled
        if(serviceConfigMap.containsKey('setNewFavorite') 
            && serviceConfigMap.get('setNewFavorite').Service_Enabled__c){

                //Creat Map where the Attendee ID will be the Key and the Rating Id will be the value
                Map<Id, Id> favRatingMap = new Map<Id, Id>();

                //We must treat the records being passed in as if it was done in bulk
                //For Each Rating is Records,
                for(Board_Game_Rating__c thisRating : newRecords){
                    //If IsFavorite Changed To Checked on Record
                    If(!((Board_Game_Rating__c) existingRecords.get(thisRating.Id)).is_Favorite__c
                        && thisRating.is_Favorite__c){
                        
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
                }

                //If Fav Ratings were Found
                if(favRatingMap != null){
                    // Get All Favorite Ratings for All Attendees in update that marked the record as Favorite, 
                    // Excluding the Favorited Records
                    for(Board_Game_Rating__c thisRating : bgRatingSelector.selectFavoriteRatingByAttendeeIdExcludingRecordID(
                                                                            favRatingMap.keySet(), 
                                                                            new Set<Id>(favRatingMap.values())
                                                                        )){
                        thisRating.is_Favorite__c = false; //Set Each Rating As False
                        uow.registerDirty(thisRating); //Register Rating to be Updated, No DML Performed yet
                    }
                }
        }
    }

    public class BGRServiceException extends Exception {}
}