# TRIGGER HANDLER LAYER

## Overview

TriggerHandlers are part of the Implementation Layer and are where all Trigger-Specific Logic will be housed for each of the different types of Before and After Triggers. 

TriggerHandlers will initialize an FFLIB UnitOfWork Object and the [Service Classes](/force-app/main/default/classes/FFLIB%20Examples/Services) that will perform the actual logic for the trigger, passing the [Unit of Work Object]() into the Service Class as a Parameter. By Initializing the [Unit of Work]() here and performing and Commiting the records here, all DMLs (either Insert or Update) are performed at once at the END of the Trigger in a single DML Transaction in the Order indicated by the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)

The Benefit of this is that the trigger itself is free of logic and, by stubbing the [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services), Unit Tests for the TriggerHandler can then just focus on the logic for determining if the Trigger should Fire or not based on Settings of the Custom Metadata Type associated with the Trigger without the need for detailed test data. 

### Class
1. Create Trigger for SObject, Calling TriggerHandler.
1. Add Logic to use [Custom Metadata Type](/force-app/main/default/objects) to:
    1. Enable/Disable Trigger
    1. Prevent Recurrison
    1. Bypass Error Handling
1. Add Override Methods for the different Trigger Types Needed
    1. Call [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) to Handle logic
    1. Pass in [UnitOfWork]() Object to all Service Methods
    1. Commit Work on [UnitOfWork]() Object

### Test Class
1. Create Test Class for Trigger Handler
    1. Add Mocking & Stubbing for [Service](/force-app/main/default/classes/FFLIB%20Examples/Services) Class
    1. Create Unit Test Methods for TriggerHandler:
        1. Test Only Logic in TriggerHandler NOT Service Class
        2. Test Every Possible Scenario for TriggerHandler Configurations NOT Just Code Coverage
    1. Use Asserts or [Mocks.Verify() Methods](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md#mocksverify-example-quick-reference) to Validate Results
1. Create Test Class for Trigger [^1]
    
[^1]: Testing here will only be for coverage as all other logic will be tested in the other layers

## Trailhead and Resources

- [Official FFLIB Domain Layer Overview Definition](https://fflib.dev/docs/domain-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Domain Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer)
