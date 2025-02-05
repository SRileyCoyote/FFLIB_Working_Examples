import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCheckOutLog from '@salesforce/apex/checkOutLogController.updateCheckOutLog';

export default class CheckInGame extends LightningElement {
    //#region Variables
    //Variables From Properties
    @api logRecords = [];                          // Collection of BG Library Entries 
    @api buttonLabel = 'Game';                      // Label for Check Out Button passed in from Parent
    @api isDisabled = false;                        // Toggle Show Button
    @api boardGameName;                             // Board Game Name from Parent

    //Variables for Log Picklist
    @track logOptions = [];
    @track selectedLogId;
    @track selectedLogRecord;
        //If there are multiple Logs Active, Show Picklist
    get showLogPicklist(){
        return this.logOptions.length > 1;
    }

    //Modal Variables
    @track showModal = false;                       // Control Modal Visibility
    @track checkInDate = new Date().toISOString(); // Default to current time
    get hasInvalidInputs(){                         // If Invalid Inputs, Disable Submit Button
        return (!this.selectedLogId || !this.checkInDate);
    }    
    //#endregion

    //#region Methods
    
    //#region On Load Methods
    connectedCallback(){

    }
    //#endregion

    //#region Handle Change Methods
    handleLogChange(event) {
        this.selectedLogId = event.target.value;
        this.selectedLogRecord = this.logRecords
                                    .find((record) => 
                                        record.Id === this.selectedLogId
                                    );
    }

    handleDateChange(event) {
        this.checkInDate = event.target.value;
    }
    //#endregion

    //#region Handle Button Click Methods
    handleSubmit(){

        const inputs = {
            log: this.selectedLogRecord,
            checkInDate: this.checkInDate
        };

        updateCheckOutLog(inputs)
            .then(()=>{ //Method returns void
                this.showToast('Success', this.boardGameName 
                                                + ' has been Checked In.' 
                                        , 'success');
                this.showModal = false; //Close Modal
                //Send Message to Parent to toggle Status
                this.refreshLogStatus(this.selectedLogId);
                this.resetForm();
            })
            .catch((error) => {
                console.error(error)
                this.showToast('Error', 'Failed to Check Out Game: ' + error.body.message, 'error');
            })
    } 

    handleOpenModal() {
        this.showModal = true;
        this.loadOptions();
    }

    handleCloseModal() {
        this.showModal = false;
        this.resetForm();
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

    refreshLogStatus(logId){
        //Pass Data Back to Parent using Custom Event
        const customEvent = new CustomEvent('logupdated',{
            detail: logId,
            //Options: Choose One
            // bubbles: false, composed: false  // Pass Events up to other LWC in this LWC
            // bubbles: true, composed: false   // Pass Events up to parent container
            bubbles: true, composed: true       // Pass Events up to all Parent LWCs and containers, Most Common
            // bubbles: false, composed: true   // Not an Option

        });

        //Fire Custom Event
        this.dispatchEvent(customEvent);
    }

    loadOptions(){
        if(this.logRecords 
            && this.logRecords.length > 0){ //If Log Records have a Value
            //For Each Log Record Given
            this.logRecords
                .forEach(record => {
                    this.logOptions.push({
                        label: record.BG_Library_Entry__r.Event__r.Name 
                            + ': ' + record.BG_Library_Entry__r.BoardGameName__c
                            + ' By ' + record.Checked_Out_By__r.Attendee_Name__c,
                        value: record.Id
                    });
                });
        }
        else {
            this.showToast('Error', 'No Open Check Out Logs Found', 'error');
        }        
        //if there is only Active Log, Default this as the Selected Value
        if(this.logOptions.length === 1){
            this.selectedLogId = this.logOptions[0].value;
            this.selectedLogRecord = this.logRecords
                                        .find((record) => 
                                            record.Id === this.selectedLogId
                                        );
        }
    }

    resetForm(){
        this.checkInDate = new Date().toISOString();
        this.selectedLogRecord = null;
        this.selectedLogId = null;
        this.logOptions = [];
    }
    //#endregion

    //#endregion
    

}