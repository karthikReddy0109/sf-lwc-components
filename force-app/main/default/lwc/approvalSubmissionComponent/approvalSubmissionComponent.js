import { LightningElement, api, wire } from 'lwc';
import getPODetails from '@salesforce/apex/ApprovalSubmissionController.getPODetails';
import submitRecordForApproval from '@salesforce/apex/ApprovalSubmissionController.submitRecordForApproval';
import {FlowNavigationFinishEvent} from 'lightning/flowSupport';

export default class ApprovalSubmissionComponent extends LightningElement {
    @api recordId;
    @api availableActions;
    poDetails;
    poDetailsErrorMsg;
    isLoading = false;
    comments;
    isSubmissionSuccess = false;
    isSubmitted = false;
    connectedCallback(){
        console.log('recordId received: ' + this.recordId);
    }
    @wire(getPODetails, {recordId: '$recordId'})
    wiredResult(response){
        console.log('recordId received: ' + this.recordId);
        console.log('response: ' + JSON.stringify(response));
        const {data, error} = response;
        if(data){
           this.poDetails = data; 
        }else if(error){
            this.poDetailsErrorMsg = error;
        }
    }

    get isAlreadyPending(){
        return this.poDetails && this.poDetails.isAlreadyPending;
    }

    async submitForApproval(){
        try{
            const result = await submitRecordForApproval({recordId: this.recordId, comments: this.comments});
            if(result.success){
                this.isSubmissionSuccess = true;
                setTimeout(() => {
                    this.dispatchEvent(new FlowNavigationFinishEvent());
                }, 2000);
            }else{
                this.isSubmissionSuccess = false;
            }
        }catch(error){
            console.error(error);
        }finally{
            this.isLoading = false;
        }
    }

    async handleSubmit(){
        this.isLoading = true;
        await this.submitForApproval();
        this.isLoading = false;
    }

    get submitButtonLabel(){
        return this.isLoading ? "Submitting..." : "Submit for Approval";
    }

    handleCommentsChange(e){
        this.comments = e.target.value;
    }

    get showComments(){
        return !this.isSubmissionSuccess;
    }

    get name() {
        return this.poDetails?.name ?? 'NA';
    }

    get amount() {
        return this.poDetails?.amount ?? 'NA';
    }

    get status() {
        return this.poDetails?.status ?? 'NA';
    }

    get createdBy() {
        return this.poDetails?.createdBy ?? 'NA';
    }

    get createdDate() {
        return this.poDetails?.createdDate ?? 'NA';
    }

    get isSubmitDisabled() {
        return this.isAlreadyPending || this.isLoading || this.isSubmissionSuccess;
    }
}