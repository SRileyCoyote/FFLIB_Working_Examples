# FFLIB Examples

I have broken down the Apex Classes into Seperate Folders for ease of Navigation.
Each Folder has it's own README File to Briefly describe each Layer of the Design Pattern.

- [Application Layer](/force-app/main/default/classes/FFLIB/Application) - Single Class holds the lists and Mappings for all of the other Layers 
- [Domain Layer](/force-app/main/default/classes/FFLIB/Domains) - Called by the Trigger, Handles all the After and Before Trigger Methods for an SObject 
- [Selector Layer](/force-app/main/default/classes/FFLIB/Selectors) - Handles all of the SOQL Queries for an SObject
- [Services Layer](/force-app/main/default/classes/FFLIB/Services) - Handles all of the Logic for an SObject
- [UnitOfWork Layer]() [^1] - Handles all of the DML transactions for all Objects

[^1]: UnitOfWork Layer does not have or need it's own set of classes so doesnt have a folder