# FFLIB Examples

I have broken down the Apex Classes into Seperate Folders for ease of Navigation.
Each Folder has it's own README File to Briefly describe each Layer of the Design Pattern.

- [Application Layer](/force-app/main/default/classes/FFLIB%20Examples/Application) - Single Class holds the lists and Mappings for all of the other Layers 
- Implementation Layer
    - [Trigger Handlers](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers) - Called by the Trigger, Handles all the After and Before Trigger Methods for an SObject 
    - [Apex Controllers](/force-app/main/default/classes/FFLIB%20Examples/Controllers) - Called by either Aura, LWC or VF Pages, Houses all of the Methods for the UI 
- [Domain Layer](/force-app/main/default/classes/FFLIB%20Examples/Domains) - Handles all of the SObject Specific Logic like Validation logic or filtering Triggered Records
- [Selector Layer](/force-app/main/default/classes/FFLIB%20Examples/Selectors) - Handles all of the SOQL Queries for an SObject
- [Services Layer](/force-app/main/default/classes/FFLIB%20Examples/Services) - Handles all of the Logic for an SObject
- [UnitOfWork Layer]() [^1] - Handles all of the DML transactions for all Objects


# Deployment Order
Because of the Dependancies Injected in this Style, Classes and Class Folders needed to be deployed in the following order

| Class Type        | Dependancies 
| ----------------- | ----------------------------------
| Interfaces:       | None
| Selectors:        | Interfaces
| Domain:           | Interfaces and Selectors
| Service:          | Interfaces, Domains, and Selectors
| Trigger Handlers: | Interfaces and Services
| Apex Controllers: | Interfaces and Services
| Application:      | Implemntation, Selectors, Services, and Domains
| Test Classes:     | Application

