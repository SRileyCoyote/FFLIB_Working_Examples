/**
 * FFLIB Application Layer
 * Used to quickly generate the Factories for the Service, Selector, UnitOfWork, and Domain Layers.
 * Another benefit of using the Application Layer is that it can be used during mocking and stubbing to replace these Layers
 * when called by the Apex classes during testing so that to allow for pure Unit Testing of the function being tested without 
 * dependancies from other methods or validation of data not needed for the test.
 */
public class Application {
    /** Configure and create the ServiceFactory for this Application 
     * Service Layer: This layer handles all of the business logic for a method call from the Domain, usually passing in a 
     *  UnitOfWork object as a parameter so that all DML transactions are handled once the trigger completes.  
     *  The benefit is that the method can be unit tested without actually performing any DML and instead inspecting the 
     *  UnitOfWork object to see if it contains the expected records that were inserted, updated or deleted.
     * Recommended Naming Convention for the Service Class is [SObjectName]sService so it is clear it is the Service Class for that SObject
    */
    public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory(
        new Map<Type, Type>{
            //Mapped By Interface as Key
            //Addtional SObject Service Classes Go Here 
            IBoardGameRatingsService.class => BoardGameRatingsService.class,
            IBoardGamesService.class => BoardGamesService.class,
            IBGGCalloutService.class => BGGCalloutService.class
        }
    );

    /** Configure and create the SelectorFactory for this Application
     * Selector Layer: This layer handles all of the SOQL Calls for an object. 
     *  The benefit is that during testing the Selector can be mocked and stubbed out so that the unit tests can focus on the method 
     *  without creating a bunch of Test Data with prerequisites and validations first.
     * Recommended Naming Convention for the Selector Class in [SObjectName]Selector so it is clear it is the Selector Class for that SObject
    */
    public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type>{
            // Map SObjectType to Selector Class
            //Additional SObject Selectors Go Here
            Board_Game_Rating__c.SObjectType => BoardGameRatingSelector.class,
            Event__c.SObjectType => EventSelector.class,
            Board_Games__c.SObjectType => BoardGameSelector.class
        }
    );

    /** Configure and create the DomainFactory for this Application
    *  Domain Layer: This layer handles all of the trigger actions for the Object such as before and after insert update and delete methods
    *  Recommended Naming Convention for the Domain Class in [SOBjectName]sDomain so it is clear it is the Domain Class for that SObject  
    */
    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Application.Selector,
        // Map SObjectType to Domain Class Constructors
        new Map<SObjectType, Type>{
            //Additional SObject Domains Go Here
            Board_Game_Rating__c.SObjectType => BoardGameRatingsDomain.Constructor.class
        }
    );

    /** Configure and create the UnitOfWorkFactory for this Application
    *  UnitOfWork Layer: This layer handles all of the DML transactions for the Methods and commits all changes 
    *   to SObjects at the same time using minimal DML Calls
    *  NOTE: SObjects will be inserted and updated in the order in which they appear in this list so Child Objects must be below the Parent Object 
    *  Example: Since Account is the Parent Object to Contact, Account must be listed above Contact.
    */ 
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = new fflib_Application.UnitOfWorkFactory(
        new List<SObjectType>{
            //Additional SObjectTypes for Unit Of Work Go Here with Parent Objects Above Child
            Board_Game_Rating__c.SObjectType,
            Board_Games__c.SObjectType,
            BG_Library_Entry__c.SObjectType
        }
    );
}