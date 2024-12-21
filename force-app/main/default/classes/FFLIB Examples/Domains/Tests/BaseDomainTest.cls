/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Base Domain Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-21
* @modified       2024-12-21
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@IsTest
public class BaseDomainTest {
    
    //Test Plan
    // Call IsChanged with Existing Records Not Set and No Name Value Set on Record
    // Call IsChanged with One Existing Record and No Name Value Set on Record
    // Call IsChanged with One Existing Record and Name Value Changed From Null on Record
    // Call IsChanged with One Existing Record and Name Value Changed From Different Value on Record
    // Call IsChanged with No Existing Records and Name Value Changed
    // Call GetChanged with No Changed Records
    // Call GetChanged with 1 Changed Record

    // Call IsChanged with Existing Records Not Set and No Name Value Set on Record
    @IsTest
    public static void givenExistingRecordsNotSetAndNameNotSet_WhenIsChangedCalledOnName_ThenReturnFalse(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c record = new Board_Games__c();

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{record});

        Test.startTest();
        Boolean result = domain.isChanged('Name', record);
        Test.stopTest();

        Assert.isFalse(result, 'Result Returned True');
    }

    // Call IsChanged with One Existing Record and No Name Value Set on Record
    @IsTest
    public static void givenOneExistingRecordAndNameNotSet_WhenIsChangedCalledOnName_ThenReturnFalse(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c record = new Board_Games__c(Id = fflib_IDGenerator.generate(Board_Games__c.SObjectType));

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{record});
        domain.setExistingRecords(new Map<ID, SObject>{record.Id => record});

        Test.startTest();
        Boolean result = domain.isChanged('Name', record);
        Test.stopTest();

        Assert.isFalse(result, 'Result Returned True');
    }

    // Call IsChanged with One Existing Record and Name Value Changed From Null on Record
    @IsTest
    public static void givenOneExistingRecordAndNameChangedFromNull_WhenIsChangedCalledOnName_ThenReturnTrue(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c newRecord = new Board_Games__c(
                            Id = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                            Name = 'New Value');
        Board_Games__c oldRecord = new Board_Games__c();

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{newRecord});
        domain.setExistingRecords(new Map<ID, SObject>{newRecord.Id => oldRecord});

        Test.startTest();
        Boolean result = domain.isChanged('Name', newRecord);
        Test.stopTest();

        Assert.isTrue(result, 'Result Returned False');
    }

    // Call IsChanged with One Existing Record and Name Value Changed From Different Value on Record
    @IsTest
    public static void givenOneExistingRecordAndNameChangedFromValue_WhenIsChangedCalledOnName_ThenReturnTrue(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c newRecord = new Board_Games__c(
                            Id = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                            Name = 'New Value');
        Board_Games__c oldRecord = new Board_Games__c(
                            Name = 'Old Value');

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{newRecord});
        domain.setExistingRecords(new Map<ID, SObject>{newRecord.Id => oldRecord});

        Test.startTest();
        Boolean result = domain.isChanged('Name', newRecord);
        Test.stopTest();

        Assert.isTrue(result, 'Result Returned False');
    }

    // Call IsChanged with No Existing Records and Name Value Changed
    @IsTest
    public static void givenNoExistingRecordAndNameChanged_WhenIsChangedCalledOnName_ThenReturnTrue(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c newRecord = new Board_Games__c(
                            Id = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                            Name = 'New Value');

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{newRecord});

        Test.startTest();
        Boolean result = domain.isChanged('Name', newRecord);
        Test.stopTest();

        Assert.isTrue(result, 'Result Returned False');
    }

    // Call GetChanged with No Changed Records
    @IsTest
    public static void givenOneExistingRecordAndNameNotChangedFromValue_WhenGetChangedCalledOnName_ThenReturnEmptyList(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c newRecord = new Board_Games__c(
                            Id = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                            Name = 'Value');
        Board_Games__c oldRecord = new Board_Games__c(
                            Name = 'Value');

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{newRecord});
        domain.setExistingRecords(new Map<ID, SObject>{newRecord.Id => oldRecord});

        Test.startTest();
        List<SObject> result = domain.getChanged('Name');
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Result Was Not Empty');
    }

    // Call GetChanged with 1 Changed Record
    @IsTest
    public static void givenOneExistingRecordAndNameChangedFromValue_WhenGetChangedCalledOnName_ThenReturnRecord(){

        //Setup Test Data
        // Using Board_Games__c as the example SObject since SObjects cannot be set 
        Board_Games__c newRecord = new Board_Games__c(
                            Id = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                            Name = 'New Value');
        Board_Games__c oldRecord = new Board_Games__c(
                            Name = 'Old Value');

        //Initialize Domain with Test Data
        BaseDomain domain = new BaseDomain(new List<SObject>{newRecord});
        domain.setExistingRecords(new Map<ID, SObject>{newRecord.Id => oldRecord});

        Test.startTest();
        List<SObject> result = domain.getChanged('Name');
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Result Was Empty');
    }

}