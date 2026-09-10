public interface IEventSelector extends IApplicationSObjectSelector {
    List<Event__c> selectById(Set<Id> recordIds);
    List<Event__c> selectAll();
}