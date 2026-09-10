public without sharing class SetFavoriteBoardGameRatingAfterAction extends AbstractBaseDomainProcessAction {
    public override void runInProcess(){

        //Filter records for those where Is Favorite is changed
        List<Board_Game_Rating__c> records = (List<Board_Game_Rating__c>) this.getChanged('Is_Favorite__c');
        //If No Favorited Records provided, Do Nothing
        if(records.size() == 0){
            return;
        }

        BoardGameRatingSelector bgRatingSelector = (BoardGameRatingSelector) Application.Selector.newInstance(Board_Game_Rating__c.sObjectType);
        //Create Map where the Attendee ID will be the Key and the Rating Id will be the value
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
                throw new BGRActionException('Duplicate Favorite Found');
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

        this.uow.commitWork();
    }

    public class BGRActionException extends Exception {}
}