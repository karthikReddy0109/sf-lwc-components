import { LightningElement, api } from 'lwc';

export default class AccountOnboardingReview extends LightningElement {
    @api accountName;
    @api industry;
    @api phone;
    @api billingStreet;
    @api city;
    @api state;
    @api country;
}