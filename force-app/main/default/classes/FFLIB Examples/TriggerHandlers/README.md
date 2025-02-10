# TRIGGER HANDLERS

## Overview

TriggerHandlers are part of the [Implementation Layer]() and are where all Trigger-Specific Logic will be housed for each of the different types of Before and After Triggers. 

TriggerHandlers will initialize an FFLIB UnitOfWork Object and the [Service Classes](/force-app/main/default/classes/FFLIB%20Examples/Services) that will perform the actual logic for the trigger, passing the [Unit of Work Object]() into the Service Class as a Parameter. By Initializing the [Unit of Work]() here and performing and Commiting the records here, all DMLs (either Insert or Update) are performed at once at the END of the Trigger in a single DML Transaction in the Order indicated by the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)

The Benefit of this is that the trigger itself is free of logic and, by stubbing the [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services), Unit Tests for the TriggerHandler can then just focus on the logic for determining if the Trigger should Fire or not based on Settings of the Custom Metadata Type associated with the Trigger without the need for detailed test data. 

### Class
1. Create Trigger for SObject, Calling TriggerHandler.
1. Add Logic to use [Custom Metadata Type](/force-app/main/default/objects) to:
    1. Enable/Disable Trigger
    1. Prevent Recurrison
    1. Bypass Error Handling
1. Add Override Methods for the different Trigger Types Needed
    1. Call [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) to Handle logic
    1. Pass in [UnitOfWork]() Object to all Service Methods
    1. Commit Work on [UnitOfWork]() Object

#### Trigger Template
```
trigger mySObjectTrigger on mySObject (before insert, after insert, before update, after update) {

    //All Logic Moved to the Trigger Handler, Domain, and Service Class for the Object
    fflib_SObjectDomain.triggerHandler(MySObjectTriggerHandler.class);

}
```

#### TriggerHandler Template
Extends [Base TriggerHandler Class](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/BaseTriggerHandler.cls)
```
public with sharing class MySObjectTriggerHandler extends BaseTriggerHandler {
    
    //Variables and Objects
    private MySObjectService service;
    
    //Set Final Strings for Error Messages
    @TestVisible private static final String ERR_MESSAGE = 'An Error Occured {0} in the MySObject Trigger Handler: {1}';

    //Actual Constructor for the Trigger Handler
    public MySObjectTriggerHandler(List<MySObject__c> sObjectList){
        super('MySObject', MySObjectTriggerHandler.class, sObjectList);
    }

    @TestVisible
    //Constructor Used For Testing and Setting Own Config File
    private MySObjectTriggerHandler(Domain_Config__mdt config, List<MySObject__c> sObjectList)
    {
        super(config, MySObjectTriggerHandler.class, sObjectList);
    }

    protected override void initialize(){
        service = (MySObjectService) MySObjectService.newInstance();
    }

    // Override Trigger Methods 
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();

        if(this.domainConfig.Prevent_Recursion__c)
        {
            system.debug('Disabling Trigger For Recursion ...');
            fflib_SObjectDomain.getTriggerEvent(MySObjectTriggerHandler.class).disableAfterUpdate(); 
        }

        try{         
            //Do Work
            service.myServiceMethod(uow, super.getRecords());
            uow.commitWork();
        }
        catch (Exception e) 
        {
            //Bypass Error Handling, If Enabled
            if(this.domainConfig.Bypass_Error_Handling__c)
            {
                System.debug('An Error Occured Before Insert', e);
            }
            else 
            {
                throw new MySObjectTriggerHandlerException( String.format(ERR_MESSAGE, new String[]{'Before Insert', ex.getMessage()}));
            }
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new MySObjectTriggerHandler(sObjectList);
		}
	}

    public class MySObjectTriggerHandlerException extends Exception {}

}
```

### Test Classes
1. Create Test Class for Trigger Handler
    1. Add Mocking & Stubbing for [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) Class
    1. Create Unit Test Methods for TriggerHandler:
        1. Test Only Logic in TriggerHandler NOT Service Class
        2. Test Every Possible Scenario for TriggerHandler Configurations NOT Just Code Coverage
    1. Use Asserts or [Mocks.Verify() Methods](/documentation/Mocks.Verify-Examples.md) to Validate Results
