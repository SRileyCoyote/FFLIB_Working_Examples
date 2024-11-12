# FFLIB Working Examples

This Repo Shows working examples of the FFLIB architechure design patterns using design patterns I have picked up over the years.

Includes the following Repos
- [FFLIB Repo](https://github.com/apex-enterprise-patterns/fflib-apex-common)
- [FFLIB Mocks Repo](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) 
- [SObjectFabricator Repo](https://github.com/mattaddy/SObjectFabricator)

This is an open source repo intended for my own personal use and to share with those that need it.

## Schema

For this example, I put together a small Application in Salesforce based on what I know best: Board Game Conventions.

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

## Setup

1. Download Repository to Local Machine with VS Code
1. Connect VS Code to DevHub Enabled Org
1. Create Scratch Org from DevHub 
- `sf org create scratch --definition-file config/project-scratch-def.json --alias [MyScratchOrg] --set-default --target-dev-hub [DevHub]`
1. Deploy all Metadata to Scratch Org
1. Populate Data Using Plan
- `sf data import tree -p ./data/Import-plan.json`

## Example Use Cases
1. When Board Game Rating is Marked as Favorite, Uncheck Favorite on all other Board Game Reviews for that Attendee

## TODO Notes:

How do I want to do this:
- Encorporate ZDF (Somehow?)
- Have triggers call Domain
- Domain Calls Service Passing in UOW
- Service Calls Selectors
- Service Calls other Services as needed
- Test Classes For Selectors
- Test Classes For Service, Mocking Selectors and Unit of Work
- Test Class For Trigger

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

Objects:
- Board Games 
 - (Action) Callout to BGG and Import Data
  - Import Board Games from My Collection
  - Search Board Games By Name (Return Id, Import Based on Id)
  - Import Board Games By Id
- BG Libraries
 - Add BG to Library
 - Import From BGG
  - Add New BG in Board Game
  - Add BGL Entry to BGL
- BGL Entries
 - Junction to BG and BGL
- Check out Logs
- Attendees 
- Conventions (Accounts)
- Events
- Registrations
- RPG Games
 - Import From BGG
- Time Slots
- Tables
- Vendors
- Event Vendors

Services and Automated Actions:
- Check out Game 
- Check in Game 
- Create Event (Owner Only)
- Generate Time Slots
- Register for Game (Attendees)
- Create Game (GM)

Perfect Path:
- Create Event off Convention
 - Add BGL(s)
 - Add Venue
  - Add Rooms (Select from Existing, or Add New)
  - Add Tables
  - Add Time Slots
    - Generate Time Slots Action
 - Add Vendors to Event Vendors
  - Select Existing Vendor or Add New
  - Assign Vendors Tables
- Add Staff
- Add Attendees
- Create Registered Game (GMs)
 - Generate Available Table Time Slots
 - Select RPG Game or Board Game
 - Total Seats (Custom Field)
 - Seats Filled (Rollup)
 - Available Seats (Formula)
-Register For Game (Attendees)
 - Generate Registered Games with Available Seats
 - Register For Game
- View My Games
 - Generate Games where Attendee is GM
 - Generate Games where Attendee is Player

