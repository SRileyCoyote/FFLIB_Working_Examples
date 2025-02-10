# Custom Property Editors

1. [Overview](#overview)
    1. [What Are CPEs?](#what-are-cpes)
    1. [Why Use CPEs?](#why-use-cpes)
1. [CPE Setup](#steps-to-create-a-screen-flow-cpe)
    1. [Unmanaged Packages](#1-install-unmanaged-packages-optional)
    1. [Build LWC](#2-build-lwc)
        - [Properties](#properties)
        - [SObject Property Type](#sobject-property-types)
    1. [Build CPE](#3-create-cpe-lwc)
        - [Add HTML](#html)
        - [Add JavaScript](#javascript)
            - [BuilderContext](#builder-context)
            - [Input Variables](#input-variables)
            - [Dispatch Methods](#dispatch-methods)
            - [Validation]()
        - [Add JS-Meta.XML](#configure-js-metaxml)
    2. [Update JS-Meta.XML on LWC](#4-update-js-metaxml-on-lwc)

## Overview
As I am sure you are aware, we can add LWCs (**Lightning Web Components**) to Screens on Screen Flows. We can setup these LWCs to accept input variables called Properties on the `.js-meta.xml` file for the LWC. 

The problem is that these Properites simply show up as a list of generic input fields regardless of datatype and display in alphabetical order based on the Label. If an LWC has a long list of Properties, this can be overwhelming or cumbersome when configuring. Not to mention all of the properties are displayed even if not all of them are always needed.

In order to solve this, we can add a CPE (**Custom Property Editor**) to the LWC that will allow us to take control over how these properites are formated. We can group and order them in a way that makes sense and even conditionally display certain Properties based on other selections.

When researching how to create a CPE, I was able to find [This Example](https://developer.salesforce.com/docs/platform/lwc/guide/use-flow-custom-property-editor-lwc-example.html) provided by Salesforce but struggled to find any other good examples or clear explinations on how to setup, create, or even use a CPE so I thought I would put one together myself.

[(Back to Top)](#custom-property-editors)

### What are CPEs? 
CPE  (**Custom Property Editor**) is an LWC (**Lightning Web Component**) that provides a custom UI for entering input values, which you can use with Invocable Apex actions and Flow Screen Components. Here is the [Official Definition](https://developer.salesforce.com/docs/platform/lwc/guide/use-flow-custom-property-editor.html) from Salesforce.

UnofficialSF.com also provided this helpful [Slide Deck](https://unofficialsf.com/wp-content/uploads/2020/08/Custom-Property-Editors-Introduction-Developer-Guide-1-1.pdf) providing an overview of the basics and touches breifly on how to set one up however I have also detailed the steps here.

[(Back to Top)](#custom-property-editors)

### Why Use CPEs?
While CPEs require add a few more extra steps to development, they greatly increase the User Experience and usability for adding an LWC to a Flow by allowing us to conditionally hide or show properties as needed, add our own formatting, as well as display them in an order that make more logical sense.


| Before CPE |  | After CPE |
| - | - | - |
|![Properties - Before CPE](/images/LWC_Default_Properties.png) | | ![Properties - After CPE](/images/LWC_CPE_Properties.png)

[(Back to Top)](#custom-property-editors)

## Steps to create a Screen Flow CPE:

1. [Unmanaged Packages](#1-install-unmanaged-packages-optional)
1. [Build LWC](#2-build-lwc)
    - [Properties](#properties)
    - [SObject Property Type](#property-type-examples)
1. [Build CPE](#3-create-cpe-lwc)
    - [Add HTML](#html)
    - [Add JavaScript](#javascript)
        - [BuilderContext](#builder-context)
        - [Input Variables](#input-variables)
        - [Dispatch Methods](#dispatch-methods)
        - [Validation]()
    - [Add JS-Meta.XML](#configure-js-metaxml)
2. [Update JS-Meta.XML on LWC](#4-update-js-metaxml-on-lwc)

### 1. Install Unmanaged Packages (Optional):

If able, you can Install these Unmanaged Packages containing some Base LWC Components already put together specifically to be used on CPEs. However, I found the [Documentation](https://unofficialsf.com/flow-action-and-screen-component-basepacks/) to be a little lacking on how to use and implement the Base Components and found it easier to create the CPE from scratch.

**NOTE**: These packages have also been added as dependancies in the `project-scratch-def.json` file but can be installed in your org using the `sf` or `sfdx` commands below or by following the install links provided.

#### Flow Actions Base Pack
Install into: [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t8b00000170r5AAA) or [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t8b00000170r5AAA)
```
sfdx force:package:install -p 04t8b00000170r5AAA -w 30 -o MyScratchOrg
```
or 
```
sf package install -p 04t8b00000170r5AAA -w 30 -o MyScratchOrg
```

#### Flow Screen Component Base Pack
Install into: [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5G000004fzAgQAI) or [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5G000004fzAgQAI)
```
sfdx force:package:install -p 04t5G000004fzAgQAI -w 30 -o MyScratchOrg
```
or 
```
sf package install -p 04t5G000004fzAgQAI -w 30 -o MyScratchOrg
```
**NOTE**: `Flow Screen Component Base Pack` is dependant on `Flow Actions Base Pack`

[(Back to Top)](#custom-property-editors) - [(Setup Steps)](#steps-to-create-a-screen-flow-cpe)

### 2. Build LWC

Create your LWC HTML, CSS (if needed), JavaScript as you normally would.

#### Properties
On the `js-meta.xml` file, set the target as `lightning__FlowScreen` and add any Inputs you want as Properties in the `targetConfig` tag like so:
```
<targetConfigs>
    <targetConfig targets="lightning__FlowScreen">
        <property name="strInput" type="String"/>
        <property name="boolInput" type="Boolean"/>
    </targetConfig>
</targetConfigs>
```
**NOTE**: Only `Name` and `Type` are needed as everything else (like `label`, `description`, etc) will be handled by the CPE.

#### SObject Property Types
If you want the Admin User to Select a specific SObject Type for a Property, you can add the Property Type to your LWCs `js-meta.xml` like this:

```
<targetConfig targets="lightning__FlowScreen">
<!-- List of Properties for LWC -->
    <propertyType name="mySObject" extends="SObject" label="Pick an SObject Type"/>
    <property name="myRecord" type="{mySObject}" label="Selected Record"/>   
    <!-- Other Properties for the LWC-->         
</targetConfig>

```
##### SObject Property Type Examples
###### Use PropertyType to prompt User to Select SObjects Type
```
<propertyType name="mySObject" extends="SObject" label="Flow Record Type" description="Generic sObject data type used for input sObject properties."/>
```
###### Example for Getting Record of the SObject Type
```
<property name="myRecord" type="{mySObject}" label="Flow Record" description="Record From Triggered Flow."/>            
```
###### Example for Getting Mutliple Records of the SObject Type
```
<property name="myRecords" type="{mySObject[]}" label="Collection of Selected SObject Type Records" description="Collection of Records."/>      
```      
###### Example for Getting Record of the Specific SObject Type
```
<property name="myCustomObjectRecord" type="@salesforce/schema/My_Custom_Object__c" label="My Custom Object Record" description="My Custom Object Record."/>   
```         
###### Example for Getting Mutliple of Specific SObjects
```
<property name="myCustomObjectRecords" type="@salesforce/schema/My_Custom_Object__c[]" label="Collection of My Custom Object" description="Collection of My Custom Objects."/>   
```

[(Back to Top)](#custom-property-editors) - [(Setup Steps)](#steps-to-create-a-screen-flow-cpe)

### 3. Create CPE LWC:

Next, we need to create the LWC that will act as the CPE. 

Create an LWC as normal (include CPE as the prefix of the name for the LWC so that we can differentiate it from the other LWCs. Example: `cpeConfig`)

#### HTML:

Start to put together the HTML of how you want your CPE to look and what inputs you want displayed on the screen as you would for any other LWC. This might include child LWCs, checkbox inputs, picklists, etc.

[(Back to Top)](#custom-property-editors) - [(Setup Steps)](#steps-to-create-a-screen-flow-cpe)

#### JavaScript:

##### Builder Context
`BuilderContext` is the object that is retrieved from the Flow that contains all of the information about the flow. While most of it wont be used, we can use the `Variables` property of `BuilderContext` to retrieve all of the Merge Field Flow Variables created in the flow.

###### Getter/Setter:
```
_builderContext;

@api
get builderContext() {
    return this._builderContext;
}
set builderContext(value) {
    this._builderContext = value;
}
```

###### Usage Example:
```
//Get all of the Single String Merge Fields from the Flow
get recordIdOptions() {
    const variables = this.builderContext.variables;

    return variables
            .filter((variable)=>{
                return variable.dataType === 'String' && variable.isCollection === false
            })
            .map(({ name }) => ({
                label: name,
                value: name,
            }));
}
```

##### Input Variables
`InputVariables` is the object that is retrieved from the Flow that contains all of the input values the Admin User entered previously on the LWC. We will use `InputVariables` to retrieve those values and populate the input fields we added to our HTML. Append cases to the switch for each input variable you are using and set save the value to a local variable.

###### Getter/Setter:
```
_values

@api get inputVariables(){
    return this._values;
}
set inputVariables(value){
    this._values = value;
    this.initializeValues();
}

initializeValues(){
    //Loop through all of the Inputs provided by the Flow
    this.inputVariables.forEach(input => {
        //Switch based on the name of the input and set the values on the CPE LWC
        // Name of the input should match the name of the LWC Property
        console.log(input.name +': '+input.value);
        switch (input.name) {
            case 'strInput':
                this.strInput = input.value;
                break;                
            case 'boolInput':
                //Boolean values are returned as the string literal of either 
                // $GlobalConstant.True or $GlobalConstant.False
                // So convert the string literal to a Boolean Value
                this.boolAddBGNameToChkOutBtn = input.value === '$GlobalConstant.True' || input.value === true; 
                break;
            default:
                break;
        }
    });
}

```

##### Dispatch Methods
Now that we have retrieved the input values from the Flow, we need to send them back to the flow to save them. To do that there are 3 Methods we will add that will each dispatch the following `CustomEvents`:
- `configuration_editor_input_value_changed`
- `configuration_editor_input_value_deleted`
- `configuration_editor_generic_type_mapping_changed`

###### DispatchFlowValueChanged Method:
This Method is what will be used in our handler events for input changes to send up the custom event `configuration_editor_input_value_changed` that the flow is listening for.
```
dispatchFlowValueChanged(attributeName, newValue, newValueDataType){
    const thisEvent = new CustomEvent('configuration_editor_input_value_changed', {
        bubbles: true,
        cancelable: false,
        composed: true,
        detail:{
            name: attributeName,
            newValue: newValue ? newValue : null,
            newValueDataType: newValueDataType
        }
    });
    this.dispatchEvent(thisEvent);
}
```
###### Example Handlers:
- String Input:
```
handleInputStringChange(event) {
    this.strInput = event.detail.value;
    // Notify the Flow of the updated value
    this.dispatchFlowValueChanged('strInput', this.strInput, 'String');
}
```
- Boolean Input
```
handleInputBooleanChange(event){
    // Update the value as the checkbox is toggled
    this.boolInput = event.target.checked;
    // Notify the Flow of the updated value
    this.dispatchFlowValueChanged('boolInput', this.boolInput, 'Boolean');
}
```
- Merge Field
```
handleRecordIdValueChange(event){
    this.recordId = '{!'+event.detail.value+'}';
    this.dispatchFlowValueChanged('recordId', this.recordId, 'reference');
}
```

###### DispatchFlowValueNull Method:
This Method is what will be used in our handler events or buttons to clear input changes by sending up the custom event `configuration_editor_input_value_deleted` that the flow is listening for.
```
dispatchFlowValueNull(attributeName){
    const thisEvent = new CustomEvent('configuration_editor_input_value_deleted', {
        bubbles: true,
        composed: true,
        cancelable: false,
        detail:{
            name: attributeName
        }
    });
    this.dispatchEvent(thisEvent);
}
```

###### DispatchTypeMappingChanged Method:
From your CPE, you can change the [SObject Type](#sobject-property-types) Selected by dispatching the custom event `configuration_editor_generic_type_mapping_changed` that the flow is listening for.

```
dispatchTypeMappingChanged(typeAttributeName, newValue){
    const thisEvent = new CustomEvent('configuration_editor_generic_type_mapping_changed', {
        bubbles: true,
        cancelable: false,
        composed: true,
        detail:{
            typeName: typeAttributeName, // Name of PropertyType (i.e. mySObject) 
            typeValue: newValue ? newValue : null,
        }
    });
    this.dispatchEvent(thisEvent);
}
```

[(Back to Top)](#custom-property-editors) - [(Setup Steps)](#steps-to-create-a-screen-flow-cpe)

##### Validation:
Because we are bypassing how the Flow handles Inputs with a CPE, we are also bypassing the built in Error Handling. In order to resolve this, we will need to use the `Validate` Method from the Flow. The `Validate` Method will *ONLY* check to see if the returned array has a value. If it does, the Flow will just display a generic error to the Admin User. We will need to add components to the HTML to display the Error Message Back to the Admin User.
###### Method Example
```
_validity = [];

@api validate(){
    if(!this.recordId){
        this._validity.push({
            key: 'recordId',
            errorString: 'Please Select the Record ID for this Flow Record'
        });
    } else if(!this.strSObjectType){
        this._validity.push({
            key: 'strSObjectType',
            errorString: 'Please Select the Record Type for this Flow Record'
        });
    }
    return this._validity;
}

//Utility Methods
isValid(key){
    return this._validity.filter((input)=>input.key === key).length === 0;
}

getError(key){
    let errMsg = ''
    if(!this.isValid(key)){
        this._validity
                .filter((input)=>input.key === key)
                .map((input)=>{
                    errMsg = input.errorString;
                })
    } 
    return errMsg;
}

//Input Validation Methods
isRecordIdInvalid(){
    return !this.isValid('recordId');
}
getRecordIdErrorMessage(){
    return this.getError('recordId');
}
```

#### Configure JS-Meta.XML:
No real changes are actually needed here. Just be sure `isExposed` is set to the default of `false` so that this LWC is not available to be added to a Screen as that might be confusing.
```
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>false</isExposed>
</LightningComponentBundle>
```
[(Back to Top)](#custom-property-editors) - [(Setup Steps)](#steps-to-create-a-screen-flow-cpe)

### 4. Update JS-Meta.XML on LWC: 
Finally, now that your LWC CPE is created (and hopefully deployed), you need to link it back to the LWC to be configured. To do so, you only need to update the `configurationEditor` property on the `targetConfig` tag in the `js-meta.xml` to use you LWC CPE: 
```
<targetConfig targets="lightning__FlowScreen" configurationEditor="c-cpe-config">
```

Now it should look something like this:
```
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__FlowScreen</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__FlowScreen" configurationEditor="c-cpe-config">
        <!-- List of Properties for LWC -->
            <propertyType name="mySObject" extends="SObject" label="Pick an SObject Type"/>
            <property name="myRecord" type="{mySObject}" label="Selected Record"/>   
            <property name="strInput" type="String"/>
            <property name="boolInput" type="Boolean"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

[(Back to Top)](#custom-property-editors) - [(Setup Steps)](#steps-to-create-a-screen-flow-cpe)