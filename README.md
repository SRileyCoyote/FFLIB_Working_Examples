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

[SObjects and Custom Metadata Types](/force-app/main/default/objects)

[FFLIB](/force-app/main/default/classes/FFLIB)
- [Application Layer](/force-app/main/default/classes/FFLIB/Application)
- [Domain Layer](/force-app/main/default/classes/FFLIB/Domains)
- [Selector Layer](/force-app/main/default/classes/FFLIB/Selectors)
- [Service Layer](/force-app/main/default/classes/FFLIB/Services)


