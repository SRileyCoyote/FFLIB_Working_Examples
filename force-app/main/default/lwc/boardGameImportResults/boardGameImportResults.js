import { LightningElement, api, track } from 'lwc';

export default class BoardGameImportResults extends LightningElement {
    @api results;

    @track expandedSections = {
        newBoardGames: false,
        updatedBoardGames: false,
        newBGLEs: false,
        updatedBGLEs: false,
        removedBGLEs: false,
    };

    toggleSection(section) {
        console.log(this.results)
        this.expandedSections[section] = !this.expandedSections[section];
        this.expandedSections = { ...this.expandedSections };
    }

    toggleNewBoardGames = () => this.toggleSection('newBoardGames');
    toggleNewBGLEs = () => this.toggleSection('newBGLEs');
    toggleUpdatedBoardGames = () => this.toggleSection('updatedBoardGames');
    toggleUpdatedBGLEs = () => this.toggleSection('updatedBGLEs');
    toggleRemovedBGLEs = () => this.toggleSection('removedBGLEs');
    
    toggleChevronIcon(isExpanded){
        return isExpanded ?  'utility:chevrondown' : 'utility:chevronright';
    }

    get toggleNewBoardGameIcon() {return this.toggleChevronIcon(this.expandedSections.newBoardGames)}
    get toggleNewBGLEsIcon() {return this.toggleChevronIcon(this.expandedSections.newBGLEs)}
    get toggleUpdatedBoardGameIcon() {return this.toggleChevronIcon(this.expandedSections.updatedBoardGames)}
    get toggleUpdatedBGLEsIcon() {return this.toggleChevronIcon(this.expandedSections.updatedBGLEs)}
    get toggleRemovedBGLEsIcon() {return this.toggleChevronIcon(this.expandedSections.removedBGLEs)}

    hasResults(recordCount){
        return recordCount > 0;
    }

    get hasNewBoardGames() {return this.hasResults(this.newBoardGamesCount)}
    get hasNewBGLEs() {return this.hasResults(this.newBGLEsCount)}
    get hasUpdatedBoardGames() {return this.hasResults(this.updatedBoardGamesCount)}
    get hasUpdatedBGLEs() {return this.hasResults(this.updatedBGLEsCount)}
    get hasRemovedBGLEs() {return this.hasResults(this.removedBGLEsCount)}

    get hasAnyResults(){
        return this.hasNewBoardGames ||
                this.hasNewBGLEs ||
                this.hasUpdatedBoardGames ||
                this.hasUpdatedBGLEs ||
                this.hasRemovedBGLEs
    }


    get hasErrors() {
        return this.results?.errorOccured && this.results?.errorMessages?.length > 0;
    }

    get unprocessedCount() {
        return this.results?.unprocessedIds?.size || 0;
    }

    get newBoardGames() {
        return this.results?.newBoardGames || [];
    }

    get updatedBoardGames() {
        return this.results?.updatedBoardGames || [];
    }

    get newBGLEs() {
        return this.results?.newBGLEs || [];
    }

    get updatedBGLEs() {
        return this.results?.updatedBGLEs || [];
    }

    get removedBGLEs() {
        return this.results?.removedBoardGames || [];
    }

    get newBoardGamesCount() {
        return this.newBoardGames?.length || 0;
    }

    get updatedBoardGamesCount() {
        return this.updatedBoardGames?.length || 0;
    }

    get newBGLEsCount() {
        return this.newBGLEs?.length || 0;
    }

    get updatedBGLEsCount() {
        return this.updatedBGLEs?.length || 0;
    }

    get removedBGLEsCount() {
        return this.removedBGLEs?.length || 0;
    }


}
