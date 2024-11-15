# SERVICE LAYER

## Overview
### Class
1. Create Service Layer Class and Interface
1. Add Service to [Application](/force-app/main/default/classes/FFLIB/Application)
1. Add Logic to Enable/Disable Features using [Custom Metadata Type](/force-app/main/default/objects)
1. Add Methods for Individual Features
    1. Pass in [UnitOfWork]() from [Domain](/force-app/main/default/classes/FFLIB/Domains)
    1. Call [Selectors](/force-app/main/default/classes/FFLIB/Selectors) for any SOQL Calls Needed 
    1. Register All DMLs needed into passed in [UnitOfWork]() Object
### Test Class
1. Add Mocking & Stubbing for any [Selectors](/force-app/main/default/classes/FFLIB/Selectors) Used
1. Add Mocking & Stubbing for [UnitOfWork]()
1. Create Test Methods for Every Possible Scenario for Feature NOT Just Code Coverage
    1. Happy Path
    1. Negative Paths
    1. Alternative Paths
    1. Bulkified Records
1. Use Asserts or Mocks.Verify Methods to Validate Results

## Trailhead and Resources

- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)