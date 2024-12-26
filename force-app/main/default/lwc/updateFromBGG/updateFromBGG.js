import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UpdateRecordFromBGG from '@salesforce/apex/UpdateFromBGGController.UpdateRecordFromBGG';

// Fields to query from the record
const FIELDS = ['Board_Games__c.BGG_ID__c'];

export default class UpdateFromBGG extends LightningElement {
    @api recordId; // Automatically provided
    recordData;

    //On Load Get Board Game Record Information
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    wiredRecord({error, data}){
        if (data) {
            this.recordData = data;
        } else if (error) {
            this.showToast(
                'Error Fetching Data',
                'There was an error retrieving record data: '+ error.body.message,
                'error'
            );
        }
    }

    //Invoke method required for Headless Actions
    @api invoke() {
        //Call Apex Controller passing along record ID and the BGG_ID__c values
        UpdateRecordFromBGG({ recordId: this.recordId, bggId: this.recordData.fields.BGG_ID__c.value})
            .then(result => {
                // Handle successful update
                this.showToast('Import Successful', result, 'success');
            })
            .catch(error => {
                // Handle error
                this.showToast('Error Occured', error.body.message, 'error');
                console.error(error);
            });
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // Variants: "success", "error", "warning", "info"
        });
        this.dispatchEvent(toastEvent);
    }

}