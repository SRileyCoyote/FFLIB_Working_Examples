import { LightningElement, api } from 'lwc';

export default class LogButtonConfigCPE extends LightningElement {
    @api label;                             // "Check In" or "Check Out"
    @api buttonLabel = '';                  // User-defined label
    @api includeBGName = false;             // Checkbox value
    @api buttonAction = '';                 // Action when unavailable

    // Action options
    get actionOptions() {
        return [
            { label: 'Hide Button if Not Available', value: 'Hide' },
            { label: 'Disable Button if Not Available', value: 'Disable' },
        ];
    }

    // Handle Button Label Change
    handleLabelChange(event) {
        this.buttonLabel = event.target.value;
        this.dispatchValueChange('buttonLabel', this.buttonLabel);
    }

    // Handle Include Board Game Name Checkbox Change
    handleIncludeBGNameChange(event) {
        this.includeBGName = event.target.checked;
        this.dispatchValueChange('includeBGName', this.includeBGName);
    }

    // Handle Action Selection Change
    handleActionChange(event) {
        this.buttonAction = event.detail.value;
        this.dispatchValueChange('buttonAction', this.buttonAction);
    }

    // Dispatch Changes to Parent
    dispatchValueChange(attribute, value) {
        this.dispatchEvent(new CustomEvent('btnconfigchange', {
            detail: {
                attribute,
                value
            }
        }));
    }
}