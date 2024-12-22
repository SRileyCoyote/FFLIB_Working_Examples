# FFLIB Examples

I have broken down the Apex Classes into Seperate Folders for ease of Navigation.
Each Folder has it's own README File to Briefly describe each Layer of the Design Pattern.

- [Application Layer](/force-app/main/default/classes/FFLIB%20Examples/Application) - Single Class holds the lists and Mappings for all of the other Layers 
- [Trigger Handler Layer](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers) - Called by the Trigger, Handles all the After and Before Trigger Methods for an SObject 
- [Domain Layer](/force-app/main/default/classes/FFLIB%20Examples/Domains) - Handles all of the SObject Specific Logic like Validation logic or filtering Triggered Records
- [Selector Layer](/force-app/main/default/classes/FFLIB%20Examples/Selectors) - Handles all of the SOQL Queries for an SObject
- [Services Layer](/force-app/main/default/classes/FFLIB%20Examples/Services) - Handles all of the Logic for an SObject
- [UnitOfWork Layer]() [^1] - Handles all of the DML transactions for all Objects


# Deployment Order
Because of the Dependancies Injected in this Style, Classes and Class Folders needed to be deployed in the following order

| Class Type        | Dependancies 
| ----------------- | ----------------------------------
| Interfaces:       | None
| Selectors:        | Interfaces
| Domain:           | Interfaces and Selectors
| Service:          | Interfaces, Domains, and Selectors
| Trigger Handlers: | Interfaces and Services
| Application:      | Selectors, Services, and Domains
| Test Classes:     | Application

In order to avoid Deployment Errors or if Deployment Errors occur due to dependancy issues, 
- Comment out the contents of the Maps and Lists in the factories on the **Application**
- Deploy **Application**
- Deploy Classes in Given Folder Order
- Uncomment out the contents on the **Application**
- Deploy **Application**

As new FFLIB Class Layers are created, Deploy interfaces and classes immediately before adding methods or logic so that the Application registers that the classes exist

[^1]: UnitOfWork Layer does not have or need it's own set of classes so doesnt have a folder