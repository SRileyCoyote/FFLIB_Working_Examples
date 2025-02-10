# FFLIB
FFLIB, admittedly, is complex and some say over engineered. There are a lot of moving pieces and the juice might not seem worth the squeeze when creating a dozen classes for one simple trigger action. However, the power and value of this pattern lies in the re-usablity and compartmentalization of its parts. 

The "Why" of using this pattern can be better described by people smarter than me, but I have broken down the Apex Classes into Seperate Folders for ease of Navigation and each Folder has it's own README File to Briefly describe each Layer of the Design Pattern for ease of understanding as well as templates on how to set them up.

- [Application Layer](/force-app/main/default/classes/FFLIB%20Examples/Application) - Single Class holds the lists and Mappings for all of the other Layers 
- Implementation Layer
    - [Trigger Handlers](/force-app/main/default/classes/FFLIB%20Examples/TriggerHandlers) - Called by the Trigger, Handles all the After and Before Trigger Methods for an SObject 
    - [Apex Controllers](/force-app/main/default/classes/FFLIB%20Examples/Controllers) - Called by either Aura, LWC or VF Pages, Houses all of the Methods for the UI 
- [Domain Layer](/force-app/main/default/classes/FFLIB%20Examples/Domains) - Handles all of the SObject Specific Logic like Validation logic or filtering Triggered Records
- [Selector Layer](/force-app/main/default/classes/FFLIB%20Examples/Selectors) - Handles all of the SOQL Queries for an SObject
- [Services Layer](/force-app/main/default/classes/FFLIB%20Examples/Services) - Handles all of the Logic for an SObject
- [UnitOfWork Layer]() [^1] - Handles all of the DML transactions for all Objects

[^1]: UnitOfWork Layer does not have or need it's own set of classes so doesnt have a folder

# Deployment Order
Because of the Dependancies Injected in this Style, Classes and Class Folders needed to be deployed in the following order

| Class Type        | Dependancies 
| ----------------- | ----------------------------------
| Interfaces:       | None
| Selectors:        | Interfaces
| Domain:           | Interfaces and Selectors
| Service:          | Interfaces, Domains, and Selectors
| Trigger Handlers: | Interfaces and Services
| Apex Controllers: | Interfaces and Services
| Application:      | Implemntation, Selectors, Services, and Domains
| Test Classes:     | Application

In order to avoid Deployment Errors or if Deployment Errors occur due to dependancy issues, 
- Comment out the contents of the Maps and Lists in the factories on the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Deploy [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Deploy Classes in Given Folder Order
- Uncomment out the contents on the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
- Deploy [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)

As new FFLIB Class Layers are created, It might be easier to deploy Interfaces and Classes immediately before adding methods or logic so that the [Application](/force-app/main/default/classes/FFLIB%20Examples/Application) registers that the classes exist