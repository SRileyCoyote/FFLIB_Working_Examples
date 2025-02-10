# APEX CONTROLLERS

## Overview

Apex Controllers are part of the [Implementation Layer]() and a very common type of Apex class. Lightning Web Components, Aura Components, VisualForce Pages, and Flows that Invoke Apex Actions will call methods from Apex Controllers to perform server-side logic.

Apex Controllers will initialize an FFLIB UnitOfWork Object and the [Service Classes](/force-app/main/default/classes/FFLIB%20Examples/Services) that will perform the actual logic for the component, passing the [Unit of Work Object]() into the Service Class as a Parameter. By Initializing the [Unit of Work]() here and performing and Commiting the records at the end of the method, all DMLs (either Insert or Update) are performed at once at the END of the method in a single DML Transaction in the Order indicated by the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)

The Benefit of this is that the Controller itself is free of logic and, by stubbing the [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services), Unit Tests for the Apex Controller can then just focus on any logic specific to the Controller without the need for detailed test data.

### Class
1. Create Apex Controller.
1. For LWC and Aura Componenents, add `@AuraEnabled` Method
1. For Flow Actions, add `@InvocableMethod` Method and `@InvocableVariable` Variables
1. Add Logic to Methods
    1. Call [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) to Handle logic
    1. Pass in [UnitOfWork]() Object to all Service Methods
    1. Commit Work on [UnitOfWork]() Object

#### AuraEnabled Template
**NOTE**: Regardless of the message given, the message on the AuraHandledException is "Script-thrown exception". Setting the message as indicated below passes along the correct message recieved when testing.

```
@AuraEnabled
public static String myAuraEnabledMethod(ID recordId){
    
    AuraHandledException auraEx = new AuraHandledException('Message');
    fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
    MySObjectService service = (MySObjectService) MySObjectService.newInstance();
            
    try {
        //Do Work
        List<MySObject> results = service.myServiceMethod(uow, recordId);
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
#### InvocableAction Template
**NOTE**: Only One Invocable Method Per Class 
```
@InvocableMethod(label='My Invocable Action' description='This is My Invocable Action' category='My Actions')
public static List<String> myInvocableAction(List<InputWrapper> inputs){
    
    fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) Application.UnitOfWork.newInstance();
    MySObjectService service = (MySObjectService) MySObjectService.newInstance();

    String resultMsg;

    //Convert Input Values into List
    List<String> recordIds = new List<String>();

    for(InputWrapper input : inputs){
        recordIds.add(input.recordId);
    }   
    
    try {
        //Do Work
        resultMsg = service.myServiceMethod(uow, recordIds);
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

### Test Class
1. Create Test Class for Apex Controller
    1. Add Mocking & Stubbing for [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) Class
    1. Create Unit Test Methods for Apex Controller:
        1. Test Only Logic in Apex Controller NOT [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services)
        2. Test Every Possible Scenario for Apex Controller Configurations NOT Just Code Coverage
    1. Use Asserts or [Mocks.Verify() Methods](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md#mocksverify-example-quick-reference) to Validate Results
    
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

## Trailhead and Resources

- [Official FFLIB Implementation Layer Overview Definition](https://fflib.dev/docs/implementation-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