In order to avoid Deployment Errors or if Deployment Errors occur due to dependancy issues, 
- Comment out the contents of the Maps and Lists in the factories on the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Deploy [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Deploy Classes in Given Folder Order
- Uncomment out the contents on the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Deploy [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)

As new FFLIB Class Layers are created, Deploy interfaces and classes immediately before adding methods or logic so that the Application registers that the classes exist

[^1]: UnitOfWork Layer does not have or need it's own set of classes so doesnt have a folder

# Mock Setup Class
Many of the test classes utilize the use of a MockSetup as an Inner Class in the Test Class. This Inner Class handles all of the Mocking and Stubbing needed for all of the unit tests for quick re-use. 

1. [Create ENUM List](#1-create-enum-list)
1. [Create Map of ParamTypes](#2-create-map-of-paramtypes)
1. [Create MockSetup Class](#3-create-mocksetup-class)
1. [Initialize Undeclared Params](#4-initialize-undeclared-params)
1. [Initialize Variables and Classes to be Stubbed](#5-initialize-variables-and-classes-to-be-stubbed)
1. [Mock and Stub Classes](#6-mock-and-stub-classes)
1. [Set Mocks on Application](#7-replace-classes-with-mocks-when-called-from-application)
1. [Final Product](#8-final-product)
1. [Usage in a Test Method](#9-usage-in-a-test-method)

### 1. Create ENUM List
Start by creating a set of [ENUMs](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_enums.htm), one for each return value you will need for stubbing
```
enum MockParams {
    RETURNED_BOARD_GAMES,
    RETURNED_MESSAGE
}
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 2. Create Map of ParamTypes
Next, create a Map where the Key is the ENUM created above and the value is the data type the stub will return
```
static Map<MockParams, Type> paramTypes {
    get {
        return new Map<MockParams, Type>{
            MockParams.RETURNED_BOARD_GAMES => List<Board_Games__c>.class,
            MockParams.RETURNED_MESSAGE => String.class
        };
    }
}
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 3. Create MockSetup Class

Create the internal class, MockSetup. Create a public ApexMocks and UnitOfWork object as well as any other variables or Objects that will be used repeatedly at the top. Add a contructor that accepts another Map where the ENUM created in Step 1 is the key and an Object is the Value.
```
class MockSetup {
    public fflib_ApexMocks mocks = new fflib_ApexMocks();
    public fflib_SObjectUnitOfWork uowMock;
    // Add Addtional Objects and Variables Here 

    private MockSetup(Map<MockParams, Object> params) {
        // Step 4: Initialize Undeclared Params Here

        // Step 5: Initialize Variables and Classes to be Stubbed Here

        mocks.startStubbing();

        // Step 6: Add Mocking and Stubbing Here

        mocks.stopStubbing();

        // Step 7: Set Mocks Here
    }
}
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 4. Initialize Undeclared Params
Loop through all of the Keys in the ParamTypes Map.
If a the ENUM Key is NOT found in the given Params Map for the MockSetup Constructor, add a new value to the Params map with that ENUM as the Key and a new instance of the Type of Object related to the ENUM in the ParamTypes Map.
This way, if a return value is NOT given in the test method, an empty instance is returned for the stubbed method. 

```
for (MockParams param : paramTypes.keySet()) {
    if (!params.containsKey(param)) {
        params.put(param, paramTypes.get(param).newInstance());
    }
}
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 5. Initialize Variables and Classes to be Stubbed
Initialize any public variables declared in [Step #3](#3-create-mocksetup-class).
Using the fflib_ApexMocks Class, create a Mock version of the Classes that are being called in the Unit Test.
Notice that the stubbed classes are actually the respective Interfaces.
```
mocks = new fflib_ApexMocks();
uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
IBoardGameSelector mockBoardGameSelector = (IBoardGameSelector) mocks.mock(BoardGameSelector.class);
IBoardGameRatingsDomain mockBGRDomain = (IBoardGameRatingsDomain) mocks.mock(BoardGameRatingsDomain.class)
IBGGCalloutService mockCalloutService = (IBGGCalloutService) mocks.mock(BGGCalloutService.class);
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 6. Mock and Stub Classes
Between the ___Mocks.StartStubbing()___ and ___Mocks.StopStubbing()___ calls, we are going to actually stub out out mocked classes intialized in the previous step. Any Methods that are not Stubbed here, will return a null value.

Notice that we are using the ___fflib_Match___ class to mock the inputs the method recieves. What this means is that regardless of what values are given to the method when it is called, always return the value provided in the Params Map given to the constructor. As mentioned in [Step #4](#4-initialize-undeclared-params), if no value was given in the test method, it will return an empty instance of that data type  
#### Stubbed Selector Example:
```
mocks.when(mockBoardGameSelector.SObjectType()).thenReturn(Board_Games__c.SObjectType);
mocks.when(mockBoardGameSelector.selectByBGGIDs(
                                            (Set<String>) fflib_Match.anyObject()
                                        ))
    .thenReturn((List<Board_Games__c>) params.get(MockParams.RETURNED_BOARD_GAMES));
```
__IMPORTANT__: Stubbing the SObjectType is REQUIRED here or the Mocking of the Selector WILL Fail

#### Stubbed Service Example:
```
mocks.when(mockBoardGameService.getIDsFromBoardGameGeek(
                                fflib_Match.anyString(),
                                fflib_Match.eqBoolean(true)
                            ))
    .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
```
#### Throw Exception Example
If you need to test the Catch Block on a Try-Catch, you can Stub the method to Throw an Exception whenever the method is called instead. You can include a Boolean in the MockSetup Class Constructor for ___throwErrors___ so that you can control which test methods need to test if the catching of Exceptions.
```
if(throwErrors){
    ((IBoardGamesService) mocks.doThrowWhen(new BoardGamesService.BGServiceException('Thrown Exception'),
                                            mockBoardGameService)).getIDsFromBoardGameGeek(
                                                        fflib_Match.anyString(),
                                                        fflib_Match.anyBoolean()
                                                    );
}

```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 7. Replace Classes with Mocks when called from Application
Finally, we will set the Mocks so that whenever they are created using the [Application Class](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls), they will instead create and use our Mock Class.
This is why it is important that whenever we call these classes from our Methods, we do so using the [Application Layer](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls).
```
Application.UnitOfWork.setMock(uowMock);
Application.Domain.setMock(mockBGRDomain);
Application.Selector.setMock(mockBoardGameSelector);
Application.Service.setMock(IBoardGamesService.class, mockBoardGameService);
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 8. Final Product
When we put it all together it should look something like this:
```
//Step 1:
enum MockParams {
    RETURNED_BOARD_GAMES,
    RETURNED_MESSAGE
}

//Step 2:
static Map<MockParams, Type> paramTypes {
    get {
        return new Map<MockParams, Type>{
            MockParams.RETURNED_BOARD_GAMES => List<Board_Games__c>.class,
            MockParams.RETURNED_MESSAGE => String.class
        };
    }
}

//Step 3:
class MockSetup {
    public fflib_ApexMocks mocks = new fflib_ApexMocks();
    public fflib_SObjectUnitOfWork uowMock;

    private MockSetup(Map<MockParams, Object> params, Boolean throwErrors) {
        
//Step 4:
        for (MockParams param : paramTypes.keySet()) {
            if (!params.containsKey(param)) {
                params.put(param, paramTypes.get(param).newInstance());
            }
        }

// Step 5:
        mocks = new fflib_ApexMocks();
        uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        IBoardGameSelector mockBoardGameSelector = (IBoardGameSelector) mocks.mock(BoardGameSelector.class);
        IBoardGameRatingsDomain mockBGRDomain = (IBoardGameRatingsDomain) mocks.mock(BoardGameRatingsDomain.class)
        IBGGCalloutService mockCalloutService = (IBGGCalloutService) mocks.mock(BGGCalloutService.class);

        mocks.startStubbing();

// Step 6:
        mocks.when(mockBoardGameSelector.SObjectType()).thenReturn(Board_Games__c.SObjectType);
        mocks.when(mockBoardGameSelector.selectByBGGIDs(
                                                    (Set<String>) fflib_Match.anyObject()
                                                ))
            .thenReturn((List<Board_Games__c>) params.get(MockParams.RETURNED_BOARD_GAMES));

        if(throwErrors){
            ((IBoardGamesService) mocks.doThrowWhen(new BoardGamesService.BGServiceException('Thrown Exception'),
                                    mockBoardGameService)).getIDsFromBoardGameGeek(
                                            fflib_Match.anyString(),
                                            fflib_Match.anyBoolean()
                                        );
        } else {
            mocks.when(mockBoardGameService.getIDsFromBoardGameGeek(
                                            fflib_Match.anyString(),
                                            fflib_Match.eqBoolean(true)
                                        ))
                .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
        }

        mocks.stopStubbing();

// Step 7:
        Application.UnitOfWork.setMock(uowMock);
        Application.Domain.setMock(mockBGRDomain);
        Application.Selector.setMock(mockBoardGameSelector);
        Application.Service.setMock(IBoardGamesService.class, mockBoardGameService);
    }
}
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

### 9. Usage in a Test Method
Now that we have our MockSetup Class built, here is how we would use it in a test method.

#### Test Method Utilizing MockSetup
Notice that we are only setting the Returned Board Games in the Params as this is the only return value we would need in this test method.

Since we are not needing to perform any DMLs, can use ___Mocks.Verify()___ to validate that the records were commited to be updated in the mocked UnitOfWork ([See Below for Mocks.Verify() examples](#mocksverify-example-quick-reference))
```
@IsTest
public static void givenInputParamters_WhenMethodNameIsCalled_ThenReturnExpectedMessage(){

    //Setup Test Data and Mocking
    Board_Games__c testBoardGame = new Board_Games__c(
                                        ID = fflib_IDGenerator.generate(Board_Games__c.SObjectType),
                                        BGG_ID__c = '12345',
                                        Name = 'My Board Game'
                                    );

    //Setup Return Values
    Map<MockParams, Object> params = new Map<MockParams, Object>{
        MockParams.RETURNED_BOARD_GAMES => new List<Board_Games__c>{testBoardGame},
    };

    //Initialize MockSetup with Params without throwing errors
    MockSetup mock = new MockSetup(params, false);

    //Run Test
    Test.startTest();
    String result = ClassBeingTested.MethodBeingTested(testBoardGame.Id, '12345');
    Test.stopTest();

    //Validate Data
    Assert.areEqual('Success', result, 'Incorrect Message Recieved: '+ result);

     ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    Board_Games__c.ID => testBoardGame.ID,
                    Board_Games__c.Name => testBoardGame.Name
                }
            ));
}
```
#### Test Method Utilizing MockSetup Catching Exception
Notice that the Exception Message returned matches the Exception Message that was provided in our MockSetup Class when we mocked throwing the Exception.
```
@IsTest
public static void givenInputParamters_WhenMethodNameIsCalled_ThenThrowError(){

    //Setup Test Data and Mocking
    //No Test Data Needed For this Unit Test
    Map<MockParams, Object> params = new Map<MockParams, Object>{
        MockParams.RETURNED_MESSAGE => 'Service Mocked Successfully'
    };

    //Initialize MockSetup with Params with errors thrown
    MockSetup mock = new MockSetup(params, true);

    //Run Test
    Test.startTest();
    String errMsg = 'No Errors';
    try{
        String result = ClassBeingTested.MethodBeingTested(testBoardGame.Id, '12345');
        Assert.isTrue(false, 'Error Not Thrown');
    } catch (Exception ex){
        errMsg = ex.getMessage();
    }
    Test.stopTest();

    //Validate Data
    Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
}
```
[Back to Steps](#mock-setup-class) - [Back to Top](#fflib-examples)

Full Credit to John Towers for this design!

# Mocks.Verify Example Quick Reference:
Since one of the benefits of Mocking and Stubbing is that we will not need to do any actual Inserts or Updates in Test Methods for the majority of classes, thereby not having to worry about any validation rules or other triggers firing while testing, we need a way to validate that a record has been (or in this case will be) inserted or updated with the correct information. This is where we will use the ___Mocks.Verify()___ method.

Here are examples of usage of some of the different types of ways to use the ___Mocks.Verify()___ method:

Verify that UOW Register Dirty Method was called X number of times

```
((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, X))
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


