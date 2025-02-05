import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBGLEs from '@salesforce/apex/checkOutLogController.getBGLEs';
import getCheckOutLogs from '@salesforce/apex/checkOutLogController.getCheckOutLogs';
import{ refreshApex } from '@salesforce/apex';

export default class CheckOutLogContainer extends LightningElement {    
    //#region Variables

    //#region LWC Property Inputs
    @api flowRecordId;                              //ID of the Record From the Flow passed in from the Record Page
    @api strSObjectType;                            //SObject Name of the Record being passed in
    @api strChkOutBtnLbl;                           //Check Out Button Label, Provided by User
    @api strChkInBtnLbl;                            //Check In Button Label, Provided By User
    @api boolAddBGNameToChkOutBtn;                  //If True, adds the Board Game Name to the end of the Check Out Button
    @api boolAddBGNameToChkInBtn;                   //If True, adds the Board Game Name to the end of the Check In Button
    @api strChkOutBtnAction;                        //Action of how to handle Check Out button if No Available BGLEs. Picklist Values: Hide, Disable 
    @api strChkInBtnAction;                         //Action of how to handle Check In button if No Active Logs. Picklist Values: Hide, Disable
    @api boolShowChkOutBtn                          //If False, Hide Check Out Button regardless of other settings
    @api boolShowChkInBtn                           //If False, Hide Check In Button regardless of other settings
    //#endregion

    //#region Container Variables
    @track strBoardGameName;                        //Holds the Name of the Board Game, pulled from the Flow Record
    //#endregion

    //#region Variables Passed to Check Out Button
    @track bgleRecords = [];                        //Retrived BGLE Records related to Flow SObject Type
    
    get checkOutButtonLabel(){                      //If Add BG Name to Check Out Button is TRUE,
        if(this.boolAddBGNameToChkOutBtn            // AND Board Game Name has a value
            && this.strBoardGameName){              // Return the given Check Out Button Label
            return this.strChkOutBtnLbl             // and Add the Board Game Name to the End
                + ' ' + this.strBoardGameName;      // Otherwise, Just return the given Check Out Button Label
        } else {
            return this.strChkOutBtnLbl;
        }
    }

    @api 
    get hideCheckOutButton(){                       
        return !this.boolShowChkOutBtn              //IF Show Check Out Button is False
            || (this.isCheckOutButtonDisabled       // OR IF bgleRecords have no Available Records
            && this.strChkOutBtnAction              // AND Check Out Button Action is HIDE
            && this.strChkOutBtnAction === 'Hide'); // Return TRUE else Return FALSE
    }

    @api
    get isCheckOutButtonDisabled(){
        return !this.bgleRecords || this.bgleRecords.length === 0;
    }
    //#endregion

    //#region Variables Passed to Check In Button
    @track logRecords = [];                         //Retrieved Check Out Log Records related to Flow SObject Type

    get checkInButtonLabel(){                       //If Add BG Name to Check In Button is TRUE,
        if(this.boolAddBGNameToChkInBtn             // AND Board Game Name has a value
            && this.strBoardGameName){              // Return the given Check In Button Label
            return this.strChkInBtnLbl              // and Add the Board Game Name to the End
                + ' ' + this.strBoardGameName;      // Otherwise, Just return the given Check In Button Label
        } else {
            return this.strChkInBtnLbl;
        }
    }

    @api
    get hideCheckInButton(){                        
        return !this.boolShowChkInBtn               //IF Show Check Out Button is False
            || (this.isCheckInButtonDisabled        // OR IF logRecords have no Active Records
            && this.strChkInBtnAction               // AND Check In Button Action is HIDE
            && this.strChkInBtnAction === 'Hide');  // Return TRUE else Return FALSE
    }

    @api
    get isCheckInButtonDisabled(){
        return !this.logRecords || this.logRecords.length === 0;
    }
    //#endregion

    //#endregion

    //#region On Load

    // Wire Apex methods so we can refresh them using refreshApex
    wiredBGLEsResult;                               // Stores the wired BGLEs response for refreshApex
    wiredLogsResult;                                // Stores the wired CheckOutLogs response for refreshApex

    @wire(getBGLEs, {recordId: '$flowRecordId', sObjectType: '$strSObjectType'})
    wireBGLEs(result){
        this.wiredBGLEsResult = result;             // Store for refreshApex
        if (result.data) {
            this.bgleRecords = result.data.filter(bgle => bgle.Status__c === "Available");
            // Ensure the Board Game Name is retrieved correctly
            if (result.data.length > 0) {
                this.strBoardGameName = result.data[0].BoardGameName__c; // Use the first record found
            }
            console.log('BGLEs Loaded:', result.data);
        } else if (result.error) {
            console.error(result.error);
            this.showToast('Error getting Library Entries', result.error.body.message, 'error');
        }
    }

    @wire(getCheckOutLogs, { recordId: '$flowRecordId', sObjectType: '$strSObjectType' })
    wiredCheckOutLogs(result) {
        this.wiredLogsResult = result;          // Store for refreshApex
        if (result.data) {
            this.logRecords = result.data.filter(record => !record.Check_In_Time__c);
            console.log('Check Out Logs Loaded:', result.data);
        } else if (result.error) {
            console.error(result.error);
            this.showToast('Error getting Check Out Logs', result.error.body.message, 'error');
        }
    }

    //#endregion

    //#region Methods

    handleRecordUpdated(){
        //Refresh APEX
        refreshApex(this.wiredBGLEsResult);
        refreshApex(this.wiredLogsResult);
    }

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