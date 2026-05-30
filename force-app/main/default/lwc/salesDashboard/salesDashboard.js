import { LightningElement, wire } from 'lwc';
import getTotalOpenPipeline from '@salesforce/apex/SalesDashboardController.getTotalOpenPipeline';
import getDealsClosingThisMonth from '@salesforce/apex/SalesDashboardController.getDealsClosingThisMonth';
import getTopRepThisQuarter from '@salesforce/apex/SalesDashboardController.getTopRepThisQuarter';
import getAvgDealSize from '@salesforce/apex/SalesDashboardController.getAvgDealSize';

export default class SalesDashboard extends LightningElement {
    isPipelineLoading = true;
    isClosingDealsLoading = true;
    isTopRepLoading = true;
    isAvgDealsLoading = true;
    totalPipeline;
    closingDeals;
    topRep;
    avgDealSize;
    refreshInterval;
    lastRefreshed;
    async loadAllKPIs(){
        this.isPipelineLoading = true;
        this.isClosingDealsLoading = true;
        this.isTopRepLoading = true;
        this.isAvgDealsLoading = true;
        try{
            const[pipeline, closingDeals, topRep, avgDeal] = await Promise.all([
                getTotalOpenPipeline(),
                getDealsClosingThisMonth(),
                getTopRepThisQuarter(),
                getAvgDealSize()
            ])
            this.totalPipeline = pipeline;
            this.closingDeals = closingDeals;
            this.topRep = topRep;
            this.avgDealSize = avgDeal;
            this.lastRefreshed = new Date().toLocaleTimeString();
        }catch(error){
            console.error(error);
        }finally{
            this.isPipelineLoading = false;
            this.isClosingDealsLoading = false;
            this.isTopRepLoading = false;
            this.isAvgDealsLoading = false;
        }
    }

    connectedCallback(){
        this.loadAllKPIs();
        this.refreshInterval = setInterval(() => {
            this.loadAllKPIs();
        }, 60000);
    }

    disconnectedCallback(){
        clearInterval(this.refreshInterval);
    }

    get formattedPipeline(){
        return this.totalPipeline ?  '$' + this.totalPipeline.toLocaleString() : '-'; 
    }

    get formattedAvgDealSize(){
        return this.avgDealSize ? '$' + this.avgDealSize : '-';
    }

    get formattedTopRepAmount(){
        return this.topRep?.amount ? '$' + this.topRep.amount.toLocaleString() : '-';
    }

    get topRepName(){
        return this.topRep ? this.topRep.name : 'No Top Rep';
    }

    handleManualRefresh(){
        this.loadAllKPIs();
    }
}