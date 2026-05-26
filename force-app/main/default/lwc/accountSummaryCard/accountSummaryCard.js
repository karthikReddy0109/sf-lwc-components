import { LightningElement, api, wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccountSummary from '@salesforce/apex/AccountSummaryController.getAccountSummary'

export default class AccountSummaryCard extends LightningElement {
    @api recordId;
    accountData;
    wiredResult;
    @wire(getAccountSummary, {recordId : '$recordId'})
    wiredAccount(result){
        this.wiredResult = result;
        const{data, error} = result;
        if(data){
            this.accountData = data;
            console.log(JSON.stringify(data));
        }
        if(error){
            console.log(error);
        }
    }
    connectedCallback(){
        console.log("Record ID : " + this.recordId);
    }
    handleRefresh(){
        refreshApex(this.wiredResult)
    }
}