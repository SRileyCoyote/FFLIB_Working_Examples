public interface IEventAttendeeSelector extends IApplicationSObjectSelector {
    List<Event_Attendee__c> selectById(Set<Id> recordIds);
    List<Event_Attendee__c> selectByEventIDs(Set<Id> eventIds);
}