# DOMAIN LAYER

## Overview

The Domain Layer should generally be called by the [Service Layer](/force-app/main/default/classes/FFLIB%20Examples/Services). The Domain Layer is very similair to the [Service Layer](/force-app/main/default/classes/FFLIB%20Examples/Services) however it should be limited to methods that are specific to the SObject Record. 

These methods might be ones that filter out records passed in from the Implementation Layer (i.e. [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers) or [Trigger Handler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers)) to only those that apply to that Service Method. Any Custom Validation Rules that need to be applied should be housed in the Domain Layer. 

The Benefit is that this Layer can then be Mocked and Stubbed out from the [Service Layer](/force-app/main/default/classes/FFLIB%20Examples/Services) Test Class and Test Data being applied to the Service Method Tests are then independant of any Custom Validation or Filtering that might be applied. Test Data is then simplified to just the data needed for the Unit Test without worry of either of those things that currently exist or might be added in the future.  

### Class
1. Create Domain Layer Class and Interface
1. Add Domain to [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
1. Add Methods for Record Filtering, Validation, or Processesing 

#### Domain Interface Template
[Extends Base Domain Interface](/force-app/main/default/classes/FFLIB%20Examples/Domains/Interfaces/IBaseDomain.cls)
```
public interface IMySObjectDomain extends IBaseDomain {
    //Any Additional Methods specific to the MySObjectDomain should go here
}
```

#### Domain Initialization Template
```
MySObjectDomain domain = (MySObjectDomain) MySObjectDomain.newInstance(records);
```

#### Domain Template

[Extends Base Domain Class](/force-app/main/default/classes/FFLIB%20Examples/Domains/BaseDomain.cls)

```
public class MySObjectDomain extends BaseDomain implements IMySObjectDomain {
    
    public static IMySObjectDomain newInstance(List<MySObject__c> recordList){
        return (MySObjectDomain) Application.Domain.newInstance(recordList);
    }

    public MySObjectDomain(List<MySObject__c> sObjectList) {
        super(sObjectList, MySObject__c.SObjectType);
    }

    public List<MySObject__c> getMySObjectRecords()
	{
		return (List<MySObject__c>) getRecords();
	}

    //Additional Domain Methods Here

    public class Constructor implements fflib_IDomainConstructor {
        public fflib_SObjects construct(List<Object> objectList) {
            return new MySObjectDomain((List<SObject>) objectList);
        }
    }

}
```


### Test Class
1. Create Test Class for Domain
    1. Create Unit Test Methods for Domain
    1. Use Asserts to Validate Results

#### Domain Test Class Template
```
@IsTest
public class BoardGameRatingsDomainTest {
       
    // Call newInstance
    @IsTest
    public static void givenRecord_WhenNewInstanceCalled_ThenReturnInstance() {

        MySObject__c testRecord = new MySObject__c();
        Test.startTest();
        IMySObjectDomain result = MySObjectDomain.newInstance(new List<MySObject__c>{testRecord});
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return instance');
    }

    // Call Constructor
    @isTest
    public static void givenListOfRecords_WhenConstructorClassCalled_ThenReturnsCorrectNumberOfRecords(){
        List<MySObject__c> records = new List<MySObject__c>{new MySObject__c()};
        MySObjectDomain.Constructor constructor = new MySObjectDomain.Constructor();
        MySObjectDomain domain = (MySObjectDomain) constructor.construct(records);
        
        Assert.areEqual(records.size(), domain.getMySObjectRecords().size(), 'Number of Records Match');
    } 

    //Test Additional Domain Methods Here 

}
```

## Trailhead and Resources

- [Official FFLIB Domain Layer Overview Definition](https://fflib.dev/docs/domain-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Domain Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer)
