import { LightningElement, wire, api } from 'lwc';
import getContacts from '@salesforce/apex/ContactInlineEditController.getContacts';
import updateContacts from '@salesforce/apex/ContactInlineEditController.updateContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from 'lightning/uiRecordApi';

export default class ContactListComponent extends LightningElement {
    columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email', editable: true },
    { label: 'Phone', fieldName: 'Phone', editable: true },
    { label: 'Title', fieldName: 'Title' }
    ];
    @api recordId;
    contactList;
    draftValues;
    contactResult;
    @wire(getContacts, {recordId : '$recordId'})
    wiredContacts(result){
        this.contactResult = result;
        const{data, error} = result;
        if(data){
            this.contactList = data;
        }
        else if(error){
            console.log(error);
        }
    }

    showSucessToastEvent(){
        const toastEvent = new ShowToastEvent({
            title : 'Success',
            message: 'Contacts updated successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvent);
    }

    showErrorToastEvent(){
        const errorToastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'An error occurred while updating contacts',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(errorToastEvent);
    }

    async saveModifiedContacts(){
        try{
            const result = await updateContacts({contacts : this.draftValues});
            this.showSucessToastEvent();
            this.draftValues = [];
            await refreshApex(this.contactResult); 
        }catch(error){
            this.showErrorToastEvent();
            console.log(error);
        }
    }

    handleSave(event){  
        this.draftValues = event.detail.draftValues;
        this.saveModifiedContacts();
    }
}