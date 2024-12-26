# SELECTOR LAYER

## Overview

The Selector Layer is where any and all SOQL calls for the Application should be housed. Any class that requires the use of a SOQL call should use the respective SObject Selector instead. 

__Calls__ to the Selector Methods should be treated as SOQL Calls meaning they should never be inside loops.

__Parameters__ for Selector Methods should always be Sets or Lists for bulkification and possible resuability later.

Selector Methods should __Return__ Lists of the SObject Type not just an individual SObject for bulkification and possible resuability later.

The Benefit is that this Layer can then be Mocked and Stubbed out from the whatever Test Class is calling the Selector to return relevant results without having to actually perform any DML inserts or updates with the Test Data bypassing any unneeded data manipulation required by Validation Rules as well as unexpected results from Triggers on the SObject that might change the data on the Test Record. Unit test data can then focus on just the logic in the mthod without having to worry about an Data Manipulation or Validation Rules that might be applied now or in the future.

### Class
1. Create Selector Layer Class and Interface
1. Add Selector to [Application](/force-app/main/default/classes/FFLIB%20Examples/Application)
1. Add Required Methods from Interface
1. Add Methods for Needed SOQL Calls
    1. Each Method should return a List of the SObject
    1. Each Method should accept Sets of parameter values for better reusability
    1. Each Method's name should reflect the ___Where___ Condition of the SOQL call
    1. Methods should NOT contain any logic
### Test Class
1. Create and Insert Setup Data using Test Utility Class [^1]
1. Create Test Methods for Selector Method
1. Use Asserts or Mocks.Verify Methods to Validate Results

[^1]: This should be the only time you will need to manipulate and insert test data

### Query Factory Options

fflib_QueryFactory query = newQueryFactory(false[^2], false[^3], true[^4]);

    query.selectField('Parent__r.Name'); //selectField is Only way to include fields from Parent Objects
    query.setCondition('ID in :setIDs'); //Where Clause for the Query
    query.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING, true) //Sort Results (Field Name, Sort Order, NullsLast)
    query.setLimit(10); //Limit Results

[^2]: **AssertCRUD**: (Optional) False By Default, Determines if CRUD Permissions are Enforced.

[^3]: **EnforceFLS**: (Optional) False By Default, Determines if Field Level Secrity is Enforced.

[^4]: **IncludeSelectorFields**: (Optional) True By Default, Query Uses Fields from getSObjectFieldList Method. Disable to limit to only own selected fields

## Trailhead and Resources

- [Official FFLIB Selector Layer Overview Definition](https://fflib.dev/docs/selector-layer/overview)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Selector Layer](https://github.com/financialforcedev/df12-apex-enterprise-patterns#data-mapper-selector)
