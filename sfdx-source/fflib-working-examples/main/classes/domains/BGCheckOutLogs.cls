/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Domain Class for the Board Game Check Out Log Object.
*
* Domain Classes are like Service Classes in that they are where logic is performed however the 
* logic performed in the Domain Class is specific to sets of records of this Object type. While 
* this Domain currenlty only utilizes the common logic performed in the Base Domain class it extends
* any future methods for logic specific to this SObject would be contained here such as Custom 
* Validation on records given to the Domain or furhter filtering of the record list.   
*
* Domain Classes extend from the BaseDomain Class which in turn extends the fflib_SObjects Class
* and implements its own Interface which also extends the BaseDomain Interface which is vital to 
* being able to Mock and Stub the Domain Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-07
* @modified       2025-01-07
* @systemLayer    Domain
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BGCheckOutLogs extends ApplicationSObjectDomain implements IBGCheckOutLogs {
    
    public static IBGCheckOutLogs newInstance(List<BG_Checkout_Log__c> recordList){
        return (IBGCheckOutLogs) Application.Domain.newInstance(recordList);
    }

    public BGCheckOutLogs(List<BG_Checkout_Log__c> sObjectList) {
        super(sObjectList);
    }

    public List<BG_Checkout_Log__c> getBGCheckOutLogs(){
        return (List<BG_Checkout_Log__c>) getRecords();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BGCheckOutLogs(sObjectList);
        }
    }

}