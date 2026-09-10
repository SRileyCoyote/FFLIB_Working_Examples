import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import importFromBGG from '@salesforce/apex/BoardGameImporterController.importFromBGG';
import getEvents from '@salesforce/apex/BoardGameImporterController.getEventList';
import getSources from '@salesforce/apex/BoardGameImporterController.getEventSources';

export default class BoardGameImporter extends LightningElement {
    // Importer Options
    importType = 'collection';
    importTypeSelected = '';
    importOptionSelected = '';
    selectedImportType;
    updateExisiting = false;
    getExpansions = false;
    deleteRemoved = false;
    nameOrId = '';
    isGeekList = false;
    showSourceSelection = false;
    selectedEventId = null;

    // State Variables
    @track showSpinner = false;
    @track importResults = {};
    @track boardGameChangeRowsById = {};

    // Data Lists
    events = [];
    sources = [];

    // Computed Getters
    get importOptions() {
        return [
            { label: 'Get New Games From Collection', value: 'onlyNew' },
            { label: 'Get New and Update Existing From Collection', value: 'updateAll' },
            { label: 'Remove Existing Collection', value: 'deleteAll' }
        ];
    }

    get deleteOptions() {
        return [
            { label: 'Force Delete of Library Entries', value: 'hardDelete' },
            { label: 'Archive Library Entries', value: 'softDelete' }
        ];
    }

    get importTypeOptions() {
        const baseOptions = [
            { label: 'User Collection', value: 'collection' },
            { label: 'GeekList', value: 'geeklist' }
        ];

        if (this.selectedEventId && this.sources.length > 0) {
            baseOptions.push({ label: 'Use Existing Source', value: 'existing' });
        }

        return baseOptions;
    }

    get nameOrIdLabel() {
        return this.isGeekList ? 'GeekList Number' : 'BGG Username';
    }

    get nameOrIdPlaceholder() {
        return this.isGeekList ? 'Enter GeekList Number' : 'Enter BoardGameGeek Username';
    }

    // Wire Methods
    @wire(getEvents)
    wiredEvents({ error, data }) {
        if (data) {
            this.events = data.map(event => ({
                label: event.Name,
                value: event.Id
            }));
        } else if (error) {
            console.error(error);
            this.showErrorToast('Error getting Events');
        }
    }

    @wire(getSources, { eventId: '$selectedEventId' })
    eventSources({ error, data }) {
        if (data) {
            console.log('Sources:', data);
            this.sources = Object.entries(data).map(([sourceName, sourceType]) => ({
                label: `${sourceType}: ${sourceName}`,
                value: `${sourceType}|${sourceName}`
            }));
        } else if (error) {
            this.showErrorToast('Error getting Sources');
        }
    }

    // Handlers
    handleImportTypeChange(event) {
        const selected = event.target.value;
        if (selected === 'existing' && !this.selectedEventId) {
            this.showErrorToast('Please select an Event before choosing "Use Existing Source".');
            return;
        }
        this.importType = selected;
        this.importTypeSelected = selected;
        this.showSourceSelection = selected === 'existing';
        this.isGeekList = selected === 'geeklist';
    }

    handleImportOptionChange(event) {
        this.importOptionSelected = event.detail.value;
        this.updateExisiting = this.importOptionSelected == 'updateAll';
    }

    handleGetExpansionsChange(event) {
        this.getExpansions = event.target.checked;
    }

    handleDeleteRemovedChange(event) {
        this.deleteRemoved = event.target.checked;
    }

    handleNameOrIdChange(event) {
        this.nameOrId = event.target.value;
    }

    handleEventChange(event) {
        this.selectedEventId = event.target.value;

        if (!this.selectedEventId && this.importType === 'existing') {
            this.importType = 'collection';
            //this.importTypeSelected = 'collection';
            this.showSourceSelection = false;
            this.nameOrId = null;
        }
    }

    handleSourceChange(event) {
        const [sourceType, sourceName] = event.detail.value.split('|');
        this.nameOrId = sourceName;
        this.importType = sourceType.toLowerCase();
        this.isGeekList = this.importType === 'geeklist';
    }

    getBoardGameChanges(gameId) {
        const changesMap = this.importResults?.boardGameChanges?.[gameId] || {};
        return Object.keys(changesMap).map(field => {
            const valueMap = changesMap[field];
            const oldVal = Object.keys(valueMap)[0];
            const newVal = valueMap[oldVal];
            return {
                field,
                oldValue: oldVal,
                newValue: newVal
            };
        });
    }

    loadBoardGameChanges() {
        const changesMap = this.importResults?.boardGameChanges || {};
        if (this.importResults?.updatedBoardGames) {
            this.importResults.updatedBoardGames = this.importResults.updatedBoardGames.map(game => {
                const gameId = game.Id;
                const fieldChanges = changesMap[gameId] || {};
                game.changeRows = Object.entries(fieldChanges).map(([fieldName, valueMap]) => {
                    const oldValue = Object.keys(valueMap)[0];
                    const newValue = valueMap[oldValue];
                    return {
                        field: fieldName,
                        oldValue,
                        newValue
                    };
                });
                return game;
            }).filter(bg => bg.changeRows && bg.changeRows.length > 0);
        }
    }

    loadBGLEChanges() {
        const changesMap = this.importResults?.bgleChanges || {};
        if (this.importResults?.updatedBGLEs) {
            this.importResults.updatedBGLEs = this.importResults.updatedBGLEs.map(entry => {
                const entryId = entry.Id;
                const fieldChanges = changesMap[entryId] || {};
                entry.changeRows = Object.entries(fieldChanges).map(([fieldName, valueMap]) => {
                    const oldValue = Object.keys(valueMap)[0];
                    const newValue = valueMap[oldValue];
                    return {
                        field: fieldName,
                        oldValue,
                        newValue
                    };
                });
                return entry;
            }).filter(bgle => bgle.changeRows && bgle.changeRows.length > 0);
        }
    }
    
    handleSubmit() {
        if (!this.nameOrId || !this.selectedEventId) {
            this.showErrorToast('Please fill in all required fields.');
            return;
        }

        this.showSpinner = true;
        this.resultsVisible = false;

        importFromBGG({
            eventId: this.selectedEventId,
            collectionNameOrGeekListId: this.nameOrId,
            isGeekList: this.isGeekList,
            updateExisiting: this.updateExisiting,
            deleteRemoved: this.deleteRemoved
        })
            .then(result => {
                console.log('raw result', result)
                this.importResults = JSON.parse(result);
                console.log('parsed result', JSON.parse(result))
                this.loadBoardGameChanges();
                this.loadBGLEChanges();
                this.resultsVisible = true;
                this.showSuccessToast('Import Successful');
            })
            .catch(error => {
                this.showErrorToast(error.body?.message || 'Import Failed');
                console.error(error);
            })
            .finally(() => {
                this.showSpinner = false;
                console.log('result', this.importResults.bgleChanges);
            });
    }

    showSuccessToast(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message,
            variant: 'success'
        }));
    }

    showErrorToast(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message,
            variant: 'error'
        }));
    }
}