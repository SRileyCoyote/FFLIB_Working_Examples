public interface IEventAttendeeSelector extends fflib_ISObjectSelector {
    List<Event_Attendee__c> selectById(Set<Id> recordIds);
    List<Event_Attendee__c> selectByEventIDs(Set<Id> eventIds);
}