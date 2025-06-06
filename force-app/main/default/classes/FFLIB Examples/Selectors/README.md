# SELECTOR LAYER

## Overview

The Selector Layer is where any and all SOQL calls for the Application should be housed. Any class that requires the use of a SOQL call should use the respective SObject Selector instead. 

__Calls__ to the Selector Methods should be treated as SOQL Calls meaning they should never be inside loops.

__Parameters__ for Selector Methods should always be Sets or Lists for bulkification and possible resuability later.

Selector Methods should __Return__ Lists of the SObject Type not just an individual SObject for bulkification and possible resuability later.

The Benefit is that this Layer can then be Mocked and Stubbed out from the whatever Test Class is calling the Selector to return relevant results without having to actually perform any DML with Test Data. This will allow us to bypass any unneeded data manipulation required by Validation Rules as well as unexpected results from Triggers on the SObject that might change the data on the Test Record. Unit test data can then focus on just the logic in the method without having to worry about any Data Manipulation or Validation Rules that might be applied now or in the future.

### Class
1. Create Selector Layer Class and Interface
1. Add Selector to [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
1. Add Required Methods from Interface
1. Add Methods for Needed SOQL Calls
    1. Each Method should return a List of the SObject
    1. Each Method should accept Sets of parameter values for better reusability
    1. Each Method's name should reflect the ___Where___ Condition of the SOQL call
    1. Methods should NOT contain any logic

#### Selector Interface Template
```
public interface IMySObjectSelector extends fflib_ISObjectSelector {
    List<MySObject__c> selectById(Set<Id> recordIds);
    //Additional Methods go Here
    List<MySObject__c> selectByRelatedRecordId(Set<Id> relatedIds);
}
```
#### Initialize Selector Template
```
MySObjectSelector selector = (MySObjectSelector) MySObjectSelector.newInstance();
```

#### Selector Template
```
@SuppressWarnings('PMD.SOQLInjection')
public without sharing class MySObjectSelector extends fflib_SObjectSelector implements IMySObjectSelector {
    //Required Method to Initialize Selector
    public static IMySObjectSelector newInstance() {
        return (IMySObjectSelector) Application.Selector.newInstance(MySObject__c.SObjectType);
    }

    //Required Method to Determine SObject Type
    public Schema.SObjectType getSObjectType() {
        return MySObject__c.SObjectType;
    }

    //Required Method. Used to get Fields from Object needed in any Selector Method
    //Add Fields to List as Needed.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            MySObject__c.Id
            //Additional Fields Go Here
        };
    }
    
    //Standard Method. Basic Select By ID Query (From Parent fflib_SObjectSelector)
    public List<MySObject__c> selectById(Set<Id> recordIds){
        // If customization is needed like adding related fields, 
        // Replace this line with a standard QueryFactory Setup
        return super.selectSObjectsById(recordIds);
    }
    
    //Addtional Methods Go Here
    public List<MySObject__c> selectByRelatedRecordId(Set<Id> relatedIds){
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Related__r.Name');
        query.setCondition('Related__c = :relatedIds');
        return (List<MySObject__c>) Database.query(query.toSOQL());
    }
}
```

### Test Class
1. Create and Insert Setup Data using Test Utility Class [^1]
1. Create Test Methods for Selector Method
1. Use Asserts or Mocks.Verify Methods to Validate Results

[^1]: This should be the only time you will need to manipulate and insert test data

#### Selector Test Template
```
@isTest
private class MySObjectSelectorTest {
    
    @IsTest
    public static void newInstance_shouldReturnInstance() {

        Test.startTest();
        IMySObjectSelector result = MySObjectSelector.newInstance();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Should return instance');
    }

    @isTest
    public static void givenId_WhenSelectByIdIsCalled_ThenReturnCorrectRecord() {
        
        //Create Test Data (Use Test Util Class where possible)
        MySObject__c testRecord = TestUtil.createMySObject();
        insert testRecord; 

        //Perform Test
        Test.startTest();
        List<MySObject__c> results = MySObjectSelector.newInstance().selectById(new Set<Id>{testRecord.Id});
        Test.stopTest();

        //Validate Data
        Assert.areEqual(1, results.size(), 'No Results Returned for Test Record ID');
        Assert.areEqual(testRecord.Id, results[0].Id, 'Record Returned does not match Test Record');
    }

    //Additional Test Methods for Selector Methods
    
}
```

### Query Factory Options

fflib_QueryFactory query = newQueryFactory(false[^2], false[^3], true[^4]);

    query.selectField('Parent__r.Name'); //selectField is Only way to include fields from Related Objects
    query.setCondition('ID in :setIDs'); //Where Clause for the Query
    query.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING, true) //Sort Results (Field Name, Sort Order, NullsLast)
    query.setLimit(10); //Limit Results

There are more options than those listed above but these are the most common

[^2]: **AssertCRUD**: (Optional) False By Default, Determines if CRUD Permissions are Enforced.

[^3]: **EnforceFLS**: (Optional) False By Default, Determines if Field Level Secrity is Enforced.

[^4]: **IncludeSelectorFields**: (Optional) True By Default, Query Uses Fields from getSObjectFieldList Method. Disable to limit to only own selected fields

## Trailhead and Resources

- [Official FFLIB Selector Layer Overview Definition](https://fflib.dev/docs/selector-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Selector Layer](https://github.com/financialforcedev/df12-apex-enterprise-patterns#data-mapper-selector)
