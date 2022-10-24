import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
export default class RetrieveRecordType extends LightningElement {
    @api recordId;
    @api objectApiName = 'Account';
    @track objectInfo;
    @track optionList=[];
    @api value;
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    getRecordType({error,data}) {
        if(data){
            console.log('Data '+data );
            for (const key in data.recordTypeInfos) {
                if(data.recordTypeInfos[key].name!='Master'){
                    this.optionList.push({ "label": data.recordTypeInfos[key].name, "value": key});
                }                
            }
            console.log('OptionList '+this.optionList );    
        }else if(error){
            console.log('error');
        }
        
    }

    selectHandler(event) {
        const selectEvent = new CustomEvent('selected', {
            detail: event.target.value
        });
        // 3. Fire the custom event
        this.dispatchEvent(selectEvent);
    }
    
    get options() {
        return [
            { label: 'Sales', value: 'option1' },
            { label: 'Force', value: 'option2' },
        ];
    }
}