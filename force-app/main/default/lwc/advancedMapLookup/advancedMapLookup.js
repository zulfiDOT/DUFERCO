import { LightningElement, track, api } from "lwc";
import placeSearch from "@salesforce/apex/AddressSearchController.placeSearch";
import addressComponent from "@salesforce/apex/AddressSearchController.getAddressComponent";
import { updateRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// import API_GOOGLE from '@salesforce/resourceUrl/googleApi';
// import { loadScript } from 'lightning/platformResourceLoader';

export default class AdvancedMapLookup extends LightningElement {
  @track errors = [];
  @api notifyViaAlerts = false;
  @api recordId;
  @api isEditMode = false;
  isLoading = false;
  googleApi;

  handleSearch(event) {
    let searchKey = event.detail.searchTerm;
    //console.log("#####" + JSON.stringify(event.detail.searchTerm));
    placeSearch({ searchPhrase: searchKey })
      .then(results => {
        this.template.querySelector("c-lookup").setSearchResults(results);
      })
      .catch(error => {
        this.notifyUser(
          "Lookup Error",
          "An error occured while searching with the lookup field.",
          "error"
        );
        // eslint-disable-next-line no-console
        console.error("Lookup error", JSON.stringify(error));
        this.errors = [error];
      });
  }

  notifyUser(title, message, variant) {
    if (this.notifyViaAlerts) {
      // eslint-disable-next-line no-alert
      alert(`${title}\n${message}`);
    } else {
      const toastEvent = new ShowToastEvent({ title, message, variant });
      this.dispatchEvent(toastEvent);
    }
  }

  handleSelectionChange(event) {
    this.errors = [];
    if (!event.detail) {
      return;
    }
    var response;
    var selectedItem = event.detail.selectedItem;
    addressComponent({placeId : selectedItem.id})
    .then(results => {
      //console.log(results);
      response = JSON.parse(results);
      this.handleAddressComponent(response.result);    
    })
    .catch(error =>{
      console.error(error);
      response = JSON.parse(results);
    })
  }

  checkForErrors() {
    const selection = this.template.querySelector("c-lookup").getSelection();
    if (selection.length === 0) {
      this.errors = [
        { message: "You must make a selection before submitting!" },
        { message: "Please make a selection and try again." }
      ];
    } else {
      this.errors = [];
    }
  }

  handleSubmit() {
    const options = {
      componentRestrictions: { country: "us" },
      fields: ["address_components", "geometry", "icon", "name"],
      strictBounds: false,
      types: ["establishment"],
    };
    const input = 'Via Roma';
    const autocomplete = new google.maps.places.Autocomplete(input, options);
    console.log('Stampa autocomplete'+autocomplete);
    const place = autocomplete.getPlace();
    console.log('Stampa place '+place);
    this.checkForErrors();
    if (this.errors.length === 0) {
      this.notifyUser("Success", "The form was submitted.", "success");
    }
  }

  handleAddressComponent(result){
    var address = {"street_number":"",
                    "route":"",
                    "postal_code":"",
                    "locality":"",
                    "province":"",
                    "country":""};
    for (const component of result.address_components) {
      const componentType = component.types[0];
  
      switch (componentType) {
        case "street_number": {
          address["street_number"] = component.long_name;
          break;
        }
        case "route": {
          address["route"] = component.short_name;
          break;
        }
        case "postal_code": {
          address["postal_code"] = component.long_name;     
          break;
        }
        case "postal_code_suffix": {
          //postcode = `${postcode}-${component.long_name}`;
          break;
        }
        case "locality":
          address["locality"] = component.long_name;
          break;
        case "administrative_area_level_1": {
          //document.querySelector("#state").value = component.short_name;
          break;
        }
        case "administrative_area_level_2": {
          address["province"] = component.short_name;
          break;
        }
        case "administrative_area_level_3": {
          address["city"] = component.long_name;
          break;
        }
        case "country":
          address["country"] = component.long_name; 
          break;
      }
    }
    console.log(address);
    if (address.country && address.country != 'Italia') {
        address.city = address.locality;
        address.locality = '';
    }

    if (this.isEditMode) {
      this.updateAddress(address);
    }else{
      this.dispatchEvent(new CustomEvent('selectaddress', {
        detail: {
                    address: address
                }
        }));
    }
  }

  updateAddress(address){

    this.isLoading = true;
        var fields = {};
        var recordInput = {};
        fields["Id"] = this.recordId;
        fields["StreetName__c"] = address.route;
        fields["StreetNumber__c"] = address.street_number;
        fields["Province__c"] = address.province;
        fields["City__c"] = address.city;
        fields["Hamlet__c"] = address.locality != address.city ? address.locality : '';
        fields["ZipCode__c"] = address.postal_code;
        fields["Country__c"] = address.country;
        recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Operazione completata',
                        message: 'Indirizzo modificato correttamente',
                        variant: 'success'
                    })
                );   
                this.isLoading = false;
                getRecordNotifyChange([{recordId: this.recordId}]);
            }
        ).catch(error => {
            this.notifyUser(
                    'Errore',
                    error.body.message,
                    'error'
            )
        });
        this.isLoading = false;
  }


  // renderedCallback() {
  //   loadScript(this, API_GOOGLE)
  //   .then(() => {
  //     //this.template.querySelector('lightning-button').addEventListener('click', Autocomplete.bind(this));
  //     console.log('Success');
  //   })
  //   .catch((error) => {
  //     console.log('Error '+error);
  //   });
  // }
}