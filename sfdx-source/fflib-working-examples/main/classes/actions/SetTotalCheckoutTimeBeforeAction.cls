public without sharing class SetTotalCheckoutTimeBeforeAction extends AbstractBaseDomainProcessAction {
    public override void runInProcess(){

        List<BG_Checkout_Log__c> filteredRecords = (List<BG_Checkout_Log__c>) getChanged('Check_In_Time__c');

        for (BG_Checkout_Log__c record : filteredRecords){
            //If Either Check Out Time or Check In Time are Have a value,
            // and Check In Time is LATER than Check Out Time,
            if (validateTimeOutValue(record) 
                && record.Check_In_Time__c != null ){
                    //Set Total_Check_Out_Time_Value__c field to equal the formula field Value
                    record.Total_Check_Out_Time_Value__c = record.Total_Check_Out_Time_Formula__c;
                }
        }
    }

    private Boolean validateTimeOutValue(BG_Checkout_Log__c record){
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
}