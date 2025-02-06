# FFLIB Working Examples

### Reporistory Documentation Directory
1. [FFLIB Architechure](/force-app/main/default/classes/FFLIB%20Examples/README.md)
     - [Implementation Layer]()
          - [Controllers](/force-app/main/default/classes/FFLIB%20Examples/Controllers/README.md)
          - [Trigger Handlers](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/README.md)
     - [Service Layer](/force-app/main/default/classes/FFLIB%20Examples/Services/README.md)
     - [Domain Layer](/force-app/main/default/classes/FFLIB%20Examples/Domains/README.md)
     - [Selector Layer](/force-app/main/default/classes/FFLIB%20Examples/Selectors/README.md)
1. [Schema](/force-app/main/default/objects/README.md)
1. [Custom Property Editors](/force-app/main/default/lwc/README.md)

## Overview

This Repo Shows working examples of the FFLIB architechure design patterns using design patterns and best practices I have picked up over the years. This is an open source repo intended for my own personal use and to share with those that need it. 

While the title ___IS___ "FFLIB Working Examples", included in this repo are also examples on how to do addtional things like I normally need to look up:
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
- [MockSetup](/force-app/main/default/classes/FFLIB%20Examples/README.md#mock-setup-class) Example
- [Mocks.Verify](/force-app/main/default/classes/FFLIB%20Examples/README.md#mocksverify-example-quick-reference) Examples
- Wrapper Classes
- Custom Exceptions
- Invocable Methods and Variables

Below you will find:
- [Setup Instructions](#scratch-org-setup-instructions) on how to create a Scratch Org and populate it with all of the metadata included for the org as well as some Example Test Data so that you can see how the examples work in a live environment.
- [Use Cases](#example-use-cases) for all of the code provided in this Repository, which classes are utilized for that Use Case, as well as a brief overview of the coding method examples that are included in that Use Case.
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

## Scratch Org Setup Instructions

1. Download Repository to Local Machine with VS Code (or similiar IDE)
   1. Ensure [latest Salesforce CLI is installed](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for `SF` Commands
1. Connect IDE to DevHub Enabled Org (Org Alias: DevHub)
1. Create Scratch Org from DevHub for 30 Days
```
sf org create scratch -f config/project-scratch-def.json -a MyScratchOrg -d -v DevHub -y 30
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

For this example, I put together an Application in Salesforce based on what I know best: Board Games and Board Game Conventions.

[Apex Classes](/force-app/main/default/classes/FFLIB%20Examples) are all sorted and organized in seperate folders based on the their respective layers. 

In this example, we will be using the following Use Cases:
1. [Mark Board Game as Favorite](#1-mark-as-board-game-as-favorite)
1. [Import Board Game List from BoardGameGeek API](#2-import-board-game-list-from-boardgamegeek-api)
1. [Update Individual Board Game Information from BoardGameGeek API](#3-update-individual-board-game-information-from-boardgamegeek-api)
1. [Check Out/In Board Game](#4-check-outin-board-game)
1. [Home Board Game Dashboard (WIP)](#6-home-board-game-dashboard-wip)

### 1. Mark as Board Game as Favorite

As an Event Attendee, when I add a Board Game Rating that is Marked as Favorite, I would like all of the other Board Game Ratings marked as Favorite for that Attendee to be Unchecked.
If Multiple Board Game Ratings are added for Attendee where Favorite is Checked, Display Error to Attendee.

We will use the following to implement this Use Case: 
- Create [Trigger](/force-app/main/default/triggers/BoardGameRatingsTrigger.trigger) using SObjectDomain as TriggerHandler
     - Which Calls Created [Trigger Handler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/BoardGameRatingsTriggerHandler.cls) extending [Base Trigger Handler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/BaseTriggerHandler.cls) overriding After Insert and After Update
          - Which Uses Created [Custom MDT](/force-app/main/default/customMetadata/Domain_Config.BoardGameRatings.md-meta.xml) to Enable and Disable Trigger
          - And Calls Created [Board Game Rating Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGameRatingsService.cls) extending [Base Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BaseService.cls) and implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Services/Interfaces/IBoardGameRatingsService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
               - Which Uses Created [Custom MDT](/force-app/main/default/customMetadata/Services_Config.setNewFavorite.md-meta.xml) to Enable and Disable Features
               - And Calls Created [Board Game Rating Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BoardGameRatingSelector.cls) and implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Interfaces/IBoardGameRatingSelector.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
               - And Created [Board Game Rating Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains/BoardGameRatingsDomain.cls) extending [Base Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains/BaseDomain.cls) and implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Domains/Interfaces/IBoardGameRatingsDomain.cls) which extends [Base Interface](/force-app/main/default/classes/FFLIB%20Examples/Domains/Interfaces/IBaseDomain.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
- Test Classes
     - Create [Trigger Test Class](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/Tests/Trigger%20Tests/BoardGameRatingTriggerTest.cls)
     - Create [Trigger Handler Test Class](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/Tests/BoardGameRatingsTriggerHandlerTest.cls) mocks [Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGameRatingsService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [Service Test Class](/force-app/main/default/classes/FFLIB%20Examples/Services/Tests/BoardGameRatingsServiceTest.cls) mocks [Domain](/force-app/main/default/classes/FFLIB%20Examples/Domains/BoardGameRatingsDomain.cls) and [Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BoardGameRatingSelector.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [Domain Test Class](/force-app/main/default/classes/FFLIB%20Examples/Domains/Tests/BoardGameRatingsDomainTest.cls) 
     - Create [Base Domain Test Class](/force-app/main/default/classes/FFLIB%20Examples/Domains/Tests/BaseDomainTest.cls)
     - Create [Selector Test Class](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Tests/BoardGameRatingSelectorTest.cls)

This Use Case shows examples for the following:
- Trigger using SObjectDomain as TriggerHandler
- Using Custom Metadata Types to Configure:
    - Trigger Handler
    - Serivce Methods
- Implementing Interfaces
- Extending Base Parent Class
     - Overriding Abstract and Virtual Methods
     - Using Protected Access Modifier
- FFLIB
    - Application Layer
    - Trigger Handler 
    - Domain Layer
    - Service Layer
    - Selector Layer
    - Unit Of Work Layer
- Testing
     - Mocking and Stubbing FFLIB Classes
          - Using [MockSetup Class](/force-app/main/default/classes/FFLIB%20Examples/README.md#mock-setup-class)
          - Validate Using [Mocks.Verify](/force-app/main/default/classes/FFLIB%20Examples/README.md#mocksverify-example-quick-reference)
     - Use Case Unit Testing


[Back to Use Case Examples List](#example-use-cases) - [Back to Top](#fflib-working-examples)

### 2. Import Board Game List from BoardGameGeek API

As an Event Owner, I would like a form to import my Collection or GeekList from BoardGameGeek and add new those new Board Games into the application. 
Any Board Games not already in the application I would like marked as 🆕 and for those games to automatically be added to the Board Game Library for the Event I selected. 
Upon follow up imports, I would like the option to update the existing Board Games information as well as the Board Game Library Entry from BoardGameGeek and for the Board Game to no longer be marked as 🆕.

TODO:
```
- When Importer Runs, Add Library Entries to Event if not found when Update NOT Selected
- Update Success Message to include number of Library entries created
- Add Button Remove Collection From Event That Deletes BGLE for that Collection for the Event
- Remove Game From Library When Removed From Collection or GeekList
- If Collection Not Found, Return Error.
```

We will use the following to implement this Use Case:
- Create [Lightning Web Component](/force-app/main/default/lwc/boardGameImporter/boardGameImporter.js)
     - Which Calls Created [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers/BoardGameImporterController.cls)
          - Which Calls Created [Event Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/EventSelector.cls) implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Interfaces/IEventSelector.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
          - And Calls Created [Board Game Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGamesService.cls) extending [Base Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BaseService.cls) implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Services/Interfaces/IBoardGamesService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
               - Which Uses Created [Custom MDT](/force-app/main/default/customMetadata/Services_Config.getBoardGameDetailsFromBGG.md-meta.xml) to Enable and Disable Features
               - And Calls Created [Board Game Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BoardGameSelector.cls) implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Interfaces/IBoardGameSelector.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
               - And Calls Created [Board Game Library Entry Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BGLibraryEntrySelector.cls) implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Interfaces/IBGLibraryEntrySelector.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
               - As Well As Created [BoardGameGeek Callout Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGGCalloutService.cls) implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Services/Interfaces/IBGGCalloutService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     
- Test Classes
     - Create [Apex Controller Test Class](/force-app/main/default/classes/FFLIB%20Examples/Controllers/Tests/BoardGameImporterControllerTest.cls) mocks [Board Game Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGamesService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [Board Game Service Test Class](/force-app/main/default/classes/FFLIB%20Examples/Services/Tests/BoardGamesServiceTest.cls) mocks [BGG Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGGCalloutService.cls), [Board Game Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BoardGameSelector.cls), and [BGLE Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BGLibraryEntrySelector.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [Board Game Selector Test Class](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Tests/BoardGameSelectorTest.cls)
     - Create [Board Game Library Entry Selector Test Class](/force-app/main/default/classes/FFLIB%20Examples/Selectors/Tests/BGLibraryEntrySelectorTest.cls)
     - Create [BoardGameGeek Callout Service Test Class](/force-app/main/default/classes/FFLIB%20Examples/Services/Tests/BGGCalloutServiceTest.cls) which mocks the HTTP Callout


This Use Case shows examples for the following:
- LWC
     - Import Apex Controller
     - Toast Messaging
     - Wire Connection
     - Promise Connection
     - Populate Combobox from Records
- REST API Callouts
     - HTTP Callout Setup
     - Parsing XML Results
- Wrapper Classes
- Implementing Interfaces
- Extending Base Parent Classes
     - Overriding Abstract and Virtual Methods
     - Using Protected Access Modifier
- FFLIB
     - Application Layor
     - Implementation Layer (APEX Controller)
     - Service Layor
     - Selector Layor
     - Unit Of Work Layer
- Testing
     - Mocking and Stubbing FFLIB Classes
          - Using [MockSetup Class](/force-app/main/default/classes/FFLIB%20Examples/README.md#mock-setup-class)
          - Validate Using [Mocks.Verify](/force-app/main/default/classes/FFLIB%20Examples/README.md#mocksverify-example-quick-reference)
     - Use Case Unit Testing
     - Mock Http Callouts
          - Using Static Resources for XML Results

**To use Importer:** 
- Open App Launcher
- Move Board Games App to Top of List (Optional)
- Open Board Games App
- Click Board Game Importer Tab
- Select Event
- Enter Collection Name[^1] or GeekList ID:
     - Collection Name Example: AZ933K
     - GeekList ID Example:     347463

[^1]: NOTE: The first time a Collection is requested from BoardGameGeek after a long period of time, it will be queued resulting in an error. If this happens just re-click submit and try again. 

[Back to Use Case Examples List](#example-use-cases) - [Back to Top](#fflib-working-examples)

### 3. Update Individual Board Game Information from BoardGameGeek API

As an Event Owner, I would like to be able to click on a button to update individual board game's information from BoardGameGeek. I would like to be able to do this from the Board Game Record as well as the Board Game Library Entry Record, the latter of which would also update the Comments for the Entry. I would also like to be able to do this from the List View[^2] for each of these Objects and be able to Select Multiple Records to be Updated at once.

[^2]: LWC Headless Actions are not currently Available for List View Buttons. Attempted several workarounds using URL buttons linking to Aura, Flow, VF Pages to show the results in a pop-up modal with little to no success. Settled on just using a Flow with an Invocable Action that opens in a new Screen and redirects back to the List View When Done.

We will use the following to implement this Use Case:
- Two Headless Lightning Web Components
     - Create One for [Board Game](/force-app/main/default/lwc/updateGameFromBGG/updateGameFromBGG.js)
          - Which Calls Created [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers/UpdateFromBGGController.cls)
               - And Calls Updated [Board Game Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGamesService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
                    - Which Uses Created [Custom MDT](/force-app/main/default/customMetadata/Services_Config.updateBoardGameDetailsFromBGG.md-meta.xml) to Enable and Disable Features
                    - Which Calls Updated [BoardGameGeek Callout Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGGCalloutService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create One for [Board Game Library Entry](/force-app/main/default/lwc/updateCollectionFromBGG/updateCollectionFromBGG.js)
          - Which Calls Same [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers/UpdateFromBGGController.cls)
               - Which Calls Created [BGLE Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGLibraryEntryService.cls) extending [Base Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BaseService.cls) implementing [Interface](/force-app/main/default/classes/FFLIB%20Examples/Services/Interfaces/IBGLibraryEntryService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
                    - Which Uses Created [Custom MDT](/force-app/main/default/customMetadata/Services_Config.updateBGLibraryEntryFromBGG.md-meta.xml) to Enable and Disable Features
                    - Which Calls Updated [BoardGameGeek Callout Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGGCalloutService.cls) and is Instantiated through [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
- And Two Flows
     - Create One for [Board Game](/force-app/main/default/flows/UpdateRecordFromBGG.flow-meta.xml)
          - Which Calls Created [Invocable Action](/force-app/main/default/classes/FFLIB%20Examples/Controllers/FlowUpdateBoardGameFromBGGController.cls)
               - Which Reuses Same Method in [Board Game Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGamesService.cls) as LWC
     - One for [Board Game Library Entry](/force-app/main/default/flows/UpdateBGLEFromBGG.flow-meta.xml)
          - Which Calls Created [Invocable Action](/force-app/main/default/classes/FFLIB%20Examples/Controllers/FlowUpdateBGLEFromBGGController.cls)
               - Which Reuses Same Method in [BGLE Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGLibraryEntryService.cls) as LWC
- Test Classes
     - Create [Apex Controller Test Class](/force-app/main/default/classes/FFLIB%20Examples/Controllers/Tests/UpdateFromBGGControllerTest.cls) which mocks [Board Game Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGamesService.cls) and [BGLE Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGLibraryEntryService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [Board Game Invocable Action Test Class](/force-app/main/default/classes/FFLIB%20Examples/Controllers/Tests/FlowUpdateBoardGameFromBGGControllerTest.cls) which mocks [Board Game Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BoardGamesService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [BGLE Invocable Action Test Class](/force-app/main/default/classes/FFLIB%20Examples/Controllers/Tests/FlowUpdateBGLEFromBGGControllerTest.cls) which mocks [BGLE Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGLibraryEntryService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Update [Board Game Service Test Class](/force-app/main/default/classes/FFLIB%20Examples/Services/Tests/BoardGamesServiceTest.cls) which mocks [BoardGameGeek Callout Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGGCalloutService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Create [BGLE Service Test Class](/force-app/main/default/classes/FFLIB%20Examples/Services/Tests/BGLibraryEntryServiceTest.cls) which mocks [BoardGameGeek Callout Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGGCalloutService.cls) when called by [Application](/force-app/main/default/classes/FFLIB%20Examples/Application/Application.cls)
     - Update [BoardGameGeek Callout Service Test Class](/force-app/main/default/classes/FFLIB%20Examples/Services/Tests/BGGCalloutServiceTest.cls) which mocks the HTTP Callout
 
This Use Case shows examples for the following:
- LWC
     - Headless LWC
     - Import Apex Controller
     - Toast Messaging
     - Wire Connection to Standard getRecord
     - Promise Connection to Apex Controller
- Expanding on Exisiting Code Base
     - Adding to BGGCalloutService
          - Reusing/Modifying Existing Methods
     - Adding to BoardGameService
     - Adding to Interfaces
     - Adding to Test Classes
- Screen Flow
     - Invocable Action
     - Invocable Variables
- FFLIB
     - Application Layer
     - Implementation Layer (APEX Controller)
     - Service Layer
     - Unit Of Work Layer
- Testing
     - Mocking and Stubbing FFLIB Classes
          - Using [MockSetup Class](/force-app/main/default/classes/FFLIB%20Examples/README.md#mock-setup-class)
          - Validate Using [Mocks.Verify](/force-app/main/default/classes/FFLIB%20Examples/README.md#mocksverify-example-quick-reference)
     - Use Case Unit Testing
     - Mock Http Callouts
          - Generate Ad Hoc XML Results

[Back to Use Case Examples List](#example-use-cases) - [Back to Top](#fflib-working-examples)

### 4. Check Out/In Board Game

As an Event Runner, I would like to click a button and automatically Check Out a Board Game from the Board Game Library. I would like this option to only be available if there is a copy of the Board Game Available to Check Out. If a Copy of the Board is already checked out, I would also like to see a Button to Check the Board Game In. 
I would like this functionality to be available throughout the app and available on any record page that displays a board game (i.e. Board Games, Library Entries, Check Out Logs, Ratings, etc.)

In order to accomplish this, we will create a Flow for each SObject Type that will support the functionaility. On each Flow, we will add a Lightning Web Component that can be added to a Flow Screen and will accept Input Properties so that the LWC Component will be configurable and resuable across all of the SObject Flows. We will also utilize a [Custom Property Editor (CPE)](/force-app/main/default/lwc/README.md#what-are-cpes) LWC on the Flow Screens for a cleaner UI for entering the inputs for the LWC on the Screen Flow.  

We will use the following to implement this Use Case:

- Create Screen Flow for Each SObject
     - Which has a Screen with a [Parent Container Component](/force-app/main/default/lwc/checkOutLogContainer)
          - Which calls the [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers/checkOutLogController.cls)
               - Which calls the correct Selector based on SObject Type:
                    - [Board Game Library Entry Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BGLibraryEntrySelector.cls)
                    - [Check Out Log Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BGCheckOutLogSelector.cls)
                    - [Board Game Rating Selector](/force-app/main/default/classes/FFLIB%20Examples/Selectors/BoardGameRatingSelector.cls)
          - Which will include a [Check Out Button Child Component](/force-app/main/default/lwc/checkOutGame)
               - Which calls the [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers/checkOutLogController.cls)
                    - Which calls to [Check Out Log Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services/BGCheckOutLogService.cls) to Create the Check Out Log 
          - And also includes a [Check In Button Child Component](/force-app/main/default/lwc/checkInGame)
               - Which calls the [Apex Controller](/force-app/main/default/classes/FFLIB%20Examples/Controllers/checkOutLogController.cls)
                    - Which calls to [Check Out Log Service Class](/force-app/main/default/classes/FFLIB%20Examples/Services/BGCheckOutLogService.cls) to Update the Check Out Log 
          - Which uses a [CPE Component](/force-app/main/default/lwc/cpeCheckOutLogConfig) to format the Properties of the Component
               - Which includes a [Child Component](/force-app/main/default/lwc/cpeLogButtonConfig) for the Properties for each of the Buttons
- Add the Screen Flow to Record Pages for Respective SObjects
- Create a [Trigger](/force-app/main/default/triggers/BoardGameCheckOutLogTrigger.trigger) on Check Out Log
     - Which calls the [Trigger Handler](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers/BoardGameCheckOutLogTriggerHandler.cls)
          - Which calls the [Service](/force-app/main/default/classes/FFLIB%20Examples/Services/BGCheckOutLogService.cls) that will populate a Hidden Field for Rollup Calculations

This Use Case shows examples for the following:
- Screen Flows
- LWC
     - Import Apex Controller
     - Toast Messaging
     - Wire Connection to get Records from Controller
     - Utilize Refresh Apex
     - Nested Child LWCs
          - Passing Values to Child
          - Firing Custom Events
          - Catching Events Fired from Child
     - Using Properties
     - Using CPE for Properties
- FFLIB
     - Application Layer
     - Implementation Layer (APEX Controller and Trigger Handler)
     - Service Layer
     - Selector Layer
     - Unit Of Work Layer
- Testing
     - Mocking and Stubbing FFLIB Classes
          - Using [MockSetup Class](/force-app/main/default/classes/FFLIB%20Examples/README.md#mock-setup-class)
          - Validate Using [Mocks.Verify](/force-app/main/default/classes/FFLIB%20Examples/README.md#mocksverify-example-quick-reference)
     - Use Case Unit Testing

[Back to Use Case Examples List](#example-use-cases) - [Back to Top](#fflib-working-examples)

### 5. Home Board Game Dashboard (WIP)

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

[SObjects and Custom Metadata Types](/force-app/main/default/objects)

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

