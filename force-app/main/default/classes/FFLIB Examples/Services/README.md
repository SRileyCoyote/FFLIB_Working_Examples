# SERVICE LAYER

## Overview

The Service Layer is the Meat and Potatoes of the Apex Method. This is where any and all logic should be performed for an SObject. A Service Class Method might call a [Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains) to filter records passed in from the [Implementation Layer](), A [Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors) to make a SOQL call to retrieve related records, or even other Services to perform actions or logic not related to its SObject.

Each Service Method that performs any DML should accept a [Unit of Work]() Object as a parameter from the [Implementation Layer]() and the [Implementation Layer]() should commit the records after the call to all the Service methods. Because no actual DML is being performed yet, __RegisterNew__ or __RegisterDirty__ Methods from the [Unit of Work]() CAN be done inside of a Loop without any issue of hitting Governor Limits. 

The Benefit is that this Layer can then Mocked and Stub out those other Services, [Domains](/force-app/main/default/classes/FFLIB%20Examples/Domains), Selectors, and the UnitOfWork. In doing so, Test data can be created and limited to just the fields and values required by the logic of the Service Unit Test and not have to worry about any additional validation rules for required fields of the record as no SOQL calls or DML will actually be performed in the Unit Tests.

### Class
1. Create Service Layer Class and Interface
1. Add Service to [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
1. Add Logic to Enable/Disable Features using [Custom Metadata Type](/force-app/main/default/objects)
1. Add Methods for Individual Features
    1. Pass in [UnitOfWork]() from [Implementation Layer]() (i.e. [Trigger Handler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers) or an [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers))
    1. Call [Selectors](/force-app/main/default/classes/FFLIB%20Examples/Selectors) for any SOQL Calls Needed 
    1. Call [Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains) for any record filtering or processing
    1. Register All DMLs needed into passed in [UnitOfWork]() Object
### Test Class
1. Add Mocking & Stubbing for any [Selectors](/force-app/main/default/classes/FFLIB%20Examples/Selectors) or [Domains](/force-app/main/default/classes/FFLIB%20Examples/Domains) Used
1. Add Mocking & Stubbing for [UnitOfWork]()
1. Create Test Methods for Every Possible Scenario for Feature NOT Just Code Coverage
    1. Happy Path
    1. Negative Paths
    1. Alternative Paths
    1. Bulkified Records
1. Use Asserts or Mocks.Verify() Methods to Validate Results

### Mocks.Verify Example Quick Reference:

Verify that UOW Register Dirty Method was called

```
((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
    .registerDirty(fflib_Match.anySObject());
```
Verify that UOW Method ran for a Single Specific Record and matches expected values being updated

```
 ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    Board_Games__c.ID => testRecord.ID,
                    Board_Games__c.Name => testRecord.Name
                }
            ));
```
Verify that UOW Method ran for a LIST of Specific Records and matches expected values being updated

```
 ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sObjectsWith(
                  new List<Map<SObjectField,Object>> {
                    new Map<SObjectField,Object> {
                        Board_Games__c.ID => testRecord1.ID,
                        Board_Games__c.Name => testRecord1.Name
                    },
                    new Map<SObjectField,Object> {
                        Board_Games__c.ID => testRecord2.ID,
                        Board_Games__c.Name => testRecord2.Name
                    }
                }
            ));
```
Verify that UOW Method ran for a Specific Record WITH Relationship

```
 ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerNew(fflib_Match.sobjectWith(
                            new Map<Schema.SObjectField, Object>{
                                BG_Library_Entry__c.BGG_Owner__c => testOwnerName,
                                BG_Library_Entry__c.Event__c => testEventId
                            }
                        ),
                        //Matches Relationship Field
                        fflib_Match.eqSObjectField(BG_Library_Entry__c.Board_Game__c), 
                        //Matches Object to create Relationship with
                        fflib_Match.sobjectWith(
                            new Map<Schema.SObjectField, Object>{
                                Board_Games__c.BGG_ID__c => testBoardGame.BGG_ID__c
                            }
                        ) 
            );
```
## Trailhead and Resources

- [Official FFLIB Service Layer Overview Definition](https://fflib.dev/docs/service-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)