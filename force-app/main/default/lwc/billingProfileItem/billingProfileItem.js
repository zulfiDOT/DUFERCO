import { LightningElement, api } from 'lwc';

export default class BillingProfileItem extends LightningElement {
    @api item;
    @api formaAnagrafica;
    
    handleClick(){
        this.dispatchEvent(new CustomEvent('selected',{detail : {selectedItem : this.item}}));
    }
    get isPA(){
        return this.formaAnagrafica == 'PA';
    }
}