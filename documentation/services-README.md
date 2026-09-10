# SERVICE LAYER

## Overview

The Service Layer is the Meat and Potatoes of the Apex Method. This is where any and all logic should be performed for an SObject. A Service Class Method might call a [Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains) to filter records passed in from the [Implementation Layer](), A [Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors) to make a SOQL call to retrieve related records, or even other Services to perform actions or logic not related to its SObject.

Each Service Method that performs any DML should accept a [Unit of Work]() Object as a parameter from the [Implementation Layer](). The [Implementation Layer]() should commit the records after the call to all the Service methods. Because no actual DML is being performed yet, **`RegisterNew`** or **`RegisterDirty`** Methods from the [Unit of Work]() CAN be done inside of a Loop without any issue of hitting Governor Limits. 

The Benefit is that this Layer can then Mock and Stub out those other Services, [Domains](/force-app/main/default/classes/FFLIB%20Examples/Domains), [Selectors](/force-app/main/default/classes/FFLIB%20Examples/Selectors), and the [UnitOfWork](). In doing so, Test data can be created and limited to just the fields and values required by the logic of the Service Unit Test and not have to worry about any additional validation rules or required fields of the record as no SOQL calls or DML will actually be performed in the Unit Tests.

### Class
1. Create Service Layer Class and Interface
1. Add Service to [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
1. Add Logic to Enable/Disable Features using [Custom Metadata Type](/force-app/main/default/objects)
1. Add Methods for Individual Features
    1. Pass in [UnitOfWork]() from [Implementation Layer]() (i.e. [Trigger Handler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers) or an [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers))
    1. Call [Selectors](/force-app/main/default/classes/FFLIB%20Examples/Selectors) for any SOQL Calls Needed 
    1. Call [Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains) for any record filtering or processing
    1. Register All DMLs needed into passed in [UnitOfWork]() Object

#### Service Interface Template
```
public interface IMySObjectService {
    //Service Methods Go Here
}
```

#### Service Initialization Template
```
MySObjectService service = (MySObjectService) MySObjectService.newInstance();
```

#### Service Template
[Extends Base Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services/BaseService.cls)
```
public without sharing class MySObjectService extends BaseService implements IMySObjectService {
    
    //Set Variables, Domains, and Selectors used throughout Service

    //Set Static Error Messages
    @TestVisible private static final String SERVICE_NOT_ENABLED_MSG = 'This Service is Not Enabled. Please Contact a System Administrator to Enable';
    @TestVisible private static final String NO_RECORD_ID_ERR_MSG = 'Invalid ID';

    public static IMySObjectService newInstance(){
        return (IMySObjectService) Application.Service.newInstance(IMySObjectService.class);
    }

    //Initialize Service Class
    public MySObjectService(){
        super('MySObject');
    }

    @TestVisible
    //Private Constructor for Testing to provide own Service Config
    private MySObjectService(List<Services_Config__mdt> configList){
        super(configList, 'MySObject'); 
    }

    //Abstract Method from Parent that Must be implemented
    protected override void initialize(){
        //Initialize Any Selectors through Application Layer 
        // so they can be Mocked and Stubbed from the Test Class
    }

    public void myMethod(fflib_SObjectUnitOfWork uow, Id recordId){
        //If Not Enabled, Throw Error
        if(!this.serviceEnabled('myMethod')){ //Check if this Service Method is Enabled from Parent
            throw new MySObjectServiceException(SERVICE_NOT_ENABLED_MSG);
        }

        //Validate Inputs
        if(recordId == null){
            throw new MySObjectServiceException(NO_RECORD_ID_ERR_MSG);
        }

        // Do Work
    }

    public class MySObjectServiceException extends Exception {}
}
```

### Test Class
1. Add Mocking & Stubbing for any [Selectors](/force-app/main/default/classes/FFLIB%20Examples/Selectors) or [Domains](/force-app/main/default/classes/FFLIB%20Examples/Domains) Used
1. Add Mocking & Stubbing for [UnitOfWork]()
1. Create Test Methods for Every Possible Scenario for Feature NOT Just Code Coverage
    1. Happy Path
    1. Negative Paths
    1. Alternative Paths
    1. Bulkified Records
1. Use Asserts or [Mocks.Verify()](/documentation/Mocks.Verify-Examples.md) Methods to Validate Results

#### Service Test Class Template
**NOTE**: [MockSetup Class Template](/documentation/MockSetup-Class#8-final-product)
```
@isTest
private class MySObjectServiceTest {
    //#region MockSetup
    // MockSetup Class Template Goes Here
    //#endregion

    //Test Plan
    // Call newInstance
    // Call Service using Current Config Record
    // Call MyMethod with Custom Config where Service Disabled
    // List of Additional Unit Tests Go Here

    //Start Testing
    // Call newInstance
    @IsTest
    public static void givenRecord_WhenNewInstanceCalled_ThenReturnInstance() {

        MySObject__c testRecord = new MySObject__c();
        Test.startTest();
        IMySObjectService result = MySObjectService.newInstance();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }

    // Call Service using Current Config Record
    @IsTest
    public static void givenCurrentServiceConfig_WhenServiceClassCalled_ThenCurrentServiceConfigReturned(){
        Test.startTest();
        MySObjectService service = (MySObjectService) MySObjectService.newInstance();
        Test.stopTest(); 

        // Validate that serviceConfigMap not only contains values for the MySObjectService
        Assert.areNotEqual(0, service.serviceConfigMap.size(), 'No Service Configs Found for MySObject Domain');
        // Check for Methods in Service Config Here
        Assert.isTrue(service.serviceConfigMap.containsKey('myMethod'), 'Service Config for myMethod Method Not Found');
    }

    //#region /////////////////// MyMethod ///////////////////////////////
    // Call MyMethod with Custom Config where Service Disabled
    @IsTest
    public static void givenServiceConfigWithServiceDisabled_WhenMyMethodIsCalled_ThenErrorThrown(){

        //Setup Test Data and Mocking
        //Setup Return Values
        Map<MockParams, Object> params = new Map<MockParams, Object>();

        //Initialize MockSetup with Params 
        MockSetup mock = new MockSetup(params);
        
        //Customize Service Config Record
        mock.mockConfig.DeveloperName = 'myMethod';
        mock.mockConfig.Service_Enabled__c = false;

        //Run Test
        Test.startTest();
        String errMessage = 'No Error Found';
        MySObjectService service = new MySObjectService(new List<Services_Config__mdt>{mock.mockConfig});
        try{
            service.myMethod(mock.uowMock, fflib_IDGenerator.generate(MySObject__c.SObjectType));            
        Assert.isTrue(false, 'Error Not Thrown');
        } catch (Exception ex){
            errMessage = ex.getMessage();
        }
        Test.stopTest();

        //Validate Data
        Assert.areEqual(service.SERVICE_NOT_ENABLED_MSG, errMessage, 'Error Message Does Not Match: '+ errMessage);
    }
    //Additional MyMethod Tests Go Here
    //#endregion

}
```

## Trailhead and Resources

- [Official FFLIB Service Layer Overview Definition](https://fflib.dev/docs/service-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)