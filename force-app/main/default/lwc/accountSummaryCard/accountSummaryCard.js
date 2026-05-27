import { LightningElement, api, wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccountSummary from '@salesforce/apex/AccountSummaryController.getAccountSummary'

export default class AccountSummaryCard extends LightningElement {
    @api recordId;
    isLoading = true;
    accountData;
    errorMsg;
    wiredResult;
    @wire(getAccountSummary, {recordId : '$recordId'})
    wiredAccount(result){
        this.wiredResult = result;
        const{data, error} = result;
        if(data){
            this.accountData = data;
            this.errorMsg = undefined;
            this.isLoading = false;
        }
        if(error){
            this.errorMsg = error?.body?.message || 'An error occurred';
            this.accountData = undefined;
            this.isLoading = false;
        }
    }

    handleRefresh(){
        this.isLoading = true;
        refreshApex(this.wiredResult)
    }
}