# APPLICATION LAYER

## Overview
The Application Layer is a single Apex Class that houses the factories to create Selectors, Services, Domains, and SObjects that will be used with the Unit of Work Layer. 

Each time a New Instance of one of the other classes are called, we call it using the Factory from the Application Layer so that during Testing we can Stub out those classes and replace the values returned with our own values so that the unit test for that individual class can focus just on the logic contained within that specific class.

### Class
1. Create Application Layer Class
1. Add Map of SObjects to their [Selectors](/force-app/main/default/classes/FFLIB%20Examples/Selectors)
1. Add Map of SObjects to thier [Domain Constructors](/force-app/main/default/classes/FFLIB%20Examples/Domains)
1. Add Map of Service Interfaces to their [Service](/force-app/main/default/classes/FFLIB%20Examples/Services)
1. Add SObject to List of [UnitOfWork]()'s SObjects 
### Test Class
1. No Test Class Needed For this Class as it contains no logic and Coverage will be met from Test Classes from the other Layers

## Trailhead and Resources

- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Preview of Advanced Apex Patterns Session (Application Factory and ApexMocks Features)](http://andyinthecloud.com/2014/08/26/preview-of-advanced-apex-enterprise-patterns-session/)
- [FFLIB - Application Structure](https://quirkyapex.com/2017/12/03/fflib-application-structure)

