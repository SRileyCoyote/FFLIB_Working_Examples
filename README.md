# FFLIB Working Examples

## Overview

This Repo Shows working examples of the FFLIB architechure design patterns using design patterns and best practices I have picked up over the years. This is an open source repo intended for my own personal use and to share with those that need it.

For this example, I put together a small Application in Salesforce based on what I know best: Board Game Conventions. In this example, we will be using the following Use Cases:
1. When Board Game Rating is Marked as Favorite, Uncheck Favorite on all other Board Game Reviews for that Attendee
1. Check Out Board Game: Create Check Out Record. (TODO)
1. Check In Board Game: Get Board Game Record For Game, Set Check In Time to Current Time. (TODO)



Already Included in the Metadata are the following Repos:
- [FFLIB Repo](https://github.com/apex-enterprise-patterns/fflib-apex-common)
- [FFLIB Mocks Repo](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) 
- [SObjectFabricator Repo](https://github.com/mattaddy/SObjectFabricator)

## Setup

1. Download Repository to Local Machine with VS Code (or similiar IDE)
   1. Ensure [latest Salesforce CLI is installed](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for `SF` Commands
1. Connect IDE to DevHub Enabled Org
1. Create Scratch Org from DevHub 
```
sf org create scratch -f config/project-scratch-def.json -a [MyScratchOrg] -d -v [DevHub]
```
4. Deploy all Metadata to Scratch Org
```
sf project deploy start -d force-app -o [MyScratchOrg] -c
```
5. Populate Data Using Plan
```
sf data import tree -p ./data/Import-plan.json
```
## More Information

[SOBjects and Custom Metadata Types](/force-app/main/default/objects/README.md)


## To Be Moved to their own READMEs
### Custom Objects

![Data Schema](/images/Schema.png)

- **Event** is a Board Game Convention with a __Start__ and __End Date__.
- **Event Attendee** is a Person Attending the Event with a __Name__ and __Email__.
- **Board Game** is a Board Game with various attributes.
- **Event Board Game** is a concat table for **Board Game** and **Event**
- **Board Game Rating** is a list of reviews of **Board Games** by **Event Attendees**
- **Board Game Checkout Log** is a log of when a **Board Game** is checked out by an **Event Attendee** at an **Event**

### Custom Metadata Types

We will use Custom Metadata Types to control certain aspects of the DOMAIN and SERVICE Layer

- **Domain Config**: This Custom MDT allows us to toggle if we want to Bypass Error Handling, Bypass Triggers, and/or Prevent Recursion on an Object's Trigger.
- **Services Config**: This Custom MDT allows us to toggle if a Method on the Service Class is to be enabled or not. Has a MetaData Relaionship to the Domain Config Record.



## Example Use Cases


## TODO Notes:

TODO:
ReadMe Files on the following Folders:
- FFLIB
- APPLICATION
- DOMAINS
   - TRIGGER TESTS
- SELECTORS
- SERVICES
- TEST UTIL
- FFLIB BASE CLASSES
   - APEX MOCKS
   - FFLIB_COMMON
   - SOBJECT_FABRICATOR
- CUSTOM METADATA
- OBJECTS (Update to Include MDT Descriptions)
- IMAGES
Add Descriptions to Objects and Fields
Links to Scratch Org Instructions
Links to Other ReadMe Files in Top ReadMe

How do I want to do this:
- Encorporate ZDF (Somehow?)

Examples I want to see:
- Domain
- Service
- Selectors
- Test Class
   - Example of SObjectFabricator
   - Example of non-SObjectFabricator Record
   - Mock Domain
   - Mock Selector
   - Mock UOW
     - Verify Individual Record
     - Verify List of Records
-Parent Classes

Use Cases To Add:
- Check out Game 
- Check in Game 

