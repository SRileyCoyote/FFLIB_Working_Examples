import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import importFromBGG from '@salesforce/apex/boardGameImporterController.importFromBGG';
import getEvents from '@salesforce/apex/BoardGameImporterController.getEventList';

export default class BoardGameImporter extends LightningElement {

    importType = 'collection';  // Default to 'User's Collection'
    isUpdate = false;    // Default to Create only new records
    nameOrId = '';     // To store the input for Collection Name or GeekList ID
    isGeekList = false;
    selectedEventId = ''; // To store the selected Event ID
    events = [];         // To store the list of events fetched from Salesforce

    importOptions = [
        { label: 'User Collection', value: 'collection' },
        { label: 'GeekList', value: 'geeklist' }
    ];

    get nameOrIdLabel() {
        return this.isGeekList ? 'GeekList Number' : 'BGG Username';
    }

    get nameOrIdPlaceholder() {
        return this.isGeekList ? 'Enter GeekList Number' : 'Enter BoardGameGeek Username';
    }

    @wire(getEvents)
    wiredEvents({error, data}){
        if(data){
            this.events = data.map(event => ({
                label: event.Name,
                value: event.Id
            }));
        }
        else if (error){
            this.showErrorToast('Error getting Events');
        }
    }

    handleImportTypeChange(event) {
        this.importType = event.target.value;
        this.isGeekList = this.importType === 'geeklist' ? true : false;
    }

    handleIsUpdateChange(event) {
        this.isUpdate = event.target.checked;
    }

    handleNameOrIdChange(event) {
        this.nameOrId = event.target.value;
    }

    handleEventChange(event) {
        this.selectedEventId = event.target.value;
    }

    handleSubmit() {
        if (!this.nameOrId) {
            // Show an error message if input is empty
            this.showErrorToast('Please fill in all fields.');
            return;
        }
    
        importFromBGG({ eventId: this.selectedEventId, 
                        collectionNameOrGeekListId: this.nameOrId, 
                        isGeekList: this.isGeekList, 
                        updateExisiting: this.isUpdate })
            .then(result => {
                // Handle successful insert or log response
                this.showSuccessToast('Import Successful: ' + result);
                //Clear Form Values

            })
            .catch(error => {
                // Handle error
                this.showErrorToast(error.body.message);
                console.error(error);
            });
    }

    showSuccessToast(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
        }));
    }

    showErrorToast(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        }));
    }
}