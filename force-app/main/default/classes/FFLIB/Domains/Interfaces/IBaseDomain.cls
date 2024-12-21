public interface IBaseDomain extends fflib_ISObjects{
    //Interface is needed so that it extends the fflib_ISObjects interface which is needed for Mocking the Domain
    //Any Additional Classes add to the Base Domain should go here
    void setExistingRecords(Map<ID, SObject> existingRecords);
    List<SObject> getChanged(String fieldName);
    Boolean isChanged(String fieldName, SObject record);
}