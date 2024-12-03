public interface IEventSelector extends fflib_ISObjectSelector {
    List<Event__c> selectById(Set<Id> recordIds);
    List<Event__c> selectAll();
}