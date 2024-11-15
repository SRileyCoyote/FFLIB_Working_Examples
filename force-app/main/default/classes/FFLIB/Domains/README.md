# DOMAIN LAYER

## Overview
### Class
1. Create Domain Layer Class and Interface
1. Create Trigger for SObject, Calling Domain.
1. Add Domain to [Application](/force-app/main/default/classes/FFLIB/Application)
1. Add Logic to use [Custom Metadata Type](/force-app/main/default/objects) to:
    1. Enable/Disable Trigger
    1. Prevent Recurrison
    1. Bypass Error Handling
1. Add Override Methods for the different Trigger Types Needed
    1. Call [Service](/force-app/main/default/classes/FFLIB/Services) to Handle logic
    1. Pass in [UnitOfWork]() Object to all Service Methods
    1. Commit Work on [UnitOfWork]() Object

### Test Class
1. Create Test Class for Domain
    1. Add Mocking & Stubbing for [Service](/force-app/main/default/classes/FFLIB/Services) Class
    1. Create Unit Test Methods for Domain:
        1. Test Only Logic in Domain NOT Service Class
        2. Test Every Possible Scenario for Domain Configurations NOT Just Code Coverage
    1. Use Asserts or Mocks.Verify Methods to Validate Results
1. Create Test Class for Trigger [^1]
    1. Add Mocking and Stubbing for [Domain]()
    
[^1]: Testing here will only be for coverage as all other logic will be tested in the other layers

## Trailhead and Resources

- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Domain Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer)
