@isTest
//Adding IsTest Annotation to this class indicates it is only for Testing so does not require code coverage
public class TestUtil {

    //A Test Util Class should be used for Data Setup across all tests so that 
    //  if and when new required fields or validation rules are added, only this class should need to be updated.
    //  Insert of the returned record should be done in the test itself so that any adjustments to the record needed
    //  can be done before insert 

    public static Board_Game_Rating__c createBoardGameRating(){
        Board_Games__c bg = createBoardGame();
        insert bg;

        Event_Attendee__c ea = createEventAttendee();
        insert ea;

        Board_Game_Rating__c record = new Board_Game_Rating__c();
        record.Board_Game__c = bg.Id;
        record.Event_Attendee__c = ea.Id;
        return record;
    }

    public static BG_Library_Entry__c createBoardGameLibraryEntry(){
        Board_Games__c bg = createBoardGame();
        insert bg;
        Event__c e = createEvent();
        insert e;
        BG_Library_Entry__c record = new BG_Library_Entry__c();
        record.Board_Game__c = bg.Id;
        record.Event__c = e.id;
        return record;
    }

    public static Board_Games__c createBoardGame(){
        Board_Games__c record = new Board_Games__c();
        return record;
    }

    public static Event_Attendee__c createEventAttendee(){
        Event__c e = createEvent();
        insert e;
        Event_Attendee__c record = new Event_Attendee__c();
        record.Event__c = e.Id;
        record.Attendee_Name__c = 'Test Attendee';
        record.Attendee_Email__c = 'TestAttendee@here.com';
        return record;
    }

    public static Event__c createEvent(){
        Event__c record = new Event__c();
        record.Start_Date__c = System.today();
        record.End_Date__c = System.today();
        return record;
    }
}