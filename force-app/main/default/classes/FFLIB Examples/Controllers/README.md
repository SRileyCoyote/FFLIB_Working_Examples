# APEX CONTROLLERS

## Overview

Apex Controllers are part of the [Implementation Layer]() and a very common type of Apex class. Lightning Web Components, Aura Components, VisualForce Pages, and Flows that Invoke Apex Actions will call methods from Apex Controllers to perform server-side logic.

Apex Controllers will initialize an FFLIB UnitOfWork Object and the [Service Classes](/force-app/main/default/classes/FFLIB%20Examples/Services) that will perform the actual logic for the component, passing the [Unit of Work Object]() into the Service Class as a Parameter. By Initializing the [Unit of Work]() here and performing and Commiting the records at the end of the method, all DMLs (either Insert or Update) are performed at once at the END of the method in a single DML Transaction in the Order indicated by the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)

The Benefit of this is that the Controller itself is free of logic and, by stubbing the [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services), Unit Tests for the Apex Controller can then just focus on any logic specific to the Controller without the need for detailed test data.

### Class
1. Create Apex Controller.
1. For LWC and Aura Componenents, add @AuraEnabled Method
1. For Flow Actions, add @InvocableMethod Method and @InvocableVariable Variables
1. Add Logic to Methods
    1. Call [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) to Handle logic
    1. Pass in [UnitOfWork]() Object to all Service Methods
    1. Commit Work on [UnitOfWork]() Object

### Test Class
1. Create Test Class for Apex Controller
    1. Add Mocking & Stubbing for [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) Class
    1. Create Unit Test Methods for Apex Controller:
        1. Test Only Logic in Apex Controller NOT [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services)
        2. Test Every Possible Scenario for Apex Controller Configurations NOT Just Code Coverage
    1. Use Asserts or [Mocks.Verify() Methods](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md#mocksverify-example-quick-reference) to Validate Results
    
## Trailhead and Resources

- [Official FFLIB Implementation Layer Overview Definition](https://fflib.dev/docs/implementation-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
