import { LightningElement, api } from 'lwc';

export default class CreateNewCase extends LightningElement {
    @api caseType;
    @api subject = '';
    @api description = '';
    @api priority = '';
    @api productVersion = '';
    @api invoiceNumber = '';
    @api amountDisputed = '';

    validateTechnicalFields(){
        if(this.priority === '' || this.productVersion === ''){
            return { isValid: false, errorMessage: 'Fill all fields' }
        };
        return {isValid: true}; 
    }

    validateBillingFields(){
        if(this.invoiceNumber === '' || this.amountDisputed === ''){
            return { isValid: false, errorMessage: 'Fill all fields' }
        };
        return {isValid: true}; 
    }


    @api validate(){
        if(this.caseType === 'Technical'){
            return this.validateTechnicalFields();
        }else if(this.caseType === 'Billing'){
            return this.validateBillingFields();
        }
    }

    get isTechnical(){
        return this.caseType === 'Technical';
    }

    get isBilling(){
        return this.caseType === 'Billing';
    }

    get priorityOptions() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Medium', value: 'Medium' },
            { label: 'Low', value: 'Low' },
        ];
    }

    handleFieldChange(e){
        const field = e.target.dataset.field;
        this[field] = e.target.value;
    }
    
}