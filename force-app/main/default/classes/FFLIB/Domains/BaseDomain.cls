/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Base Domain Class is a Virtual Class all other Domain Classes will Extend.
*
* Domain Classes are like Service Classes in that they are where logic is performed however the 
* logic performed in the Domain Class is specific to sets of records for that SObject type. This
* Base Class houses all of the common logic and methods that can be used across all other Domain 
* Classes
*
* Base Domain Class extends from the fflib_SObjects Class and Implements its own Interface which 
* in turn also extends the fflib_ISObjects Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-21
* @modified       2024-12-21
* @systemLayer    Domain
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public virtual class BaseDomain extends fflib_SObjects implements IBaseDomain {
    
    private Map<Id,SObject> existingRecords;

    public BaseDomain(List<SObject> records) {
        super(records, records[0].getSObjectType());
    }

    public void setExistingRecords(Map<ID, SObject> existingRecords){
        this.existingRecords = existingRecords;
    }

    public List<SObject> getChanged(String fieldName){
        List<SObject> results = new List<SObject>();
        for(SObject record : super.getRecords()){
            if(isChanged(fieldName, record)){
                results.add(record);
            }
        }
        return results;
    }

    public Boolean isChanged(String fieldName, SObject record){
        if(existingRecords != null){
            return (record.get(fieldName) != existingRecords.get(record.Id).get(fieldName));
        }
        else{
            return (record.get(fieldName) != null);
        }
    }
}