# `FFLIB` Working Examples

1. [Goal and Purpose of this Repo](#goal-and-purpose)
1. [Contents Overview](#contents-overview)
1. [What exactly IS `FFLIB`?](#fflib-explained-sort-of)

## GOAL AND PURPOSE

**FFLIB** is confusing for those working with it for the first time. As is sometimes the case, new developers are often thrown straight into the deep end and expected to understand why a simple seemingly straight-forward process like updating a field on a record after something else triggers it, for example, needs 6 different Apex Classes. 

Because of this, there are numerous articles, videos, and Salesforce Seminars dedicated to explaining WHY this architecture design style is useful however what I found is that specific examples and templates for how to implement these things is woefully lacking. 

So my goal here was simple: I needed to make one.

So admittedly, this was supposed to be a *simple* example of FFLIB for those to use as a referenece for how to setup and understand the complexities of this architecture, however, in typical *me* fasion, I just couldn't leave things well enough alone and kept adding cool features and functionality to the examples until I had added multiple use cases and complexities because, well, it was fun to do so. 

I have since dialed it back a bit and am attempting to **K.I.S.S.** (Keep it simple, stupid). 

This Repo holds working examples of how to use and implement **`FFLIB`** as well as examples of other patterns I picked up over my long career in Salesforce and have found useful. 

It is intended *mostly* for my own personal use to have templates to refer back to for future projects as well as to be shared with other developers that might find it useful.

[(Back to top)](#fflib-working-examples)

## CONTENTS OVERVIEW
There is a lot to unpack here. 

This Repo contains metadata for a working Salesforce Instance intended to be deployed as a Scratch Org or to a Developer Edition Environment. 

Included in this repo are also examples on how to do addtional things I normally need to look up like:
- Incorporating the Architechure Design Patterns (e.g. `fflib`, `at4dx`)
- [Setting up a Scratch Org](/documentation/Setup-Scratch-Org.md)
- [Creating Lightning Web Components](/documentation/LWC-Templates.md)
- [Creating Custom Property Editors for Screen Flow LWCs](/documentation/Custom-Property-Editors.md)
- [Creating REST API Callouts](/documentation/API-Connections.md)
- [Mocking HTTP Callouts](/documentation/API-Connections.md#mocking-http-response)
- [GIVEN-WHEN-THEN Style Test Classes (External Link)](https://martinfowler.com/bliki/GivenWhenThen.html) 
- [MockSetup Class](/documentation/MockSetup-Class) Example
- [Mocks.Verify](/documentation/Mocks.Verify-Examples.md) Examples
- [Invocable Methods and Variables](/force-app/main/default/classes/FFLIB%20Examples/Controllers/FlowUpdateBGLEFromBGGController.cls)

[You can find more information about the Example Use Cases Here](/documentation/Example-Use-Cases.md)

---
In the `sfdx-source` folder you will find three main folders: `default`, `dependancies`, and `fflib-working-examples`. 
- [`default`](sfdx-source\default): Placeholder for where new files pulled down from Salesforce will land and can be moved and sorted into the proper folder. Contents of this folder are ignored by git.
- [`dependancies`](sfdx-source\dependancies): Contains all the following forked repos used in this project:
     - [AT4DX](\sfdx-source\dependancies\at4dx)
     - [FFLIB Apex Common](sfdx-source\dependancies\fflib-apex-common)
     - [FFLIB Apex Mocks](sfdx-source\dependancies\fflib-apex-mocks) 
     - [Force DI](\sfdx-source\dependancies\force-di)
     - [SObjectFabricator](sfdx-source\dependancies\SObjectFabricator)
- [`fflib-working-examples`](fflib-working-examples): All metadata for our examples are stored. Folder structure can be found [HERE](\sfdx-source\fflib-working-examples\README.md).

[(Back to top)](#fflib-working-examples)

## `FFLIB` EXPLAINED... SORT OF
### WHAT IS `FFLIB`?
`FFLIB` is an open-sourced framework built for scalability, modularity and maintainability. It consists of four seperate modules: `fflib-apex-common`, `fflib-apex-mocks`, `a4dx`, and `force-di`. It uses four main parts or layers:
- `Implemenation Layer`: This layer referes to all of the different ways Apex can be called most common being Apex Controllers. Controllers would have minimal logic and leave the lion's share of the logic processing for the Service Layer
- `Domain Layer`: This layer handles not only SObject manipulation but also would act as the Trigger Handler keeping everything related to the SObject in one place.
- `Service Layer`: This is the meat and potatoes of where the business logic is housed. 
- `Selector Layer`: This layer holds all of the SOQL queries for an object.

### HOW DO I USE IT?
Included in this repository are [Steps to Setup a Scratch Org](/documentation/Example%20Scratch%20Org%20Setup.md) using the `fflib` example metadata I have created. The repo also includes submodules to my own forked repos for the different fflib repo modules (but this can easily be changed to point to the actual source for each).

I have also put together my own documentation for each layer that includes examples, templates, and setup steps on the "how" and little bit more of the "why" and their Seperation of Concerns:
- [Selector Layer](/documentation/FFLIB%20Selector%20Layer%20Setup.md)
- [Service Layer](/documentation/FFLIB%20Service%20Layer%20Setup.md)
- [Domain Layer](/documentation/FFLIB%20Domains%20Layer%20Setup.md)
- [Implementation Layer](/documentation/FFLIB%20Implementation%20Layer%20Setup.md) 

### WHY USE IT?
`FFLIB`, admittedly, is complex and some say over engineered. There are a lot of moving pieces and the juice might not seem worth the squeeze when creating a dozen classes for one simple trigger action. However, the power and value of this pattern lies in the re-usablity and compartmentalization of its parts.

If you have a basic, out-of-the-box Single Developer Organization, you might think this is not the best approach, and you might be completely right. While the "Why" of using this pattern can be better described by people smarter than me, the best reason I found seen is for larger (or even mid-size) organizations with multiple developers. As your org grows and becomes more and more complex, it will be more and more benificial for compartmentalizing and reusing code and classes especially if priorities pivot and something needs to be majorly restructured or redesigned. These design patterns will help ease some of those pains of having to re-do things. 

Including `AT4DX` allows use to migrate controls to Custom Metadata which means we can do things like add and remove fields from queries and have more control over individual triggered actions like enabling and disabling them all without having to change any Apex Code which means we can do it directly in production if needed. 

### WHO PUT ALL THIS TOGETHER?
I have gathered and collected as much information and understanding about `fflib` and the different aspects of it from different projects I have worked on over the years. Credit DEFINATLY where credit is due, people WA-A-A-A-Y smarter than me put all of this together and showed me the ropes. I just recreated what I learned and put it all together in one place. 

### WHERE CAN I FIND MORE INFORMATION?
All Apex Classes amd other Metadata are seperated into their own seperate folders ([see folder structure here](/sfdx-source/fflib-working-examples/README.md)) for ease of navigation.

- [fflib.dev](https://fflib.dev/docs): This is a really good source of information. It also has some basic examples for each of the layers and brief explinations of them as well.
- The official GitHub Repos for the seperate modules also have more details about each one and how they work:
    - [fflib-apex-common](https://github.com/apex-enterprise-patterns/fflib-apex-common)
    - [fflib-apex-mocks](https://github.com/apex-enterprise-patterns/fflib-apex-mocks)
    - [force-di](https://github.com/apex-enterprise-patterns/force-di)
    - [at4dx](https://github.com/apex-enterprise-patterns/at4dx)


[(Back to top)](#fflib-working-examples)

## FEEDBACK WANTED
Did I missed the mark on something? <br>
Do you still have questions about how to do something? <br>
Are the examples or comments not clear enough for what you are trying to do?

I consider this Example Repo as still a `Work In Progress` and would love to hear any feedback on what you think is still missing, what is not correct, what could be done better, or what could be done more efficiently. 

Please feel free to leave a comment in the [Discussions Tab](https://github.com/SRileyCoyote/FFLIB_Working_Examples/discussions). 

[(Back to top)](#fflib-working-examples)