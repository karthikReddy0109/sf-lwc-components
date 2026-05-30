import { LightningElement, api, wire } from 'lwc';
import getApprovalDetails from '@salesforce/apex/ApprovalActionController.getApprovalDetails';
import userId from '@salesforce/user/Id';
import processApproval from '@salesforce/apex/ApprovalActionController.processApproval'

export default class PurchaseOrderApproval extends LightningElement {
    @api recordId;
    currentUserId = userId;
    approvalDetails;
    wiredResult;
    isApproved;
    showModal = false;
    pendingAction;
    @wire(getApprovalDetails, {recordId : '$recordId'})
    wiredDetails(result){
        this.wiredResult = result;
        const {data, error} = result;
        if(data){
            this.approvalDetails = data;
            console.log('Data :' + JSON.stringify(data));
        }else{
            console.log('Error ' + error);
        }
    }

    get hasTimeline(){
        return this.approvalDetails && this.approvalDetails.previousSteps.length > 0;
    }

    get isApprover(){
        return this.approvalDetails && this.approvalDetails.isCurrentApprover;
    }

    get currentStatus(){
        if(this.approvalDetails && this.approvalDetails.currentStatus){
            return this.approvalDetails.currentStatus;
        }
        return 'NA';
    }

    get currentApprover(){
        if(this.approvalDetails && this.approvalDetails.currentApprover){
            return this.approvalDetails.currentApprover;
        }
        return 'No Pending Approver';
    }

    handleReject(){
        this.showModal = true;
        this.pendingAction = 'Reject';
    }

    handleApprove(){
        this.showModal = true;
        this.pendingAction = 'Approve';
    }

    async confirmFromApex(){
        const result = await processApproval({recordId : this.recordId, isApproved : this.isApproved});
    }

    handleConfirm(){
        this.isApproved = true;
        this.confirmFromApex();
        this.showModal = false;
    }

    handleCancel(){
        this.isApproved = false;
        this.confirmFromApex();
        this.showModal = false;
    }
}

