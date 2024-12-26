/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Service Class for the BoardGameGeek API Callout.
*
* This Service Class houses all of the logic for calling out to the API for the BoardGameGeek 
* website as well as how to handle the incoming XML Results. Methods Return an Inner Wrapper Class
* to hold all of the multiple data points returned by the API Callout. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2024-12-26
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BGGCalloutService implements IBGGCalloutService {

    //Set Final Strings for Return Messages
    //Use Final Strings so that exact text can be used in the Test Class without worrying about text changes
    @TestVisible private final String ERROR_COLLECTION_MSG = 'An Error Occured Getting Collection: ';
    @TestVisible private final String ERROR_GEEKLIST_MSG = 'An Error Occured Getting GeekList: ';
    @TestVisible private final String ERROR_DETAILS_MSG = 'An Error Occured Getting Details: ';
    @TestVisible private final String NO_IDS_PROVIDED_MSG = 'No New Games Found';
    @TestVisible private final String ERROR_TOO_MANY_CALLOUTS = 'Too Many Games. Details for {0} out of {1} returned';

    //Used to override Values during testing
    @TestVisible private Integer maxCalloutLimit = System.Limits.getLimitCallouts();
    @TestVisible private Integer totalCallouts = System.Limits.getCallouts(); //Get All Callouts already made

    public BGGCalloutService(){

    }

    public CalloutResult getIDsFromBoardGameGeek(String nameOrId, Boolean isGeekList){
        if(isGeekList){
            return getIDsFromGeekList(nameOrId);
        }
        else{
            return getIDsFromCollection(nameOrId);
        }
    }

    private CalloutResult getIDsFromCollection(String collectionName){
        CalloutResult rtv = new CalloutResult();
        
        String endpoint = 'https://boardgamegeek.com/xmlapi2/collection?username='+collectionName+'&own=1&excludesubtype=boardgameexpansion';
        try{
            For(Dom.XmlNode item : makeCallout(endpoint)){            
                BoardGameWrapper result = new BoardGameWrapper();
                result.ownerName = collectionName;
                String bggId = item.getAttribute('objectid', null);
                result.comment = item.getChildElement('comment', null)?.getText();
                result.boardGame = new Board_Games__c();
                result.boardGame.BGG_ID__c = bggId;
                rtv.wrapperMap.put(bggId, result);
            }
        } catch (Exception ex){
            throw new HttpServiceException( ERROR_COLLECTION_MSG + ex.getMessage());
        }
        return rtv;
    }

    private CalloutResult getIDsFromGeekList(String geekListId){       
        CalloutResult rtv = new CalloutResult();
        
        String endpoint = 'https://boardgamegeek.com/xmlapi/geeklist/'+geekListId;

        try{
            For(Dom.XmlNode item : makeCallout(endpoint)){
                BoardGameWrapper result = new BoardGameWrapper();
                
                if(item.getName() == 'item'){
                    String bggId = item.getAttribute('objectid', null);
                    result.boardGame = new Board_Games__c();
                    result.boardGame.BGG_ID__c = bggId;
                    result.comment = item.getChildElement('body', null)?.getText();
                    result.ownerName = item.getAttribute('username', null);
                    rtv.wrapperMap.put(bggId, result);
                }
            }
        } catch (Exception ex){
            throw new HttpServiceException(ERROR_GEEKLIST_MSG + ex.getMessage());
        }
        return rtv;
    }

    public CalloutResult getBoardGameDetailFromBGGIds(Map<Id, String> recordIdToBGGIdMap){
        
        //Initialize new CalloutResult to Return with new Wrapper Map
        CalloutResult result = new CalloutResult();
        result.wrapperMap = new Map<String, BoardGameWrapper>();

        //For Each RecordId and BGG ID key/value pair
        for(ID recordId : recordIdToBGGIdMap.keySet()){
            BoardGameWrapper wrapper = new BoardGameWrapper(); //Initialize New Wrapper
            wrapper.boardGame = new Board_Games__c(     //Add Values to Board Game in Wrapper
                                                        ID = recordId, 
                                                        BGG_ID__c = recordIdToBGGIdMap.get(recordId)
                                                    );
            //Put Wrapper into Result Wrapper Map
            result.wrapperMap.put(wrapper.boardGame.BGG_ID__c, wrapper);
        }
        //Make Callout and Get Board Game Details and return the result
        return getBoardGameDetailsFromBGG(result);
    }

    public CalloutResult getBoardGameDetailsFromBGG(CalloutResult result){

        if(result.wrapperMap.size() > 0){ //If no BGG Ids provided, do nothing

            String endpoint = 'https://boardgamegeek.com/xmlapi2/thing?stats=1&id=';

            //BGG Thing API has a limit of 20 Games per Callout
            //Break Set into batches of 19
            List<Set<String>> bggIdBatches = createBatches(result.wrapperMap.keySet(), 19);
            List<Dom.XmlNode> results = new List<Dom.XmlNode>();
            try{
                //Loop Through Batches of Ids 
                for(Set<String> batch : bggIdBatches){
                    //If Callout limit is not reached
                    if(totalCallouts < maxCalloutLimit){
                        String idList = String.join(new List<String>(batch), ','); //Convert Ids into CSV List
                        results.addAll(makeCallout(endpoint + idList)); //Get BG Details for batch and add to results
                    }else{ //If Callout limit IS reached
                        result.unprocessedIDs.addAll(batch); //All remaining IDs to unprocessed BGG IDs List
                    }
                }
                if(result.unprocessedIDs.size() > 0){
                    Integer totalProcessed = result.wrapperMap.size() - result.unprocessedIDs.size();
                    // Return Message as opposed to Throw Error, as we dont want to stop processing the records we already retrieved
                    result.resultMessage = String.format(ERROR_TOO_MANY_CALLOUTS, 
                                                        new Integer[]{totalProcessed, result.wrapperMap.size()});
                }
            } catch (Exception ex){
                throw new HttpServiceException(ERROR_DETAILS_MSG + ex.getMessage());
            }

            //For all results returned, parse XML into Board Game Data
            For(Dom.XmlNode item : results){
                String bggID = item.getAttribute('id', null);
                //Get Wrapper from Map, if Value exists or create new wrapper
                BoardGameWrapper wrapper = result.wrapperMap.containsKey(bggID) 
                                            ? result.wrapperMap.get(bggID) 
                                            : new BoardGameWrapper();
                //Parse XML for Board Game Details
                wrapper = getDetailsFromXML(item, wrapper);
                //Put Wrapper back into Map to be returned
                result.wrapperMap.put(bggID, wrapper);
            }
        }
        else{ //If Map of BoardGameWrappers is empty, return error message
            //Return Message as opposed to throw error as this is a likely outcome
            //and an acceptable result, not neccessarily an error
            result.resultMessage = NO_IDS_PROVIDED_MSG;
        }
        return result;
    }

    private BoardGameWrapper getDetailsFromXML(Dom.XmlNode xml, BoardGameWrapper wrapper){
        wrapper.boardGame.BGG_ID__c = xml.getAttribute('id', null);

        List<String> catList = new List<String>();
        List<String> mechList = new List<String>();
        //Loop through ALL Child Elements
        for(Dom.XmlNode item : xml.getChildElements()){
            //Switch on Element Name and Assign Values
            switch on item.getName(){
                when 'name'{
                    if(item.getAttribute('type', null) == 'primary'){
                        wrapper.boardGame.Name = item.getAttribute('value', null);
                    }
                }
                when 'statistics'{
                    wrapper.boardGame.Avg_Rating__c = Decimal.valueOf(item.getChildElement('ratings', null)
                                                            ?.getChildElement('average', null)
                                                            ?.getAttribute('value', null));
                    wrapper.boardGame.Avg_Weight__c = Decimal.valueOf(item.getChildElement('ratings', null)
                                                            ?.getChildElement('averageweight', null)
                                                            ?.getAttribute('value', null));
                }
                when 'description'{
                    wrapper.boardGame.Description__c = item.getText();
                }
                when 'image'{
                    wrapper.boardGame.Image_URL__c = item.getText();
                }
                when 'thumbnail'{
                    wrapper.boardGame.Thumbnail_URL__c = item.getText();
                }
                when 'maxplayers'{
                    wrapper.boardGame.Max_Players__c = Integer.valueOf(item.getAttribute('value', null));
                }
                when 'minplayers'{
                    wrapper.boardGame.Min_Players__c = Integer.valueOf(item.getAttribute('value', null));
                }
                when 'minage'{
                    wrapper.boardGame.Min_Age__c = Integer.valueOf(item.getAttribute('value', null));
                }
                when 'playingtime'{
                    wrapper.boardGame.Playing_Time__c = Integer.valueOf(item.getAttribute('value', null));
                }
                when 'yearpublished'{
                    wrapper.boardGame.Year_Published__c = item.getAttribute('value', null);
                }
                when 'link'{
                    switch on item.getAttribute('type', null) {
                        when 'boardgamecategory' {
                            catList.add(item.getAttribute('value', null));
                        }
                        when 'boardgamepublisher' {
                            //Get only the first Publisher Name
                            if(wrapper.boardGame.Publisher__c == null){
                                wrapper.boardGame.Publisher__c = item.getAttribute('value', null);
                            }
                        }
                        when 'boardgamemechanic'{
                            mechList.add(item.getAttribute('value', null));
                        }
                    }
                }
            }
        }
        //Convert Lists into CSV Strings
        wrapper.boardGame.Categories__c = String.join(catList, ', ');
        wrapper.boardGame.Mechanics__c = String.join(mechList, ', ');
        wrapper.boardGame.Is_New__c = true; //Set this as Default on Imports
        return wrapper; //Return Given Board Game Wrapper
    }

    private List<Set<String>> createBatches(Set<String> stringSet, integer batchSizeLimit){
        //Set Return Value
        List<Set<String>> rtv = new List<Set<String>>();
        Set<String> batch = new Set<String>();

        //for each item in set
        For(String item : stringSet){
            //if the Batch is over the Batch Size Limit
            if(batch.size() > batchSizeLimit){
                rtv.add(batch); //Add Batch to Return Value
                batch = new Set<String>(); //Reset Batch
            }
            batch.add(item); //Add Current Item to Batch
        }
        rtv.add(batch); //Add Remaining Items

        return rtv;
    }

    private List<Dom.XmlNode> makeCallout(string endpoint){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        totalCallouts++;
        If(response.getStatusCode()==200){
            return response.getBodyDocument().getRootElement().getChildElements();
        }
        else {
            throw new HttpServiceException(response.getStatusCode() +': '+ response.getBody());
        }
    }

    public class CalloutResult{
        public Map<String, BoardGameWrapper> wrapperMap = new Map<String, BoardGameWrapper>();
        public Set<String> unprocessedIDs = new Set<String>();
        public String resultMessage;
    }

    public class BoardGameWrapper{
        public Board_Games__c boardGame = new Board_Games__c();
        public string ownerName {get;set;}
        public string comment {get;set;}
    }

    public class HttpServiceException extends Exception {}
}