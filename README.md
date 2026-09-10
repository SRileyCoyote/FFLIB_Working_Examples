# FFLIB Working Examples

## GOAL AND PURPOSE

**FFLIB** is confusing for those working with it for the first time. As is sometimes the case, new developers are often thrown straight into the deep end and expected to understand why a simple seemingly straight-forward process like updating a field on a record after something else triggers it, for example, needs 6 different Apex Classes. 

Because of this, there are numerous articles, videos, and Salesforce Seminars dedicated to explaining WHY this architecture design style is useful however what I found is that specific examples and templates for how to implement these things is woefully lacking. 

So my goal here was simple: I needed to make one.

So admittedly, this was supposed to be a *simple* example of FFLIB for those to use as a referenece for how to setup and understand the complexities of this architecture, however, in typical *me* fasion, I just couldn't leave things well enough alone and kept adding cool features and functionality to the examples until I had added multiple use cases and complexities because, well, it was fun to do so. 

I have since dialed it back a bit and am attempting to **K.I.S.S.** (Keep it simple, stupid). 

This Repo holds working examples of how to use and implement not just **FFLIB**, but **AT4DX**, **FORCE DI**, and **SOBJECT FABRICATOR** as well as examples of other patterns I picked up over my long career in Salesforce. 

It is intended *mostly* for my own personal use to have [templates](/documentation/Template-Quick-Links.md) to refere back to for future projects as well as to be shared to other developers that might find it useful.

Even though this project has since expanded to incoporate other repos like those mentioned above, the name: **FFLIB Working Examples** will need to remain the same for now for simplicity.

### To Do:
- Better Definition of Domains
- Include Selector Example of calling selecort for related fields

## CONTENTS OVERVIEW

There is a lot to unpack here. 

This Repo contains metadata for a working Salesforce Instance intended to be deployed as a Scratch Org or to a Developer Edition Environment. 
Included in this repo are also examples on how to do addtional things like I normally need to look up like:
- [Incorporating the FFLIB and AT4DX Architechure Design Patterns](/documentation/FFLIB.md)
- [Setting up a Scratch Org](/documentation/Setup-Scratch-Org.md)
- [Creating Lightning Web Components](/documentation/LWC-Templates.md)
- [Creating Custom Property Editors for Screen Flow LWCs](/documentation/Custom-Property-Editors.md)
- Creating and Implementing Interfaces
- Extending Parent Classes
     - Difference between Abstract and Virtual Methods
     - Using the Protected Access Modifier
- Using [Custom Metadata Types](/documentation/SObject-Schema.md#custom-metadata-types)
- [Creating REST API Callouts](/documentation/API-Connections.md)
- [Mocking HTTP Callouts](/documentation/API-Connections.md#mocking-http-response)
- [GIVEN-WHEN-THEN Style Test Classes](https://martinfowler.com/bliki/GivenWhenThen.html) 
- [MockSetup Class](/documentation/MockSetup-Class) Example
- [Mocks.Verify](/documentation/Mocks.Verify-Examples.md) Examples
- [Invocable Methods and Variables](/force-app/main/default/classes/FFLIB%20Examples/Controllers/FlowUpdateBGLEFromBGGController.cls)

[You can find instructions to Setup the Scratch Org Here](/documentation/Setup-Scratch-Org.md)

[You can find more information about the Example Use Cases Here](/documentation/Example-Use-Cases.md)

In the `sfdx-source` folder you will find three main folders: `default`, `fflib-working-examples`, and `dependancies`.

---
The `dependancies` folder contains the following repos:
- [AT4DX](\sfdx-source\dependancies\at4dx)
- [FFLIB Apex Common](sfdx-source\dependancies\fflib-apex-common)
- [FFLIB Apex Mocks](sfdx-source\dependancies\fflib-apex-mocks) 
- [Force DI](\sfdx-source\dependancies\force-di)
- [SObjectFabricator](sfdx-source\dependancies\SObjectFabricator)

I have created a fork off each of the respective repos add them to our project using the `.gitmodules` file. This way intellisense should have access to all of our sourced fflib files which will allow us to be able to use the *Go To Definition* Menu option in VS Code. 

These are all pointing to my own forked copies so that I can make sure my code works with the committed versions that I have.

---
Did I missed the mark on something? <br>
Do you still have questions about how to do something? <br>
Are the examples or comments not clear enough for what you are trying to do?

I consider this Example Repo as still a Work In Progress and would love to hear any feedback on what you think is still missing, what is not correct, what could be done better, or what could be done more efficiently. 

Please feel free to leave a comment in the [Discussions Tab](https://github.com/SRileyCoyote/FFLIB_Working_Examples/discussions). 

## LINKS FOR MORE INFORMATION 

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

