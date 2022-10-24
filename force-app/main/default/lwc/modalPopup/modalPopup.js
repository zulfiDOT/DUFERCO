import { api, LightningElement, track } from 'lwc';

export default class LWCModalBoxDemo extends LightningElement {
    @track openmodel = true;
    @track recordType;
    isRecordType = true;
    nextBtn = true;
    @api invoke() {
        console.log('Hello, world!');
      }
    //rightButton = nextButton;
    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    }
    onPrevious(){
        this.isRecordType = true;
    }
    onNext(){
        if (this.recordType) {
            this.isRecordType = false; 
        }
    }
    handleSelected(event){
        this.recordType = event.detail;
        this.nextBtn = false;
    }
    saveMethod(event) {
        console.log('Sono nel parent');

        this.template.querySelector('c-account-form').handleSubmit();
        
        //this.closeModal();
    }
}