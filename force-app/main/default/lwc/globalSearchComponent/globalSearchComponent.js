import { LightningElement } from 'lwc';
import userId from '@salesforce/user/Id';
import getSearchResults from '@salesforce/apex/GlobalSearchController.getSearchResults';
export default class GlobalSearchComponent extends LightningElement {
    currentUserId = userId;
    searchTerm;
    searchTimeout;
    accounts;
    contacts;
    leads;
    async executeSearch(){
        try{
            const searchResults = await getSearchResults({searchTerm : this.searchTerm});
            this.accounts = searchResults.accounts || [];
            this.contacts = searchResults.contacts || [];
            this.leads = searchResults.leads || [];
        }catch(error){
            console.log(error);
        }
    }
    handleChange(event){
        this.searchTerm = event.target.value;
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.executeSearch();
        }, 300);
    }

    get hasAccounts(){
        return this.accounts && this.accounts.length > 0;
    }

    get hasContacts(){
        return this.contacts && this.contacts.length > 0;
    }

    get hasLeads(){
        return this.leads && this.leads.length > 0;
    }

}