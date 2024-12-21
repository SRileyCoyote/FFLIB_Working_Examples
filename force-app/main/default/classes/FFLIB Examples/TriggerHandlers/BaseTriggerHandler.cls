/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Parent Trigger Handler for all Trigger Handlers.
*
* The Base/Parent Trigger Handler is an abstract class that holds all of the common varaibles such
* as the Domain Config MDT Record used in the trigger as well as the common logic to retrieve that
* MDT Record. The Base Trigger Handler also has an Abstract method used in the Constructors that 
* MUST be overriden by any class that extends the Base Class. The Overriden Method will then be 
* what is used in the Constructor. 
* 
* The Base Trigger Handler implements and extends the fflib_ISObjectDomain and fflib_SObjectDomain
* respectively which is needed by the line in the trigger itself which then knows which trigger 
* methods to fire.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-12-21
* @modified       2024-12-21
* @systemLayer    Trigger Handler
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing abstract class BaseTriggerHandler extends fflib_SObjectDomain implements fflib_ISObjectDomain {
    
    @TestVisible
    protected Domain_Config__mdt domainConfig;

    public BaseTriggerHandler(String domainName, Type domainClass, List<SObject> sObjectList) {
        this(Domain_Config__mdt.getInstance(domainName), domainClass, sObjectList);
    }

    @TestVisible
    //Constructor Used For Testing and Setting Own Config File
    protected BaseTriggerHandler(Domain_Config__mdt config, Type domainClass, List<SObject> sObjectList)
    {
        super(sObjectList);
        domainConfig = config;
        initialize();

        //Disable Triggers, if enabled 
        If(domainConfig.Bypass_Trigger__c){
            system.debug('Disabling Trigger...');
            fflib_SObjectDomain.getTriggerEvent(domainClass).disableAll();
        }
    }

    //Abstract methods Must be overriden by Child Classes.
    //The Child Initialize method will be what is used in the constructor  
    protected abstract void initialize();
}