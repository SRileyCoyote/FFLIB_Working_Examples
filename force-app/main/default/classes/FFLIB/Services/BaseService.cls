/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Parent Service Class for all Service Classes.
*
* The Base Service Class is an abstract class that holds all of the common logic and variables for 
* retrieving and checking if services are enabled. Child Classes must Override the Initialize()
* Method used to initalize any Varaibles needed for the Service Class.
*
* Individual Test Class Not Needed For Parent Class as it is Abstract and cannot be 
* initialize on its own. Coverage for Class will come from Child Test Classes
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sean Riley
* @modifiedBy     Sean Riley
* @version        1.0
* @created        2024-11-30
* @modified       2024-12-21
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public abstract class BaseService {
    
    @TestVisible 
    protected Map<String, Services_Config__mdt> serviceConfigMap = new Map<String, Services_Config__mdt>(); 

    //Base Constructor, Gets Service Config MDT in Application
    public BaseService(String domainName){
        this(Services_Config__mdt.getAll().values(), domainName);
    }

    //Protected (Visible to only This and Child Classes) Overloaded Constructor 
    //Used to override the Service Config MDT in Application with MDT provided by test class
    protected BaseService(List<Services_Config__mdt> configList, String domainName) {
        // Get All Service Config Records without SOQL Call, Filter By Domain
        for(Services_Config__mdt config : configList){
            if(config.Domain_Config__r.DeveloperName == domainName){
                serviceConfigMap.put(config.DeveloperName, config);
            }
        }
        //Call initialize method overriden by Child Class
        initialize();
    }

    @TestVisible
    protected Boolean serviceEnabled(string serviceName){
        //If Service Config for Method Found AND Service Method is Enabled, Return True
        return (serviceConfigMap.containsKey(serviceName) && serviceConfigMap.get(serviceName).Service_Enabled__c);
    }

    //Abstract methods Must be overriden by Child Classes.
    //The Child Initialize method will be what is used in the constructor  
    protected abstract void initialize();

}