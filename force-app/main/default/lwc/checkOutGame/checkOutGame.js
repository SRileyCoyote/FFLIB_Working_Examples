import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEventAttendees from '@salesforce/apex/checkOutLogController.getEventAttendeesByEventId';
import createCheckOutLog from '@salesforce/apex/checkOutLogController.createCheckOutLog';

export default class CheckOutGame extends LightningElement {
    //#region Variables
    //Variables From Properties
    @api bgleRecords = [];                          // Collection of BG Library Entries 
    @api buttonLabel = 'Game';                      // Label for Check Out Button passed in from Parent
    @api isDisabled = false;                        // Toggle Show Button
    @api boardGameName;                             // Board Game Name from Parent

    //Variables from Atendees Wire
    @track attendees = [];                          // Store event attendees for Picklist Options
    @track selectedAttendeeId;                      // Store selected attendee's ID
    @track selectedAttendeeName                     // Store selected attendee Name for return message

    //Variables for BGLE Picklist
    @track bgleOptions = [];
    @track selectedBGLEId;
    @track selectedBGLE;
        //If there are multiple BGLEs Available, Show Picklist
    get showBGLEPicklist(){
        return this.bgleOptions.length > 1;
    }

    //Modal Variables
    @track showModal = false;                       // Control Modal Visibility
    @track checkOutDate = new Date().toISOString(); // Default to current time
    get hasInvalidInputs(){                         // If Invalid Inputs, Disable Submit Button
        return (!this.selectedBGLE || !this.selectedAttendeeId);
    }    
    //#endregion

    //#region Methods

    //#region On Load Methods
    connectedCallback(){

    }

    @wire(getEventAttendees, {eventId: '$selectedBGLE.Event__c'})
    wireEventAttendees({error, data}){
        if(data){
            this.attendees = data.map(record => ({
                label: record.Attendee_Name__c,
                value: record.Id
            }));
        }
        else if (error){
            this.showToast("Error getting Attendees", error.body.message, 'error')
        }
    }
    //#endregion

    //#region Handle Change Methods
    handleAttendeeChange(event) {
        this.selectedAttendeeId = event.target.value;
        
        // Find the label corresponding to the selected value
        const selectedOption = this.attendees.find(attendee => 
                                                    attendee.value === this.selectedAttendeeId);
        this.selectedAttendeeName = selectedOption 
                                    ? selectedOption.label 
                                    : null; // Store the label (name) of the selected attendee
    }

    handleBGLEChange(event) {
        const lastEventId = this.selectedBGLE?.Event__c;
        this.selectedBGLEId = event.target.value;
        this.selectedBGLE = this.bgleRecords
                                        .find((record) => 
                                            record.Id === this.selectedBGLEId
                                        );
        if(lastEventId !== this.selectedBGLE.Event__c){ //IF Event ID Changed,
             this.selectedAttendeeId = null;            //Clear Selected Attendee Value
        }
    }

    handleDateChange(event) {
        this.checkoutDate = event.target.value;
    }
    //#endregion

    //#region Handle Button Click Methods
    handleSubmit(){

        const inputs = {
            bgleId: this.selectedBGLEId,
            attendeeId: this.selectedAttendeeId,
            checkOutDate: this.checkOutDate
        };

        createCheckOutLog(inputs)
            .then(()=>{ //Method returns void
                this.showToast('Success', this.boardGameName 
                                                + ' has been Checked Out By ' 
                                                + this.selectedAttendeeName
                                        , 'success');
                this.showModal = false; //Close Modal
                //Send Message to Parent to toggle Status
                this.refreshBGLEStatus(this.selectedBGLE.Id);
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to Check Out Game: ' + error.body.message, 'error');
            })
            .finally(()=>{
                this.resetForm();
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

    refreshBGLEStatus(bgleId){
        //Pass Data Back to Parent using Custom Event
        const customEvent = new CustomEvent('bgleupdated',{
            detail: bgleId,
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
        if(this.bgleRecords){ //If BGLE Records have a Value
            //For Each BGLE Record Given
            this.bgleRecords
                .forEach(record => {
                    this.bgleOptions.push({
                        label: record.Event_Name__c + ' - ' + record.BoardGameName__c,
                        value: record.Id
                    });
                });
        }       
        else {
            this.showToast('Error', 'No Available Library Entries Found', 'error');
        }         
        //if there is only Available BGLE, Default this as the Selected Value
        if(this.bgleOptions.length === 1){
            this.selectedBGLEId = this.bgleOptions[0].value;
            this.selectedBGLE = this.bgleRecords
                                        .find((record) => 
                                            record.Id === this.selectedBGLEId
                                        );
        }
    }

    resetForm(){
        this.selectedAttendeeId = null;
        this.selectedAttendeeName = null;
        this.checkOutDate = new Date().toISOString();
        this.selectedBGLEId = null;
        this.selectedBGLE = null;
        this.bgleOptions = [];
    }
    //#endregion

    //#endregion

}