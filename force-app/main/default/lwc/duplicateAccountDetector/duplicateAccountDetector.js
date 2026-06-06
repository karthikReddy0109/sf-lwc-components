import { LightningElement, api } from 'lwc';
import getDuplicateAccounts from '@salesforce/apex/DuplicateAccDetectorController.getDuplicateAccounts';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';
import {NavigationMixin } from 'lightning/navigation';
export default class DuplicateAccountDetector extends NavigationMixin(LightningElement) {
    @api accountName;
    searchText;
    isChecking = false;
    duplicateAccounts;
    searchTimeout;
    @api proceedAnyway = false;
    async executeSearch(){
        try{
            const searchResults = await getDuplicateAccounts({searchText: this.searchText});
            this.duplicateAccounts = searchResults.length > 0 ? searchResults : [];
            this.isChecking = false;
        }catch(e){
            console.error(e);
        }
        
    }

    handleAccountNameChange(e){
        this.isChecking = true;
        this.searchText = e.target.value;
        this.accountName = e.target.value;
        if(!this.searchText || this.searchText.length === 0){
            this.isChecking = false;
            this.duplicateAccounts = [];
            return;
        }
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.executeSearch();
        }, 300);
    }

    get hasDuplicates(){
        return this.duplicateAccounts && this.duplicateAccounts.length > 0;
    }

    get noDuplicates(){
        return this.duplicateAccounts && this.duplicateAccounts.length === 0;
    }

    @api validate(){
        if(this.duplicateAccounts && this.duplicateAccounts.length > 0 && !this.proceedAnyway){
            return{
                isValid: false,
                errorMessage: 'Please review duplicate accounts before proceeding'
            };
        }
        return{isValid: true};
    }

    handleCreateAnyway(){
        this.proceedAnyway = true;
        //Fire - Flow next navigation
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleView(e){
        const accountId = e.currentTarget.dataset.id;
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: accountId,
        //         actionName: 'view'
        //     }
        // }) 
        window.open('/' + accountId, '_blank');
    }
}