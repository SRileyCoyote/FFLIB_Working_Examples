public without sharing class BoardGameRatingsService implements IBoardGameRatingsService {
    
    //Set Objects used throughout Domain
    private BoardGameRatingSelector bgRatingSelector;
    private Map<String, Services_Config__mdt> serviceConfigMap = new Map<String, Services_Config__mdt>(); 

    //Initialize Service Class
    public BoardGameRatingsService(){
        //Initialize Selector from Application Layer
        bgRatingSelector = (BoardGameRatingSelector) Application.Selector.newInstance(Board_Game_Rating__c.sObjectType);
        
        //Get All Service Config Records without SOQL Call, Filter By Domain
        for(Services_Config__mdt config : Services_Config__mdt.getAll().values()){
            if(config.Domain_Config__c == 'BoardGameRatingDomain'){
                serviceConfigMap.put(config.DeveloperName, config);
            }
        }
    }

    public void setNewFavorite(fflib_SObjectUnitOfWork uow, List<Board_Game_Rating__c> records){
        
        //If Service Config for Method Found AND Service Method is Enabled
        if(serviceConfigMap.containsKey('setNewFavorite') 
            && serviceConfigMap.get('setNewFavorite').Service_Enabled__c
            && !System.Test.isRunningTest()){

                Board_Game_Rating__c favRating;

                //For Each Rating is Records,
                for(Board_Game_Rating__c thisRating : records){
                    If(thisRating.is_Favorite__c){//Get First Record where Favorite is Checked
                        favRating = thisRating; //Set Rating as Favorite
                        break; //Exit Loop
                    }
                }

                //If Fav Rating was Found
                if(favRating != null){
                    //Get All Ratings From Running User, Excluding Favorite Record
                    for(Board_Game_Rating__c thisRating : bgRatingSelector.selectFavoriteRatingByUserIdExcludingRecordID(UserInfo.getUserId(), favRating.Id)){
                        thisRating.is_Favorite__c = false; //Set Each Rating As False
                        uow.registerDirty(thisRating); //Register Rating to be Updated
                    }
                }
        }
}
}