1. Create Test Class for Trigger [^1]
    
[^1]: Testing here will only be for coverage as all other logic will be tested in the other layers

#### Trigger Test Template
```
@isTest
private class MySObjectTriggerTest {

    @IsTest
    public static void triggerTest(){

        Test.startTest();
            MySObject__c testRecord = TestUtil.createMySObject(); //Use TestUtil to generate test data
            insert testRecord;
        Test.stopTest();

        //Trigger Logic is tested in the TriggerHandler, Domain, and Service classes
        Assert.isNotNull(testRecord.Id, 'Record ID Not Found');
    }
}
```

#### TriggerHandler Test Template
**NOTE**: [MockSetup Class Template](/documentation/MockSetup-Class#8-final-product)
```
@IsTest
public class MySObjectTriggerHandlerTest {
    //#region MockSetup
    // MockSetup Class Template Goes Here
    //#endregion

    //Test Plan
    // Call Constructor Class 
    // Call TriggerHandler with Current Config 
    // Call TriggerHandler with Custom Config where Trigger Disabled
    //Additional Planned Tests Goes Here
    // Call BeforeUpdate Method with MySObject Record
    // Call BeforeUpdate Method with Custom Config where Recursion Disabled
    // Call BeforeUpdate and Throw Error with Custom Config where Bypass Triggers Disabled
    // Call BeforeUpdate and Throw Error with Custom Config where Bypass Triggers Enabled


    //Start Testing
    // Call Constructor Class
    @isTest
    public static void givenListOfRecords_WhenConstructorClassCalled_ThenReturnsCorrectNumberOfRecords(){
        List<MySObject__c> records = new List<MySObject__c>{new MySObject__c()};
        MySObjectTriggerHandler.Constructor constructor = new MySObjectTriggerHandler.Constructor();
        MySObjectTriggerHandler handler = (MySObjectTriggerHandler) constructor.construct(records);
        
        Assert.areEqual(records.size(), handler.getRecords().size(), 'Number of Records Match');
    }

    // Call TriggerHandler with Current Config 
    @IsTest
    public static void givenNothing_WhenTriggerHandlerInitialized_ThenUseCurrentConfigMDT(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, false);
        
        // Create Test Data
        List<MySObject__c> testRecords = new List<MySObject__c>{
            new MySObject__c(Id = fflib_IdGenerator.generate(MySObject__c.sobjectType))
        };

        Test.startTest();
            MySObjectTriggerHandler triggerhandler = new MySObjectTriggerHandler(testRecords);
        Test.stopTest();

        //Validate Current Config Record was Used
        Assert.areEqual('MySObject', triggerhandler.domainConfig.DeveloperName, 'Dev Name for Config File Does not match');
    }

    // Call TriggerHandler with Custom Config where Trigger Disabled 
    @IsTest
    public static void givenConifigWithDisableTriggersEnabled_WhenTriggerHandlerInitialized_ThenTriggerDisabled(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
            Bypass_Trigger__c = true,
            Bypass_Error_Handling__c = false,
            Prevent_Recursion__c = false
        );
        

        Test.startTest();
            MockSetup mock = new MockSetup(params, config, false);
        Test.stopTest();

        //Validate Triggers are Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(MySObjectTriggerHandler.class).BeforeUpdateEnabled, 'Before Update Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(MySObjectTriggerHandler.class).BeforeInsertEnabled, 'Before Insert Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(MySObjectTriggerHandler.class).AfterUpdateEnabled, 'After Update Was Not Disabled');
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(MySObjectTriggerHandler.class).AfterInsertEnabled, 'After Insert Was Not Disabled');
    }

    //Add Additional Trigger Type Tests Here
    //#region /////////////////// BeforeUpdate Tests ////////////////////////////////
    // Call BeforeUpdate Method with BG Checkout Log Record
    @IsTest
    public static void givenRecord_WhenOnBeforeUpdateIsCalled_ThenNoErrors(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, false);

        // Create Test Data
            // No DML will occur on these records so a Fake Id will be used as the ID and the record can be empty
            // Actual Logic will be tested in the Service Class
        ID recordID = fflib_IdGenerator.generate(MySObject__c.sObjectType);
        Map<ID, MySObject__c> existingRecords = new Map<ID, MySObject__c>{
                                                                recordID => new MySObject__c( ID = recordID )                      
                                                        };

        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onBeforeUpdate(existingRecords);
            Assert.isTrue(true, 'Error Thrown');
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate No Error Was Thrown
        Assert.areEqual('No Errors', errMsg, 'Error Message Recieved: '+ errMsg);

    }

    // Call BeforeUpdate Method with Custom Config where Recursion Disabled
    @IsTest
    public static void givenConifigWithPreventRecursionEnabled_WhenOnBeforeUpdateIsCalled_ThenOnBeforeUpdateMethodsDisabled(){
        
        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params, Dont Throw Errors, and Given Settings on Config File
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = false,
                                        Prevent_Recursion__c = true
                                    );
        MockSetup mock = new MockSetup(params, config, false);

        // Create Test Data
        ID recordId = fflib_IdGenerator.generate(MySObject__c.sobjectType);
        Map<ID, MySObject__c> existingRecords = new Map<ID, MySObject__c>{
                                                                recordId => new MySObject__c( ID = recordId )                      
                                                        };

        Test.startTest();
            mock.triggerHandler.onBeforeUpdate(existingRecords);
        Test.stopTest();

        //Validate Before Update Trigger is Disabled
        Assert.isFalse(fflib_SObjectDomain.getTriggerEvent(MySObjectTriggerHandler.class).BeforeUpdateEnabled, 'Before Update Was Not Disabled');
    }

    // Call BeforeUpdate and Throw Error with Custom Config where Bypass Triggers Disabled
    @IsTest
    public static void givenConifigWithByPassErrorHandlingDisabled_WhenBeforeUpdateErrorOccurs_ThenErrorThrown(){

        //Setup Test Data and Mocking
        // Create Test Data
        ID recordId = fflib_IdGenerator.generate(MySObject__c.sobjectType);
        Map<ID, MySObject__c> existingRecords = new Map<ID, MySObject__c>{
                                                                recordId => new MySObject__c( ID = recordId )                      
                                                        };
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();
        
        //Initialize MockSetup with params, Throw Errors, and Default Settings on Config File
        MockSetup mock = new MockSetup(params, true);

        
        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onBeforeUpdate(existingRecords);
            Assert.isTrue(false, 'Error Not Thrown');
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Correct Error Was Thrown
        Assert.areEqual(String.format(MySObjectTriggerHandler.ERR_MESSAGE, new String[]{'Before Update', 'Thrown Exception'}), errMsg, 'Error Message Recieved: '+ errMsg);
    }

    // Call BeforeUpdate and Throw Error with Custom Config where Bypass Triggers Enabled
    @IsTest
    public static void givenConifigWithByPassErrorHandlingEnabled_WhenBeforeUpdateErrorOccurs_ThenErrorBypassed(){

        //Setup Test Data and Mocking
        // Create Test Data
        ID recordId = fflib_IdGenerator.generate(MySObject__c.sobjectType);
        Map<ID, MySObject__c> existingRecords = new Map<ID, MySObject__c>{
                                                                recordId => new MySObject__c( ID = recordId )                      
                                                        };
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Setup Custom Config
        Domain_Config__mdt config = new Domain_Config__mdt(
                                        Bypass_Trigger__c = false,
                                        Bypass_Error_Handling__c = true,
                                        Prevent_Recursion__c = false
                                    );

        //Initialize MockSetup with params, Dont Throw Errors, and Given Settings on Config File
        MockSetup mock = new MockSetup(params, config, true);

        Test.startTest();
        String errMsg = 'No Errors';
        try{
            mock.triggerHandler.onBeforeUpdate(existingRecords);
        }
        catch (Exception ex){
            errMsg = ex.getMessage();
        }
        Test.stopTest();

        //Validate Before Update Trigger is Disabled
        Assert.areEqual('No Errors', errMsg, 'Error Message Recieved: '+ errMsg);
    }

    //#endregion

}
```
See [TriggerHandlerTest](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/Tests/BoardGameCheckOutLogsTriggerHandlerTest.cls) for more Test Examples for Trigger Handlers

## Trailhead and Resources

- [Official FFLIB Implementation Layer Overview Definition](https://fflib.dev/docs/implementation-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
