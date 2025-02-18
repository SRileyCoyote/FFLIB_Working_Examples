import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UpdateBGLERecordFromBGG from '@salesforce/apex/UpdateFromBGGController.updateLibraryEntryRecordFromBGG';

// Fields to query from the record
const FIELDS = [
                'BG_Library_Entry__c.Source__c', 
                'BG_Library_Entry__c.Source_Type__c', 
                'BG_Library_Entry__c.BGG_Id__c',
                'BG_Library_Entry__c.BoardGameName__c'
            ];

export default class UpdateCollectionFromBGG extends LightningElement {
    @api recordId; // Automatically provided
    recordData;

    //On Load Get Board Game Record Information
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    wiredRecord({error, data}){
        if (data) {
            // Each Field Value from Data must be mapped into the recordData variable
            this.recordData = {
                Id: this.recordId,
                BoardGameName__c: data.fields.BoardGameName__c.value,
                Source__c: data.fields.Source__c.value,
                Source_Type__c: data.fields.Source_Type__c.value,
                BGG_Id__c: data.fields.BGG_Id__c.value
            };
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
        //Call Apex Controller passing along record ID and the Record Data value
        UpdateBGLERecordFromBGG({ recordId: this.recordId, bgle: this.recordData})
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