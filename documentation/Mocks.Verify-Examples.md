# Mocks.Verify()
Since one of the benefits of Mocking and Stubbing is that we will not need to do any actual Inserts or Updates in Test Methods for the majority of classes, thereby not having to worry about any validation rules or other triggers firing while testing, we will need a way to validate that a record has been (or in this case will be) inserted or updated with the correct information. This is where we will use the ***Mocks.Verify()*** method.

## Examples
Here are examples of usage of some of the different types of ways to use the ***Mocks.Verify()*** method:

#### Verify that UOW Register Dirty Method was called X number of times

```
((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, X))
    .registerDirty(fflib_Match.anySObject());
```
#### Verify that UOW Method ran for a Single Specific Record and matches expected values being updated

```
 ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    Board_Games__c.ID => testRecord.ID,
                    Board_Games__c.Name => testRecord.Name
                }
            ));
```
#### Verify that UOW Method ran for a LIST of Specific Records and matches expected values being updated

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
#### Verify that UOW Method ran for a Specific Record WITH Relationship

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
