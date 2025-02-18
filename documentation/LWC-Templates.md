# HTML

The HTML for a LWC is going to be too hyper-specific to what you need to be able to provide a basic template and there are WAY too many [LWC Components](https://developer.salesforce.com/docs/component-library/overview/components) to provide examples of each one here especially when [This Library](https://developer.salesforce.com/docs/component-library/overview/components) exists.

# Common JavaScript Methods
## Get Record
### Import
```
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
                'MySObject__c.Name', 
                'MySObject__c.Related__c',
                'MySObject__c.Source__c'
            ];
```
### Method
```
@api recordId; // Automatically provided from Salesforce
recordData;

@wire(getRecord, {recordId: '$recordId', fields: FIELDS})
wiredRecord({error, data}){
    if (data) {
        //Do Work
        console.log('Results:', data);

        // Each Field Value from Data must be mapped into the recordData variable
        this.recordData = {
            Id: this.recordId,
            Related__c: data.fields.Related__c.value,
            Source__c: data.fields.Source__c.value
        };
    } else if (error) {
        console.error('Error Getting Record', error);
        this.showToast(
            'Error Fetching Data',
            'There was an error retrieving record data: '+ error.body.message,
            'error'
        );
    }
}
```
## Show Toast
### Import
```
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
```
### Method
```
showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // Variants: "success", "error", "warning", "info"
        });
        this.dispatchEvent(toastEvent);
    }
```
### Usage
```
this.showToast('Import Successful', result, 'success');
```
```
this.showToast('Error Occured', errormessage, 'error');
```
## Wire Method
### Import
```
import { LightningElement, wire } from 'lwc';
import myMethod from '@salesforce/apex/myController.myMethod';
```
### Method
```
@wire(myMethod, {myRecordId: '$recordId', strMyParam: '$strSObjectType'})
    wireMyMethod({error, data}){
        if (data) {
            //Do Work
            console.log('Results:', data);
        } else if (error) {
            console.error('Error in Wire', error);
            this.showToast('Error getting MyMethod', error.body.message, 'error');
        }
    }
```
## Promise Method
### Import
```
import myMethod from '@salesforce/apex/myController.myMethod';
```
### Method
```
handleClickMethod(){

    const inputs = {
        myRecordId: this.recordId,
        strMyParam: this.strSObjectType
    };

    myMethod(inputs)
        .then((result)=>{ 
            //Do Work with Result
            console.log('Results:', result);
        })
        .catch((error) => {
            console.error('Error In Promise', error);
            this.showToast('Error', error.body.message, 'error');
        })
        .finally(()=>{ //Optional
            //Do Clean Up Work
        })
} 
```

# JS-Meta.xml
[JS-Meta.xml Config Documentation](https://developer.salesforce.com/docs/platform/lwc/guide/reference-configuration-tags.html)
## Header
```
<apiVersion>62.0</apiVersion> <!-- Update API version as needed -->
<description>This is My Lightning Web Component</description>
<isExposed>true</isExposed>
<masterLabel>My LWC</masterLabel>
```
## Targets
[Full List of Targets](https://developer.salesforce.com/docs/platform/lwc/guide/reference-configuration-tags.html#target)
```
<targets> 
    <!-- Choose Only those that Apply -->
    <target>lightning__AppPage</target>
    <target>lightning__RecordPage</target>
    <target>lightning__HomePage</target>
    <target>lightning__FlowScreen</target>
    <target>lightning__Tab</target>
    <target>lightning__UtilityBar</target>
    <target>lightningCommunity__Page</target>
    <target>lightningCommunity__Default</target>
    <target>lightning__RecordAction</target>
</targets>
```
## Target Configs
### App Page
```
<targetConfigs>
    <targetConfig targets="lightning__AppPage, lightning__HomePage, lightning__RecordPage">
        <!-- Properites Go Here -->
    <targetConfig>
</targetConfigs>
```
### Flow Screen
```
<targetConfigs>
    <targetConfig targets="lightning__FlowScreen" configurationEditor="c-cpe-config">
        <!-- Properites Go Here -->
    <targetConfig>
</targetConfigs>
```
**NOTE**: [More Information about Configuration Editors](/documentation/Custom-Property-Editors.md)
### Record Action
```
<targetConfigs>
    <targetConfig targets="lightning__FlowScreen">
        <!-- Pick One -->
        <actionType>ScreenAction</actionType> <!-- Default -->
        <!-- OR -->
        <actionType>Action</actionType> <!-- Headless Action -->
        <!-- lightning__RecordAction doesn't support component properties -->
    </targetConfig>
</targetConfigs>
```
## Properties
### Standard Property Types
[Full List of Standard Property Options](https://developer.salesforce.com/docs/platform/lwc/guide/targets-lightning-record-page.html#property)
#### String
```
<property name="strInput" type="String" label="My String Name" description="This is My String's Description" default="My Name" placeholder="String Placeholder" required="true"/>
```
#### Boolean
```
<property name="boolInput" type="Boolean" label="My Boolean Name" description="This is My Boolean's Description" default="false" />
```
#### Integer
```
<property name="intInput" type="Integer" label="My Integer Name" description="This is My Integer's Description" default="10" min="1" max="100" required="true"/>
```

#### Picklist
```
<property name="strPickList" type="String" label="My Picklist" description="This is My Picklist's Description" default="value1" datasource="value1,value2,value3" required="true"/>
```
### Additional Flow Property Types
**NOTE**: Flows have an addition attribute of `role` which can be set to `inputOnly` or `outputOnly`. If not set, the default is both input and output.
#### Date
```
<property name="dateInput" type="Date" label="My Date" description="This is My Date's Description." required="false" role="inputOnly"/>
```
#### DateTime
```
<property name="dateInput" type="Datetime" label="My Datetime" description="This is My Datetime's Description." required="false" role="inputOnly"/>
```
#### Specific SObject Type
```
<property name="objInput" type="@salesforce/schema/MySObject__c" label="My Custom Object Record" description="My Custom Object Record Description." role="inputOnly"/>   
```

#### Select SObject Type
If you want the Admin User to Select a specific SObject Type for a Property, you can add a Property Type

```
<propertyType name="mySObject" extends="SObject" label="Pick an SObject Type" description="Generic sObject data type used for input sObject properties"/>

<property name="myRecord" type="{mySObject}" label="Selected Record" description="Record Description." role="inputOnly"/>   
```
