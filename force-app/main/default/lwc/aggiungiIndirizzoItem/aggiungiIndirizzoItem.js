import { LightningElement, api } from 'lwc';

export default class AggiungiIndirizzoItem extends LightningElement {

    @api item;

    handleClick(){
        this.dispatchEvent(new CustomEvent('selected',{detail : {selectedItem : this.item}}));
    }
}