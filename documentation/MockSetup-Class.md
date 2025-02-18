# MockSetup Class
Mocking and Stubbing is a key component and benefit of using FFLIB. Beacause of this, many of the test classes will utilize the use of a MockSetup as an Inner Class in the Test Class. This Inner Class handles all of the Mocking and Stubbing needed for all of the unit tests for quick re-use in each test method. Full Credit to John Towers for showing me this initial design!

1. [Setup](#setup-mocksetup-class)
    1. [Create ENUM List](#1-create-enum-list)
    1. [Create Map of ParamTypes](#2-create-map-of-paramtypes)
    1. [Create MockSetup Class](#3-create-mocksetup-class)
    1. [Initialize Undeclared Params](#4-initialize-undeclared-params)
    1. [Initialize Variables and Classes to be Stubbed](#5-initialize-variables-and-classes-to-be-stubbed)
    1. [Mock and Stub Classes](#6-mock-and-stub-classes)
    1. [Set Mocks on Application](#7-replace-classes-with-mocks-when-called-from-application)
    1. [Final Product](#8-final-product)
1. [Example Usage in a Test Method](#example-in-a-test-method)
    1. [Example Test Method](#example-test-method-utilizing-mocksetup)
    1. [Example Test Method for Exception](#example-test-method-utilizing-mocksetup-catching-exception)

## Setup MockSetup Class

### 1. Create ENUM List
Start by creating a set of [ENUMs](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_enums.htm), one for each return value you will need for stubbing
```
enum MockParams {
    RETURNED_MYSOBJECTS,
    RETURNED_MESSAGE
}
```
[Back to Steps](#mocksetup-class)

### 2. Create Map of ParamTypes
Next, create a Map where the Key is the ENUM created above and the value is the data type the stub will return
```
static Map<MockParams, Type> paramTypes {
    get {
        return new Map<MockParams, Type>{
            MockParams.RETURNED_MYSOBJECTS => List<MySObject__c>.class,
            MockParams.RETURNED_MESSAGE => String.class
        };
    }
}
```
[Back to Steps](#mocksetup-class) 

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
[Back to Steps](#mocksetup-class) 

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
[Back to Steps](#mocksetup-class) 

### 5. Initialize Variables and Classes to be Stubbed
Initialize any public variables declared in [Step #3](#3-create-mocksetup-class).
Using the fflib_ApexMocks Class, create a Mock version of the Classes that are being called in the Unit Test.
Notice that the stubbed classes are actually the respective Interfaces.
```
mocks = new fflib_ApexMocks();
uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
IMySObjectSelector mockSelector = (IMySObjectSelector) mocks.mock(MySObjectSelector.class);
IMySObjectDomain mockDomain = (IMySObjectDomain) mocks.mock(MySObjectDomain.class)
ICalloutService mockCalloutService = (ICalloutService) mocks.mock(CalloutService.class);
```
[Back to Steps](#mocksetup-class) 

### 6. Mock and Stub Classes
Between the ***`Mocks.StartStubbing()`*** and ***`Mocks.StopStubbing()`*** calls, we are going to actually stub out out mocked classes intialized in the previous step. Any Methods that are not Stubbed here, will return a null value.

Notice that we are using the ***`fflib_Match`*** class to mock the inputs the method recieves. What this means is that regardless of what values are given to the method when it is called, always return the value provided in the Params Map given to the constructor. As mentioned in [Step #4](#4-initialize-undeclared-params), if no value was given in the test method, it will return an empty instance of that data type  
#### Stubbed Selector Example:
```
mocks.when(mockSelector.SObjectType()).thenReturn(MySObject__c.SObjectType);
mocks.when(mockSelector.selectById(
                                            (Set<String>) fflib_Match.anyObject()
                                        ))
    .thenReturn((List<MySObject__c>) params.get(MockParams.RETURNED_MYSOBJECTS));
```
**NOTE**: Stubbing the SObjectType is ***REQUIRED*** here or the Mocking of the Selector **WILL** Fail

#### Stubbed Service Example:
```
mocks.when(mockCalloutService.makeCallout(
                                fflib_Match.anyString(),
                                fflib_Match.eqBoolean(true)
                            ))
    .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
```
#### Throw Exception Example
If you need to test the Catch Block on a Try-Catch, you can Stub the method to Throw an Exception whenever the method is called instead. You can include a Boolean in the MockSetup Class Constructor for ___throwErrors___ so that you can control which test methods need to test if the catching of Exceptions.
```
if(throwErrors){
    ((ICalloutService) mocks.doThrowWhen(new CalloutService.ServiceException('Thrown Exception'),
                                            mockCalloutService)).makeCallout(
                                                        fflib_Match.anyString(),
                                                        fflib_Match.anyBoolean()
                                                    );
}

```
[Back to Steps](#mocksetup-class) 

### 7. Replace Classes with Mocks when called from Application
Finally, we will set the Mocks so that whenever they are created using the [Application Class](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls), they will instead create and use our Mock Class.
This is why it is important that whenever we call these classes from our Methods, we do so using the [Application Layer](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls).
```
Application.UnitOfWork.setMock(uowMock);
Application.Domain.setMock(mockDomain);
Application.Selector.setMock(mockSelector);
Application.Service.setMock(ICalloutService.class, mockCalloutService);
```
[Back to Steps](#mocksetup-class) 

### 8. Final Product
When we put it all together it should look something like this:
```
//Step 1:
enum MockParams {
    RETURNED_MYSOBJECTS,
    RETURNED_MESSAGE
}

//Step 2:
static Map<MockParams, Type> paramTypes {
    get {
        return new Map<MockParams, Type>{
            MockParams.RETURNED_MYSOBJECTS => List<MySObject__c>.class,
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
        IMySObjectSelector mockSelector = (IMySObjectSelector) mocks.mock(MySObjectSelector.class);
        IMySObjectDomain mockDomain = (IMySObjectDomain) mocks.mock(MySObjectDomain.class)
        ICalloutService mockCalloutService = (ICalloutService) mocks.mock(CalloutService.class);

        mocks.startStubbing();

// Step 6:
        mocks.when(mockSelector.SObjectType()).thenReturn(MySObject__c.SObjectType);
        mocks.when(mockSelector.selectById(
                                                    (Set<String>) fflib_Match.anyObject()
                                                ))
            .thenReturn((List<MySObject__c>) params.get(MockParams.RETURNED_MYSOBJECTS));

        if(throwErrors){
            ((ICalloutService) mocks.doThrowWhen(new CalloutService.ServiceException('Thrown Exception'),
                                                    mockCalloutService)).makeCallout(
                                                                fflib_Match.anyString(),
                                                                fflib_Match.anyBoolean()
                                                            );
        } else {
            mocks.when(mockCalloutService.makeCallout(
                                            fflib_Match.anyString(),
                                            fflib_Match.eqBoolean(true)
                                        ))
                .thenReturn((String) params.get(MockParams.RETURNED_MESSAGE));
        }

        mocks.stopStubbing();

// Step 7:
        Application.UnitOfWork.setMock(uowMock);
        Application.Domain.setMock(mockDomain);
        Application.Selector.setMock(mockSelector);
        Application.Service.setMock(ICalloutService.class, mockCalloutService);
    }
}
```
[Back to Steps](#mocksetup-class) 

## Example in a Test Method
Now that we have our MockSetup Class built, here is how we would use it in a test method.

NOTE: We are using the [GIVEN-WHEN-THEN Style](https://martinfowler.com/bliki/GivenWhenThen.html) for Test methods

### Example Test Method Utilizing MockSetup
Notice that we are only setting the `RETURNED_MYSOBJECTS` in the Params as this is the only return value we would need in this test method.

Since we are not needing to perform any DMLs, can use ***`Mocks.Verify()`*** to validate that the records were commited to be updated in the mocked `UnitOfWork` ([More Mocks.Verify() Examples](/documentation/Mocks.Verify-Examples.md))
```
@IsTest
public static void givenInputParamters_WhenMethodNameIsCalled_ThenReturnExpectedMessage(){

    //Setup Test Data and Mocking
    MySObject__c testRecord = new MySObject__c(
                                        ID = fflib_IDGenerator.generate(MySObject__c.SObjectType),
                                        Name = 'My Object'
                                    );

    //Setup Return Values
    Map<MockParams, Object> params = new Map<MockParams, Object>{
        MockParams.RETURNED_MYSOBJECTS => new List<MySObject__c>{testRecord},
    };

    //Initialize MockSetup with Params without throwing errors
    MockSetup mock = new MockSetup(params, false);

    //Run Test
    Test.startTest();
    String result = ClassBeingTested.MethodBeingTested(testRecord.Id, '12345');
    Test.stopTest();

    //Validate Data
    Assert.areEqual('Success', result, 'Incorrect Message Recieved: '+ result);

     ((fflib_ISObjectUnitOfWork) mock.mocks.verify(mock.uowMock, 1))
            .registerDirty(fflib_Match.sobjectWith(
                new Map<Schema.SObjectField, Object>{
                    MySObject__c.ID => testRecord.ID,
                    MySObject__c.Name => testRecord.Name
                }
            ));
}
```
### Example Test Method Utilizing MockSetup Catching Exception
Notice that the Exception Message returned matches the Exception Message that was provided in our MockSetup Class when we mocked throwing the Exception.
```
@IsTest
public static void givenInputParamters_WhenMethodNameIsCalled_ThenCatchError(){

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
        String result = ClassBeingTested.MethodBeingTested(
                                        fflib_IDGenerator.generate(MySObject__c.SObjectType), 
                                        '12345'
                                    );
        Assert.isTrue(false, 'Error Not Thrown');
    } catch (Exception ex){
        errMsg = ex.getMessage();
    }
    Test.stopTest();

    //Validate Data
    Assert.areEqual('Thrown Exception', errMsg, 'Incorrect Message Recieved: '+ errMsg);
}
```
[Back to Steps](#mocksetup-class) 

