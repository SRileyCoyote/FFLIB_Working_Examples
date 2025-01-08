/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for the Board Game Check Out Log Domain Class
*
* A Test Plan is required to cover all possible scenarios for the inputs or variations to 
* variables that might occur. Up to and Including: Positive, Negative, and Bulk Testing.
* If done correctly, minimal manual testing should be needed in the Application. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2025-01-08
* @modified       2025-01-08
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@IsTest
public class BGCheckOutLogDomainTest {
    
    //Test Plan
    // Call newInstance
    // Call Constructor
    // Call validateTimeOutValue when Time Out is Null
    // Call validateTimeOutValue when Time In is Null
    // Call validateTimeOutValue when Time In is Before Time Out
    // Call validateTimeOutValue when Time In is After Time Out
    // Call getCompletedCheckOutLogs when Time Out is Null
    // Call getCompletedCheckOutLogs when Time In is Null
    // Call getCompletedCheckOutLogs when Time In is Before Time Out
    // Call getCompletedCheckOutLogs when Time In is After Time Out

    //Start Testing
    // Call newInstance
    @IsTest
    public static void givenRecord_WhenNewInstanceCalled_ThenReturnInstance() {

        BG_Checkout_Log__c testRecord = new BG_Checkout_Log__c();
        Test.startTest();
        IBGCheckOutLogDomain result = BGCheckOutLogDomain.newInstance(new List<BG_Checkout_Log__c>{testRecord});
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }

    // Call Constructor
    @isTest
    public static void givenListOfRecords_WhenConstructorClassCalled_ThenReturnsCorrectNumberOfRecords(){
        List<BG_Checkout_Log__c> records = new List<BG_Checkout_Log__c>{new BG_Checkout_Log__c()};
        BGCheckOutLogDomain.Constructor constructor = new BGCheckOutLogDomain.Constructor();
        BGCheckOutLogDomain domain = (BGCheckOutLogDomain) constructor.construct(records);
        
        Assert.areEqual(records.size(), domain.getBoardGameCheckOutLogs().size(), 'Number of Records Match');
    } 

    // Call validateTimeOutValue when Time Out is Null
    @isTest
    public static void givenRecordWhereTimeOutIsNull_WhenValidateTimeOutIsCalled_ThenReturnsFalse(){
        BG_Checkout_Log__c testRecord = new BG_Checkout_Log__c();
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(new List<BG_Checkout_Log__c>{testRecord});
        
        Test.startTest();
        Boolean result = domain.validateTimeOutValue(testRecord);
        Test.stopTest();

        Assert.isFalse(result, 'Result is True');
    }

    // Call validateTimeOutValue when Time Out has Value and Time In is Null
    @isTest
    public static void givenRecordWhereTimeInIsNull_WhenValidateTimeOutIsCalled_ThenReturnsTrue(){
        BG_Checkout_Log__c testRecord = new BG_Checkout_Log__c(
                                            Check_Out_Time__c = System.Now()
                                        );
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(new List<BG_Checkout_Log__c>{testRecord});
        
        Test.startTest();
        Boolean result = domain.validateTimeOutValue(testRecord);
        Test.stopTest();

        Assert.isTrue(result, 'Result is False');
    }

    // Call validateTimeOutValue when Time In is Before Time Out
    @isTest
    public static void givenRecordWhereTimeInIsBeforeTimeOut_WhenValidateTimeOutIsCalled_ThenReturnsFalse(){
        BG_Checkout_Log__c testRecord = new BG_Checkout_Log__c(
                                            Check_Out_Time__c = System.Now(),
                                            Check_In_Time__c = System.Now().addHours(-1)
                                        );
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(new List<BG_Checkout_Log__c>{testRecord});
        
        Test.startTest();
        Boolean result = domain.validateTimeOutValue(testRecord);
        Test.stopTest();

        Assert.isFalse(result, 'Result is True');
    }

    // Call validateTimeOutValue when Time In is After Time Out
    @isTest
    public static void givenRecordWhereTimeInIsAfterTimeOut_WhenValidateTimeOutIsCalled_ThenReturnsFalse(){
        BG_Checkout_Log__c testRecord = new BG_Checkout_Log__c(
                                            Check_Out_Time__c = System.Now(),
                                            Check_In_Time__c = System.Now().addHours(1)
                                        );
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(new List<BG_Checkout_Log__c>{testRecord});
        
        Test.startTest();
        Boolean result = domain.validateTimeOutValue(testRecord);
        Test.stopTest();

        Assert.isTrue(result, 'Result is False');
    }

    // Call getCompletedCheckOutLogs when Time Out is Null
    @isTest
    public static void givenRecordWhereTimeOutIsNull_WhenGetCompCheckOutLogsIsCalled_ThenReturnsEmptyList(){
        List<BG_Checkout_Log__c> testRecords = new List<BG_Checkout_Log__c>{
                                                    new BG_Checkout_Log__c()
                                                };
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(testRecords);
        
        Test.startTest();
        List<BG_Checkout_Log__c> results = domain.getCompletedCheckOutLogs(testRecords);
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Results Returned Values');
    }

    // Call getCompletedCheckOutLogs when Time In is Null
    @isTest
    public static void givenRecordWhereTimeInIsNull_WhenGetCompCheckOutLogsIsCalled_ThenReturnsEmptyList(){
        List<BG_Checkout_Log__c> testRecords = new List<BG_Checkout_Log__c>{
                                                    new BG_Checkout_Log__c(
                                                        Check_Out_Time__c = System.Now()
                                                    )
                                                };
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(testRecords);
        
        Test.startTest();
        List<BG_Checkout_Log__c> results = domain.getCompletedCheckOutLogs(testRecords);
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Results Returned Values');
    }

    // Call getCompletedCheckOutLogs when Time In is Before Time Out
    @isTest
    public static void givenRecordWhereTimeInIsBeforeTimeOut_WhenGetCompCheckOutLogsIsCalled_ThenReturnsEmptyList(){
        List<BG_Checkout_Log__c> testRecords = new List<BG_Checkout_Log__c>{
                                                    new BG_Checkout_Log__c(
                                                        Check_Out_Time__c = System.Now(),
                                                        Check_In_Time__c = System.Now().addHours(-1)
                                                    )
                                                };
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(testRecords);
        
        Test.startTest();
        List<BG_Checkout_Log__c> results = domain.getCompletedCheckOutLogs(testRecords);
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Results Returned Values');
    }

    // Call getCompletedCheckOutLogs when Time In is After Time Out
    @isTest
    public static void givenRecordWhereTimeInIsAfterTimeOut_WhenGetCompCheckOutLogsIsCalled_ThenReturnsRecord(){
        List<BG_Checkout_Log__c> testRecords = new List<BG_Checkout_Log__c>{
                                                    new BG_Checkout_Log__c(
                                                        Check_Out_Time__c = System.Now(),
                                                        Check_In_Time__c = System.Now().addHours(1)
                                                    )
                                                };
        BGCheckOutLogDomain domain = new BGCheckOutLogDomain(testRecords);
        
        Test.startTest();
        List<BG_Checkout_Log__c> results = domain.getCompletedCheckOutLogs(testRecords);
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Results Returned Incorrect Number of Values');
    }

}