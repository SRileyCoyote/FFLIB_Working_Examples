import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CheckOutLogConfigCPE extends LightningElement {
    //#region Inputs    
    
    @api strChkOutBtnLbl
    @api strChkInBtnLbl
    @api boolAddBGNameToChkOutBtn
    @api boolAddBGNameToChkInBtn
    @api strChkOutBtnAction
    @api strChkInBtnAction
    @api boolShowChkOutBtn = false;
    @api boolShowChkInBtn = false;

    @api selectedRecordType;
    @api flowRecordId

    //#endregion

    //#region Picklist Options

    get recordTypeOptions() {
        return [
          { label: 'BG Library Entry', value: 'BG_Library_Entry__c' },
          { label: 'Board Games', value: 'Board_Games__c' },
          { label: 'Board Game Rating', value: 'Board_Game_Rating__c' },
          { label: 'Check Out Log', value: 'BG_Checkout_Log__c' },
        ];
      }
    
    get recordIdOptions() {
        //Get all variables from the Flow
        const variables = this.builderContext.variables;
        //Return only the Single String Variables
        return variables
                .filter((variable)=>{
                    return variable.dataType === 'String' && variable.isCollection === false
                })
                .map(({ name }) => ({
                    label: name,
                    value: name,
                }));
    }

    //#endregion

    //#region BuilderContext

    //Builder Context is ALL of the metadata of the current flow.
    // This is where we are going to get our variables that exist in the flow.
    // This is Read-Only
    _builderContext;

    @api
    get builderContext() {
        return this._builderContext;
    }
    set builderContext(value) {
        console.log('Builder Context:', value);
        this._builderContext = value;
    }

    //#endregion

    //#region InputVariables

    //Input Variables is the actual Input Values on the Flow being passed in by the user
    // The name of the InputVariable is the name of the property from the parent LWC
    // The value of the InputVariable is the saved value enter for that property
    _values

    @api get inputVariables(){
        return this._values;
    }
    set inputVariables(value){
        this._values = value;
        this.initializeValues();
    }

    initializeValues(){
        console.log('Input Variables:', this.inputVariables);
        //Loop through all of the Inputs provided by the Flow
        this.inputVariables.forEach(input => {
            //Switch based on the name of the input and set the values on the CPE LWC
            // Name of the input should match the name of the LWC Property
            switch (input.name) {
                case 'flowRecordId':
                    this.flowRecordId = input.value;
                    break;                
                case 'strSObjectType':
                    this.selectedRecordType = input.value;
                    break;
                case 'strChkOutBtnLbl':
                    this.strChkOutBtnLbl = input.value;
                    break;
                case 'strChkInBtnLbl':
                    this.strChkInBtnLbl = input.value;
                    break;
                case 'boolAddBGNameToChkOutBtn':
                    //Boolean values are returned as the string literal of either 
                    // $GlobalConstant.True or $GlobalConstant.False
                    // So convert the string literal to a Boolean Value
                    this.boolAddBGNameToChkOutBtn = input.value === '$GlobalConstant.True' || input.value === true; 
                    break;
                case 'boolAddBGNameToChkInBtn':
                    this.boolAddBGNameToChkInBtn = input.value === '$GlobalConstant.True' || input.value === true; 
                    break;
                case 'boolShowChkOutBtn':
                    this.boolShowChkOutBtn = input.value === '$GlobalConstant.True' || input.value === true; 
                    break;
                case 'boolShowChkInBtn':
                    this.boolShowChkInBtn = input.value === '$GlobalConstant.True' || input.value === true; 
                    break;
                case 'strChkOutBtnAction':
                    this.strChkOutBtnAction = input.value;
                    break;
                case 'strChkInBtnAction':
                    this.strChkInBtnAction = input.value;
                    break;
                default:
                    break;
            }
        });
    }
    //#endregion

    //#region Validation

    //Use this funtion to validate inputs from the CPE
    // if the return value is an empty array, all is good
    // otherwise, throw an error on the page
    // Errors must be handled by the CPE and will NOT be handled by the Flow Builder
    _validity = [];

    @api validate(){
        if(!this.selectedRecordType){
            this._validity.push({
                key: 'selectedRecordType',
                errorString: 'Please Select the Record Type for this Flow Record'
            });
        } else if(!this.flowRecordId){
            this._validity.push({
                key: 'flowRecordId',
                errorString: 'Please Select the Record ID for this Flow Record'
            });
        }
        return this._validity;
    }

    isValid(key){
        const temp = []
        temp.push(...this._validity.filter((input)=>input.key === key));
        console.log('Value', temp)
        return temp.length === 0;
    }

    getError(key){
        let errMsg = ''
        if(!this.isValid(key)){
            this._validity
                    .filter((input)=>input.key === key)
                    .map((input)=>{
                        console.log('Err Message', input.errorString )
                        errMsg = input.errorString;
                    })
        } 
        return errMsg
    }

    get isRecordIdInvalid(){
        return !this.isValid('flowRecordId');
    }
    get recordIdErrorMessage(){
        return this.getError('flowRecordId');
    }

    get isRecordTypeInvalid(){
        return !this.isValid('selectedRecordType');
    }
    get recordTypeErrorMessage(){
        return this.getError('selectedRecordType');
    }

    //#endregion

    //#region Dispatch Events

    dispatchFlowValueChanged(attributeName, newValue, newValueDataType){
        const thisEvent = new CustomEvent('configuration_editor_input_value_changed', {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail:{
                name: attributeName,
                newValue: newValue ? newValue : null,
                newValueDataType: newValueDataType //Literal Data Type Value or 'reference' for merge fields
            }
        });
        this.dispatchEvent(thisEvent);
    }

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

    dispatchTypeMappingChanged(typeName, newValue){
        const thisEvent = new CustomEvent('configuration_editor_generic_type_mapping_changed', {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail:{
                typeName: typeName,
                typeValue: newValue ? newValue : null,
            }
        });
        this.dispatchEvent(thisEvent);
    }

    //#endregion

    //#region Handler Methods

    handleEnableCheckOutBtnChange(event) {
        // Update the value as the checkbox is toggled
        this.boolShowChkOutBtn = event.target.checked;
        // Notify the Flow of the updated value
        this.dispatchFlowValueChanged('boolShowChkOutBtn', this.boolShowChkOutBtn, 'Boolean');
    }

    handleEnableCheckInBtnChange(event){
        // Update the value as the checkbox is toggled
        this.boolShowChkInBtn = event.target.checked;
        // Notify the Flow of the updated value
        this.dispatchFlowValueChanged('boolShowChkInBtn', this.boolShowChkInBtn, 'Boolean');
    }

    handleRecordIdValueChange(event){
        this.flowRecordId = '{!'+event.detail.value+'}';
        this.dispatchFlowValueChanged('flowRecordId', this.flowRecordId, 'reference');
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
        this.dispatchFlowValueChanged('strSObjectType', this.selectedRecordType, 'String');
    }

    handleChkOutBtnChange(event){
        //Catch values from child component for Check Out 
        const { attribute, value } = event.detail;

        switch (attribute){
            case 'buttonLabel':
                this.strChkOutBtnLbl = value;
                this.dispatchFlowValueChanged('strChkOutBtnLbl', value, 'String');
                break;
            case 'includeBGName':
                this.boolAddBGNameToChkOutBtn = value;
                this.dispatchFlowValueChanged('boolAddBGNameToChkOutBtn', value, 'Boolean');
                break;
            case 'buttonAction':
                this.strChkOutBtnAction = value;
                this.dispatchFlowValueChanged('strChkOutBtnAction', value, 'String');
                break;
        }
    }

    handleChkInBtnChange(event){
        //Catch values from child component for Check In 
        const { attribute, value } = event.detail;

        switch (attribute){
            case 'buttonLabel':
                this.strChkInBtnLbl = value;
                this.dispatchFlowValueChanged('strChkInBtnLbl', value, 'String');
                break;
            case 'includeBGName':
                this.boolAddBGNameToChkInBtn = value;
                this.dispatchFlowValueChanged('boolAddBGNameToChkInBtn', value, 'Boolean');
                break;
            case 'buttonAction':
                this.strChkInBtnAction = value;
                this.dispatchFlowValueChanged('strChkInBtnAction', value, 'String');
                break;
        }

    }

    //#endregion

    //#region Utility Methods
    
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // Variants: "success", "error", "warning", "info"
        });
        this.dispatchEvent(toastEvent);
    }

    //#endregion

}