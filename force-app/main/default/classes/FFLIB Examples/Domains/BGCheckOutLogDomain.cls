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
public class BGCheckOutLogDomain extends BaseDomain implements IBGCheckOutLogDomain {
    
    public static IBGCheckOutLogDomain newInstance(List<BG_Checkout_Log__c> recordList){
        return (BGCheckOutLogDomain) Application.Domain.newInstance(recordList);
    }

    public BGCheckOutLogDomain(List<BG_Checkout_Log__c> sObjectList) {
        super(sObjectList, BG_Checkout_Log__c.SObjectType);
    }

    public List<BG_Checkout_Log__c> getBoardGameCheckOutLogs(){
        return (List<BG_Checkout_Log__c>) getRecords();
    }

    public Boolean validateTimeOutValue(BG_Checkout_Log__c record){
        //If Check Out is Null, Return false
        if(record.Check_Out_Time__c == null){
            return false;
        }
        //If Check In is Not Null and is Sooner than the Check Out Time, Return False
        if(record.Check_In_Time__c != null
            && record.Check_Out_Time__c > record.Check_In_Time__c){
            return false;
        }
        //If Check Out Time is Not Null and Check In Time is Null, return True
        //If Check Out Time is Not Null and Check In Time is LATER than Check Out Time, return True
        return true;
    }

    public List<BG_Checkout_Log__c> getCompletedCheckOutLogs(List<BG_Checkout_Log__c> records){
        List<BG_Checkout_Log__c> results = new List<BG_Checkout_Log__c>();
        for(BG_Checkout_Log__c record : records){
            //If Neither Check Out Time nor Check In Time are Not Null
            // and Check In Time is LATER than Check Out Time,
            // Add Record to Returned Results 
            if(validateTimeOutValue(record) && record.Check_In_Time__c != null){
                results.add(record);
            }
        }
        return results;
    }

    public class Constructor implements fflib_IDomainConstructor {
        public fflib_SObjects construct(List<Object> objectList) {
            return new BGCheckOutLogDomain((List<SObject>) objectList);
        }
    }

}