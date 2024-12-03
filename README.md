# FFLIB Working Examples

## Overview

This Repo Shows working examples of the FFLIB architechure design patterns using design patterns and best practices I have picked up over the years. This is an open source repo intended for my own personal use and to share with those that need it.

Already Included in the Metadata are the following Repos:
- [FFLIB Repo](https://github.com/apex-enterprise-patterns/fflib-apex-common)
- [FFLIB Mocks Repo](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) 
- [SObjectFabricator Repo](https://github.com/mattaddy/SObjectFabricator)

## Setup

1. Download Repository to Local Machine with VS Code (or similiar IDE)
   1. Ensure [latest Salesforce CLI is installed](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for `SF` Commands
1. Connect IDE to DevHub Enabled Org (Org Alias: DevHub)
1. Create Scratch Org from DevHub 
```
sf org create scratch -f config/project-scratch-def.json -a MyScratchOrg -d -v DevHub
```
4. Deploy all Metadata to Scratch Org
```
sf project deploy start -d force-app -o MyScratchOrg -c
```
5. Assign Permission Set to User
```
sf org assign permset -n BoardGamePS -o MyScratchOrg
```
6. Populate Data Using Plan
```
sf data import tree -p ./data/Import-plan.json
```

## Example Use Cases

For this example, I put together a small Application in Salesforce based on what I know best: Board Game Conventions. In this example, we will be using the following Use Cases:

### Mark as Favorite

As an Event Attendee, when I add a Board Game Rating that is Marked as Favorite, I would like all of the other Board Game Ratings marked as Favorite for that Attendee to be Unchecked.
If Multiple Board Game Ratings are added for Attendee where Favorite is Checked, Display Error to Attendee.

This Use Case shows examples for the following:
- Trigger using SObjectDomain as TriggerHandler
- Using Custom Metadata Types to Configure:
    - Trigger Handler
    - Serivce Methods
- FFLIB
    - Application Layer
    - Trigger Handler and Domain Layer
    - Service Layer
    - Selector Layer
    - Unit Of Work Layer
- Mock Setup Class
- Mocking and Stubbing FFLIB
- Use Case Unit Testing

### Import Board Game List from BoardGameGeek API

As an Event Owner, I would like a form to import my Collection or GeekList from BoardGameGeek and add new those new Board Games into the application. 
Any Board Games not already in the application I would like marked as 🆕 and for those games to automatically be added to the Board Game Library for the Event I selected. 
Upon follow up imports, I would like the option to update the existing Board Games information from BoardGameGeek and for the Board Game to no longer be marked as 🆕.

This Use Case shows examples for the following:
- LWC
     - Imports Apex Controller
     - Toast Messaging
     - Wire Connection
     - Promise Connection
     - Populate Combobox from Records
- REST API Callouts
     - HTTP Callout Setup
     - Parsing XML Results
- Wrapper Classes
- FFLIB
     - Application Layor
     - Service Layor
     - Selector Layor
     - Unit Of Work Layer
- Mocking and Stubbing FFLIB
     - [Mocks.Very() Examples](/force-app/main/default/classes/FFLIB/Services/README.md#mocksverify-example-quick-reference)
- Use Case Unit Testing
- Mock Http Callouts
     - Using Static Resources for XML Results

**To use Importer:** 
- Open Board Games App, 
- Click Board Game Importer Tab. 
- Select Default Event (My Event)
- Enter Collection Name or GeekList ID:
     - Collection Name Example: __AZ933K__[^1]
     - GeekList ID Example:     __347463__

[^1]: The first time a Collection is requested from BoardGameGeek after a long period of time, it will queued resulting in an error. If this happens just re-click submit and try again. 

### Check Out Board Game (TODO)

As an Event Attendee, I would like to click a button and automatically Check Out a Board Game from the Board Game Library.

### Check In Board Game (TODO)

As an Event Attendee, I would like to click a botton and automaitcally Check In the Board Game I have Checked Out

## More Information

[SObjects and Custom Metadata Types](/force-app/main/default/objects)

[FFLIB](/force-app/main/default/classes/FFLIB)
- [Application Layer](/force-app/main/default/classes/FFLIB/Application)
- [Domain Layer](/force-app/main/default/classes/FFLIB/Domains)
- [Selector Layer](/force-app/main/default/classes/FFLIB/Selectors)
- [Service Layer](/force-app/main/default/classes/FFLIB/Services)


