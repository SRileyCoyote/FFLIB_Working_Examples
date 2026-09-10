public inherited sharing abstract class AbstractBaseDomainProcessAction extends DomainProcessAbstractAction implements IDomainProcessActionWithExistingRecs {
    private Map<Id, SObject> existingRecords = new Map<Id, SObject>();

    public IDomainProcessAction setExistingRecords(Map<Id, SObject> existingRecords){
        if(existingRecords != null && !existingRecords.isEmpty()){
            this.existingRecords = existingRecords;
        }
        return this;
    }

    public Map<Id, SObject> getExisitingRecords(){
        return existingRecords;
    }

    public List<SObject> getChanged(String fieldName){
        List<SObject> results = new List<SObject>();
        for(SObject record : this.records){
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