# FFLIB Working Examples

## Overview

This Repo holds a working example of how to use and implement FFLIB as well as examples of other patterns I picked up over my long career in Salesforce. It is intended mostly for my own personal use to refer back to and use the [templates](/documentation/Template-Quick-Links.md) for future projects as well as to be shared to other developers that might find it useful.

## Contents

This Repo contains metadata for a working Salesforce Instance intended to be deployed as a Scratch Org or to a Developer Edition Environment. Included in this repo are also examples on how to do addtional things like I normally need to look up like:
- [Utilizing the FFLIB Architechure Design Patterns](/documentation/FFLIB.md)
- [Setting up a Scratch Org](/documentation/Setup-Scratch-Org.md)
- [Creating Lightning Web Components](/documentation/LWC-Templates.md)
- [Creating CPEs for Screen Flow LWCs](/documentation/Custom-Property-Editors.md)
- Creating and Implementing Interfaces
- Extending Parent Classes
     - Difference between Abstract and Virtual Methods
     - Using the Protected Access Modifier
- Using [Custom Metadata Types](/documentation/SObject-Schema.md#custom-metadata-types)
- [Creating REST API Callouts](/documentation/API-Connections.md)
- [Mocking HTTP Callouts](/documentation/API-Connections.md#mocking-http-response)
- [GIVEN-WHEN-THEN Style](https://martinfowler.com/bliki/GivenWhenThen.html) Test Classes
- [MockSetup Class](/documentation/MockSetup-Class) Example
- [Mocks.Verify](/documentation/Mocks.Verify-Examples.md) Examples
- [Invocable Methods and Variables](/force-app/main/default/classes/FFLIB%20Examples/Controllers/FlowUpdateBGLEFromBGGController.cls)

[You can find instructions to Setup the Scratch Org Here](/documentation/Setup-Scratch-Org.md)

[You can find more information about the Example Use Cases Here](/documentation/Example-Use-Cases.md)

Already Included in the Metadata are copies of the following Repos:
- [FFLIB Common](/force-app/main/default/classes/FFLIB%20Common%20Classes/FFLIB_COMMON)
- [FFLIB Mocks](/force-app/main/default/classes/FFLIB%20Common%20Classes/APEX_MOCKS) 
- [SObjectFabricator](/force-app/main/default/classes/FFLIB%20Common%20Classes/SOBJECT_FABRICATOR)

Did I missed the mark on something? <br>
Do you still have questions about how to do something? <br>
Are the examples or comments not clear enough for what you are trying to do?

I consider this Example Repo as still a Work In Progress and would love to hear any feedback on what you think is still missing, what is not correct, what could be done better, or what could be done more efficiently. 

Please feel free to leave a comment in the [Discussions Tab](https://github.com/SRileyCoyote/FFLIB_Working_Examples/discussions). 

## Links for More Information 

[SObjects and Custom Metadata Types](/documentation/SObject-Schema.md)

[FFLIB Examples](/force-app/main/default/classes/FFLIB%20Examples) - [Official Definitions](https://fflib.dev/docs)
- [Application Layer Examples](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Implementation Layer - [Official Definition](https://fflib.dev/docs/implementation-layer/overview)
     - [Apex Controller Examples](/force-app/main/default/classes/FFLIB%20Examples/Controllers)
     - [Trigger Handler Examples](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers)
- [Domain Layer Examples](/force-app/main/default/classes/FFLIB%20Examples/Domains)  - [Official Definition](https://fflib.dev/docs/domain-layer/overview)
- [Selector Layer Examples](/force-app/main/default/classes/FFLIB%20Examples/Selectors) - [Official Definition](https://fflib.dev/docs/selector-layer/overview)
- [Service Layer Examples](/force-app/main/default/classes/FFLIB%20Examples/Services) - [Official Definition](https://fflib.dev/docs/service-layer/overview)

- [Official FFLIB Sample Code GitHub Repo](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode)

[Deployment Order and Dependancy Troubleshooting](/force-app/main/default/classes/FFLIB%20Examples/README.md#deployment-order)

