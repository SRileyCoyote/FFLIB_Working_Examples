# IMPLEMENTATION LAYER SETUP

## Overview

Apex Controllers are part of the **Implementation Layer** and a very common type of Apex class. Lightning Web Components, Aura Components, VisualForce Pages, and Flows that Invoke Apex Actions will call methods from Apex Controllers to perform server-side logic.

Apex Controllers will initialize an **FFLIB UnitOfWork** Object and the [Service Classes]() that will perform the actual logic for the component, passing the [Unit of Work]() Object into the [Service Classes]() as a Parameter. By Initializing the [Unit of Work]() here and performing and Commiting the records at the end of the method, all DMLs (either Insert or Update) are performed at once at the END of the method in a single DML Transaction in the Order indicated by the *Binding Sequence* Value on the  **Application Factory Unit of Work** Custom Metadata Type Record

The Benefit of this is that the Controller itself is mostly free of logic and, by stubbing the [Service Class](), Unit Tests for the Apex Controller can then just focus on any logic specific to the Controller without the need for detailed test data.

---
## How to Create an Apex Controller using `fflib` and `at4dx`
1. Create Apex Controller.
    1. For LWC and Aura Componenents, Create `@AuraEnabled` Method
    1. For Flow Actions, Create `@InvocableMethod` Method and `@InvocableVariable` Inputs
1. Add Logic to Methods
    1. Call [Service]() to Handle logic
    1. Pass in [UnitOfWork]() Object to all Service Methods
    1. Commit Work on [UnitOfWork]() Object
1. Create Test Class for Controller

---
### AuraEnabled Methods
---
**NOTE**: Regardless of the message given, the message on the AuraHandledException is "Script-thrown exception". Setting the message as indicated below passes along the correct message recieved when testing.

**NOTE**: If making SOQL call to return list of records, set cachable to TRUE. Otherwise, if making DML transactions in the method, cachable should be FALSE (Omitting the Cachable variable Defaults it to FALSE)

#### AuraEnabled Template

```
@AuraEnabled(cachable=false) 
public static String myAuraEnabledMethod(ID recordId){
    
    AuraHandledException auraEx = new AuraHandledException('Message');
    ApplicationSObjectUnitOfWork uow = (ApplicationSObjectUnitOfWork) Application.UnitOfWork.newInstance();
    MySObjectService service = (MySObjectService) Application.UnitOfWork.newInstance(IMySObjectService.class);
            
    try {
        //Do Work
        List<MySObject> results = service.myServiceMethodExample(uow, recordId);
        uow.commitWork();
        if (results.isEmpty()) {
            auraEx.setMessage('No Records found.');
            throw auraEx;
        }
        return results;
    } catch (Exception e) {
        System.debug('Error Thrown in Controller', e);
        auraEx.setMessage(e.getMessage());
        throw auraEx;
    }
}
```
[(Back to Top)](#apex-controllers)

---
### InvocableMethod Methods
---
**NOTE**: Unlike Aura Enabled Methods, Only One Invocable Method Allowed Per Class 

**NOTE**: InvocableMethods can only accept a single list of inputs and return a single list of outputs. If more than one Inout (or more than one Output) needs to be used, use a Wrapper Class using InvocableVarables (as seen below).

#### InvocableMethod and InvocableVariable Templates
```
@InvocableMethod(label='My Invocable Action' description='This is My Invocable Action' category='My Actions')
public static List<String> myInvocableAction(List<InputWrapper> inputs){
    
    ApplicationSObjectUnitOfWork uow = (ApplicationSObjectUnitOfWork) Application.UnitOfWork.newInstance();
    MySObjectService service = (MySObjectService) Application.Service.newInstance(IMySObjectService.class);

    String resultMsg;

    //Convert Input Values into List
    List<String> recordIds = new List<String>();

    for(InputWrapper input : inputs){
        recordIds.add(input.recordId);
    }   
    
    try {
        //Do Work
        resultMsg = service.myServiceMethodExample(uow, recordIds);
        uow.commitWork();
    } catch (Exception e) {
        System.debug('Error Thrown in Controller', e);
        throw new FlowException(e.getMessage());
    }

    return new List<String>{resultMsg};
}

public class InputWrapper {
    @InvocableVariable(required=true label='Record Id')
    //Add Additional Inputs Here
    public String recordId;
}
```
[(Back to Top)](#apex-controllers)

---
### Test Class
---
1. Create Test Class for Apex Controller
    1. Add Mocking & Stubbing for [Service]() Class
    1. Create Unit Test Methods for Apex Controller:
        1. Test Only Logic in Apex Controller NOT [Service Class]()
        2. Test Every Possible Scenario for Apex Controller Configurations NOT Just Code Coverage
    1. Use Asserts or [Mocks.Verify() Methods](/documentation/Mocks.Verify-Examples.md) to Validate Results
    
#### Test Class Template
**NOTE**: [MockSetup Class Template](/documentation/MockSetup-Class#8-final-product)
```
@isTest
public class myControllerTest {
    //#region MockSetup
    // MockSetup Class Template Goes Here
    //#endregion

    //Test Plan
    // List of Unit Tests Go Here

    //Start Testing
    //#region /////////////////// Method Name ///////////////////////////////
    //Method Tests Go Here
    //#endregion
}
```
[(Back to Top)](#apex-controllers)
