# FFLIB Working Examples

### Reporistory Documentation Directory
1. [FFLIB Architechure](/documentation/FFLIB.md)
     - [Implementation Layer]()
          - [Controllers](/force-app/main/default/classes/FFLIB%20Examples/Controllers/README.md)
          - [Trigger Handlers](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/README.md)
     - [Service Layer](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md)
     - [Domain Layer](/force-app/main/default/classes/FFLIB%20Examples/Domains/README.md)
     - [Selector Layer](/force-app/main/default/classes/FFLIB%20Examples/Selectors/README.md)
1. [Schema](/force-app/main/default/objects/README.md)
1. [Custom Property Editors](/force-app/main/default/lwc/README.md)

### Templates
- [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/README.md#application-template)
- Implementation
     - [AuraEnabled](/force-app/main/default/classes/FFLIB%20Examples/Controllers/README.md#auraenabled-template)
     - [Invocable Method](/force-app/main/default/classes/FFLIB%20Examples/Controllers/README.md#invocableaction-template)
     - [Trigger](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/README.md)
     - [TriggerHandler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/README.md)
- [Domain Class](/force-app/main/default/classes/FFLIB%20Examples/Domains/README.md)
     - [Base Class](/force-app/main/default/classes/FFLIB%20Examples/Domains/BaseDomain.cls)
     - [Interface](/force-app/main/default/classes/FFLIB%20Examples/Domains/README.md)
     - [Initialize](/force-app/main/default/classes/FFLIB%20Examples/Domains/README.md)
- [Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md)
     - [Base Class](/force-app/main/default/classes/FFLIB%20Examples/Services/BaseService.cls)
     - [Interface](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md)
     - [Initialize](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md)
- [Selector Class](/force-app/main/default/classes/FFLIB%20Examples/Selectors/README.md)
     - [Interface](/force-app/main/default/classes/FFLIB%20Examples/Selectors/README.md)
     - [Initialize](/force-app/main/default/classes/FFLIB%20Examples/Selectors/README.md)
- Test Classes
     - [MockSetup Class](/documentation/MockSetup-Class#8-final-product)
     - [Controllers](/force-app/main/default/classes/FFLIB%20Examples/Controllers/README.md)
     - [Trigger](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/README.md)
     - [TriggerHandler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/README.md)
     - [Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains/README.md)
     - [Service](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md)
     - [Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/README.md)

## Overview

This Repo Shows working examples of the FFLIB architechure design patterns using design patterns and best practices I have picked up over the years. This is an open source repo intended for my own personal use and to share with those that need it. 

While the title ___IS___ "FFLIB Working Examples", included in this repo are also examples on how to do addtional things like I normally need to look up:
- [Setting up a Scratch Org](/documentation/Setup-Scratch-Org.md)
- Creating LWCs
- [Creating CPEs for Screen Flow LWCs](/force-app/main/default/lwc)
- Creating and Implementing Interfaces
- Extending Parent Classes
     - Difference between Abstract and Virtual Methods
     - Using the Protected Access Modifier
- Using Custom Metadata Types
- Creating REST API Callouts
- Mocking HTTP Callouts
- Given_When_Then Test Class Setup
- [MockSetup](/documentation/MockSetup-Class) Example
- [Mocks.Verify](/documentation/Mocks.Verify-Examples.md) Examples
- Wrapper Classes
- Custom Exceptions
- Invocable Methods and Variables

If this Repo, you will find:
- [Setup Instructions](/documentation/Setup-Scratch-Org.md) on how to create a Scratch Org and populate it with all of the metadata included for the org as well as some Example Test Data so that you can see how the examples work in a live environment.
- [Use Cases](/documentation/Example-Use-Cases.md) for all of the code provided in this Repository, which classes are utilized for that Use Case, as well as a brief overview of the coding method examples that are included in that Use Case.
- [Links for More Information](#links-for-more-information) about the Application Schema as well as each of the different FFLIB Layers, both official definitions as well as notes about my own understanding of how each Layer is works with each other.

Already Included in the Metadata are copies of the following Repos:
- [FFLIB Common](/force-app/main/default/classes/FFLIB%20Common%20Classes/FFLIB_COMMON)
- [FFLIB Mocks](/force-app/main/default/classes/FFLIB%20Common%20Classes/APEX_MOCKS) 
- [SObjectFabricator](/force-app/main/default/classes/FFLIB%20Common%20Classes/SOBJECT_FABRICATOR)

Did I missed the mark on something? <br>
Do you still have questions about how to do something? <br>
Are the examples or comments not clear enough for what you are trying to do?

I consider this Example Repo as still a Work In Progress and would love to hear any feedback on what you think is still missing, what is not correct, or could be done better or more efficiently. 

Please feel free to leave a comment in the [Discussions Tab](https://github.com/SRileyCoyote/FFLIB_Working_Examples/discussions). 

As an Event Owner, I would like to see a Dashboard showing: 
- Total number of Board Games for the Event 
- How many Board Games have been Checked Out
- How many Board Games are Currently Checked Out
     - How long they have been checked out for
     - If they have been checked out for longer than the average Duration for the Game
- Favorited Board Games
- Top 5 User Rated Board Games

[Back to Use Case Examples List](#example-use-cases) - [Back to Top](#fflib-working-examples)

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

