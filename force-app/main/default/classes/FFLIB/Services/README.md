# SERVICE LAYER

## Overview
### Class
1. Create Service Layer Class and Interface
1. Add Service to [Application](/force-app/main/default/classes/FFLIB/Application)
1. Add Logic to Enable/Disable Features using [Custom Metadata Type](/force-app/main/default/objects)
1. Add Methods for Individual Features
    1. Pass in [UnitOfWork]() from [Domain](/force-app/main/default/classes/FFLIB/Domains)
    1. Call [Selectors](/force-app/main/default/classes/FFLIB/Selectors) for any SOQL Calls Needed 
    1. Register All DMLs needed into passed in [UnitOfWork]() Object
### Test Class
1. Add Mocking & Stubbing for any [Selectors](/force-app/main/default/classes/FFLIB/Selectors) Used
1. Add Mocking & Stubbing for [UnitOfWork]()
1. Create Test Methods for Every Possible Scenario for Feature NOT Just Code Coverage
    1. Happy Path
    1. Negative Paths
    1. Alternative Paths
    1. Bulkified Records
1. Use Asserts or Mocks.Verify Methods to Validate Results

### Mocks.Verify Example Quick Reference:

Verify that UOW Method ran X number of times

```
((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, X))
    .registerDirty(fflib_Match.anySObject());
```
Verify that UOW Method ran for a Single Specific Record

```
 ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    Board_Games__c.ID => testRecord.ID,
                    Board_Games__c.Name => testRecord.Name
                }
            ));
```
Verify that UOW Method ran for a LIST of Specific Records

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

- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)