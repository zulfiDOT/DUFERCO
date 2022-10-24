import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecordUi } from 'lightning/uiRecordApi';
import { getRecordCreateDefaults } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import fetchRecordTypeValues from '@salesforce/apex/RecordTypeSelector.fetchRecordTypeValues';
import accFieldSet from '@salesforce/apex/RecordTypeSelector.getFieldSet';
import { updateRecord } from 'lightning/uiRecordApi';

export default class RecordForm extends LightningElement {
    @track listRt=[];     //list of recordt types
    jsonRt={};
    @track configValues = {};
    @track configVal = '';

    @api recordTypeId;    //fields to store record type Id
    @api rtName;
    @track recordIdCopy;
    recTypeName;

    //fields boolen to control rendering
    @track cargado = false;      
    @track isLoading = false;
    @track checkcampiform = true;
    hasRendered = false;
    bLoading = true;

    @api recordId;                  //  Id del registro obtenido desde el layout
    @api objectApiName;             //  Api name del objetoobtenido desde el layout
    @api fieldsValueStep1           // Campi valorizzati nello step 1     
    @api isNew;

    @track infoSectionsLayout;      //structures to storage the form
    inputsInForm = new Map();
    sectionsInForm = new Map();
    @track formulario={};
    @track activeSections = [];
    loadRules = true;

    _response;

    //maps with data types 
    dataTypePicklists = new Map();
    dataTypeTexts = new Map();
    dataTypeDouble = new Map();
    dataTypeDate = new Map();
    dataTypeDatetime = new Map();
    dataTypeBoolean = new Map();
    dataTypePercent = new Map();
    dataTypeMultipicklist = new Map();
    dataTypeTextarea = new Map();
    dataTypeTime = new Map();
    dataTypeReference = new Map();
    dataTypeAllFields = new Map();
    dependences = new Map();
    dependent = new Map();

    queueFieldUpdate =[]; 
    
    hiddenFields;           
    rules ={};
    configuration={};

    // @wire(fetchRecordTypeValues, { objectName: '$objectApiName' })
    //  getRecordTypes({ data, error }) {
    //     if(!this.recordId){
    //         if(data){
    //             console.log(JSON.stringify(data));
    //             this.jsonRt = data;
    //             for(var rt in  data){
    //                 if(this.recordTypeId == '')
    //                 {
    //                     this.recordTypeId =rt;
                       
    //                 }
                    
    //                 console.log(rt);
    //                 console.log(data[rt]);

    //                 var option = {};
    //                 option.label = data[rt];
    //                 option.value = rt;
    //                 this.listRt.push(option);
    //             }
    //             this.recTypeName = this.jsonRt[this.recordTypeId];
    //             this.cargado = true;
    //         }else if(error){
    //             console.log('objectApiName es ' + this.objectApiName);
    //             console.log(JSON.stringify(error));
    //         }
    //     }
    //     else{
    //         console.log('estamos en modo edit');
    //     }

    // }
    @wire(accFieldSet, { rType: '$rtName' })
     getAccFieldSet({ data, error }) {
        if (data) {
            this.hiddenFields = data;
        } else if (error) {
            console.error(error);
        }
     }

     
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objInfo({ data, error }) {
        if (data) {
            console.log('Inicializando getObjectInfo...');

            Object.values(data.fields).forEach((fld) => {
                let { apiName, dataType, length, precision, scale, calculated, label, updateable } = fld;
                let object = { apiName, dataType, length, precision, scale, calculated, label, updateable };
                //  Comprobamos el tipo de registro que se trata el campo
                if(fld.dataType === "String"){
                    this.dataTypeTexts.set(apiName, object);
                } else if(fld.dataType === "Picklist"){
                    this.dataTypePicklists.set(apiName, object);
                } else if(fld.dataType === "Double") {
                    this.dataTypeDouble.set(apiName, object);
                } else if(fld.dataType === "Date"){
                    this.dataTypeDate.set(apiName, object);
                } else if(fld.dataType === "Datetime"){
                    this.dataTypeDatetime.set(apiName, object);
                } else if(fld.dataType === "Time"){
                    this.dataTypeTime.set(apiName, object);
                } else if(fld.dataType === "Boolean") {
                    this.dataTypeBoolean.set(apiName, object);
                } else if(fld.dataType === "Percent") {
                    this.dataTypePercent.set(apiName, object);
                } else if(fld.dataType === "Multipicklist") {
                    this.dataTypeMultipicklist.set(apiName, object);
                } else if(fld.dataType === "TextArea") {
                    this.dataTypeTextarea.set(apiName, object);
                } else if(fld.dataType === "Reference") {
                    this.dataTypeReference.set(apiName, object);
                }

                this.dataTypeAllFields.set(apiName, object);
                
            });
            console.log('this.recordIdCopy = this.recordId');
                this.recordIdCopy = this.recordId;
               
            console.log('Finalizado getObjectInfo...');
        } else if(error) {;
            let msgError = 'Error mientras cargaba la información del objeto asociado';
            this.showToastEvent("ERROR", msgError, 'error', 'sticky'); 
        }
    }

    @wire(getRecordUi, { recordIds: '$recordIdCopy', layoutTypes: 'Full', modes: 'Edit'})
    dcrRecordUi(response) {
        var listLayout;
        var LayoutSection;
        var SectionList = [];
        var FieldList = [];
        this._response = response;
        let error = response && response.error;
        let data = response && response.data;

        
        this.isLoading = true;
        
        if (data && !this.isNew) {
            console.log('Inicializando dcRecordUi...');

            var record = data.records[this.recordId];
            LayoutSection = {};
            LayoutSection.id = 'aux';
            LayoutSection.heading = 'campos auxiliares';
            LayoutSection.fakeFields = true; 
            LayoutSection.show = false; 
            LayoutSection.lstFields = [];
            SectionList.push(LayoutSection);


            if(record.recordTypeInfo)
            {
                this.recordTypeId = record.recordTypeId;
                console.log(this.recordTypeId);
                var rtName = record.recordTypeInfo.name;
                this.recTypeName = rtName;
                //this.getRtRules(rtName);
            }
            else
            {
                console.log('getRtRules para master');
                //this.getRtRules('Master');
                this.recTypeName = 'Master';
            }
            

            listLayout = data.layouts[this.objectApiName][Object.keys(data.layouts[this.objectApiName])].Full.Edit.sections;
  
            this.sectionsInForm = {};
            for (let i = 0; i < listLayout.length; i++) {

                var count = 0;
                
                LayoutSection = {};
                FieldList = [];
                LayoutSection.id = listLayout[i].id;
                LayoutSection.show = true;
                LayoutSection.fakeFields = false; 
                LayoutSection.heading = listLayout[i].heading;
                let section = listLayout[i].heading;
                this.sectionsInForm[section] = [];




                for (let j = 0; j < listLayout[i].layoutRows.length; j++) {
                    var boleanoColumnas = true;

                    for (let k = 0; k < listLayout[i].layoutRows[j].layoutItems.length; k++) {
                    
                       
                        var layoutItem = listLayout[i].layoutRows[j].layoutItems[k];
                        
                        for (let l = 0; l < layoutItem.layoutComponents.length; l++) {
                            var layoutComponent = layoutItem.layoutComponents[l];
                            var apiNamef = layoutComponent.apiName;
                            
                            let field = data.records[this.recordId].fields[apiNamef];
                            if(field){
                                var Field = {};
                                
                                Field = this.getField(layoutItem, layoutComponent, 'update');
                                Field.fieldValue = field.value;
                                
                                Field.metadata.computedIsReadOnly = this.filtrolwc(Field.apiName, Field.isReadOnly, Field.fieldValue);
                                this.formulario[apiNamef] ={"value": field.value, "seccion": i+1, "posicion":count};
                                Field[apiNamef]={"fieldValue": field.value};
                                count = count +1;
                                Field.boleanoColumnas =boleanoColumnas;
                                Field.key='0000'+i+j+k+l;
                                
                                if (apiNamef !== undefined || apiNamef != null){
                                    this.sectionsInForm[section].push(apiNamef);
                                }
                                
                                FieldList.push(Field);
                            }
                        }
                        boleanoColumnas = !boleanoColumnas;
                    }
                }
                LayoutSection.lstFields = FieldList;
                SectionList.push(LayoutSection);
                
            } 
            if (SectionList) {
                this.infoSectionsLayout = SectionList;
            }
            
            console.log('Finalizado dcRecordUi...');
        }
        this.isLoading = false;
    
    }

    @wire(getRecordCreateDefaults, { objectApiName: '$objectApiName', recordTypeId:'$recordTypeId'})
    dcrRecordCreateUi(response) {

        var listLayout;
        var LayoutSection;
        var SectionList = [];
        var actSections = [];
        let error = response && response.error;
        let data = response && response.data;
        var Field;
        var FieldList = [];
        var timestamp = Date.now();
        
        

        console.log('Inicializando dcrRecordCreateUi...');
        console.log('recordTypeId ' + this.recordTypeId);
        this.isLoading = true;
        this.checkcampiform = true;
        if (data && this.isNew) {
            this.formulario ={};

            console.log('Inicializando dcRecordUi...');
            
            if(!this.rules){
                LayoutSection = {};
                LayoutSection.id = 'aux';
                LayoutSection.heading = 'campos auxiliares';
                LayoutSection.show = true; 
                LayoutSection.fakeFields = true; 
                LayoutSection.lstFields = [];
                SectionList.push(LayoutSection);
            }
            else{
                LayoutSection = {};
                LayoutSection.id = 'aux';
                LayoutSection.heading = 'campos auxiliares';
                LayoutSection.show = true; 
                LayoutSection.fakeFields = true; 
                LayoutSection.lstFields = [];
                if(this.configuration && this.configuration.fields)
                {
                    for(var i=0; i<this.configuration.fields.length; i++)
                    {
                        LayoutSection.lstFields.push(this.configuration.fields[i]);
                        this.formulario[this.configuration.fields[i].apiName] = {"posicion":i, "seccion": 0, "value": this.configuration.fields[i].fieldValue};

                    }
                }
                SectionList.push(LayoutSection);
            }

                // if(this.recordTypeId && this.recordTypeId !='')
                // {
                //     console.log(this.recordTypeId);
                //     var rtName = this.jsonRt[this.recordTypeId];
                //     //this.getRtRules(rtName);
                //     this.recTypeName = rtName;
                // }
                // else
                // {
                //     console.log('getRtRules para master');
                //     //this.getRtRules('Master');
                //     this.recTypeName = 'Master';
                // }
            

            var listLayout = data.layout.sections;

            this.sectionsInForm = {};

            for (let i = 0; i < listLayout.length; i++) {
                var hideAllFieldOfSection = true;
                var count = 0;
  
                LayoutSection = {};
                FieldList = [];
                LayoutSection.id = listLayout[i].id;
                
                LayoutSection.heading = listLayout[i].heading;
                actSections.push(LayoutSection.heading);
                LayoutSection.show = true;

                let section = listLayout[i].heading;
                this.sectionsInForm[section] = [];

                for (let j = 0; j < listLayout[i].layoutRows.length; j++) {
                    var boleanoColumnas = true;

                    for (let k = 0; k < listLayout[i].layoutRows[j].layoutItems.length; k++) {
                    
                       
                        var layoutItem = listLayout[i].layoutRows[j].layoutItems[k];
                        
                        for (let l = 0; l < layoutItem.layoutComponents.length; l++) {
                            var layoutComponent = layoutItem.layoutComponents[l];
                            console.log(JSON.stringify(layoutComponent));
                            var apiNamef = layoutComponent.apiName;
                            
                            if(layoutComponent.componentType != 'EmptySpace'){ //check empty section

                                Field = this.getField(layoutItem, layoutComponent, 'new');
                                Field.fieldValue = Field.metadata.isBoolean ? false : '';
                                this.formulario[apiNamef] ={"value": '', "seccion": i+1, "posicion":count};
                                Field[apiNamef]={"fieldValue": ''};

                                if(this.fieldsValueStep1[Field.apiName]){
                                    Field[apiNamef].fieldValue = this.fieldsValueStep1[Field.apiName].value ? this.fieldsValueStep1[Field.apiName].value : this.fieldsValueStep1[Field.apiName];
                                    Field.fieldValue = Field[apiNamef].fieldValue;
                                    
                                    Field.metadata.computedIsReadOnly = this.filtrolwc(Field.apiName, Field.isReadOnly, Field.fieldValue);
                                }
                                count = count +1;
                                Field.boleanoColumnas =boleanoColumnas;
                                Field.key='0000'+i+j+k+l;
                                if (hideAllFieldOfSection) {
                                    hideAllFieldOfSection = Field.metadata.isHide;
                                }
                                if (apiNamef !== undefined || apiNamef != null){
                                    this.sectionsInForm[section].push(apiNamef);
                                }
                            
                                FieldList.push(Field);
                            }
                        }
                        boleanoColumnas = !boleanoColumnas;
                    }
                }
                //if (!hideAllFieldOfSection) {
                    LayoutSection.show = !hideAllFieldOfSection;
                    LayoutSection.lstFields = FieldList;
                    SectionList.push(LayoutSection);
                //}   
            }
            
            if (SectionList) {
                this.infoSectionsLayout = SectionList;
                this.activeSections = actSections;//handle open accordion
                this.hasRendered = true;              
                //this.doAllActions();
                
                /*
                if(this.rules)
                {
                    this.doAllActions();
                }*/
            }
            
            console.log('Finalizado dcRecordUi...');
            
        }
        this.isLoading = false;
        console.log('Finalizando dcrRecordCreateUi...');
    }

    handleField(evt) {
        
        console.log(evt.target.fieldName);
        console.log(evt.target.value);
        console.log(evt.target.checked);
  
        var  fieldName = evt.target.fieldName;
        var fieldValue = evt.target.checked;

        if(!fieldName)
            fieldName = evt.target.name;

        if(!fieldValue)
            fieldValue = evt.target.value;

        
        var seccion = this.formulario[fieldName].seccion;
        var posicion = this.formulario[fieldName].posicion;
  
        this.infoSectionsLayout[seccion].lstFields[posicion].fieldValue = fieldValue;
        ((this.infoSectionsLayout[seccion].lstFields[posicion])[fieldName]).fieldValue =  fieldValue;
  
        this.doTheWork(fieldName);

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.reportValidity();
        }, true);

        if (isInputsCorrect) {  
          this.checkcampiform = false;
        }else{
          this.checkcampiform = true;
        }

    }

    getField(layoutItem, layoutComponent, mode){
        var Field = {};
        var apiNamef = layoutComponent.apiName;

        Field.apiName = apiNamef;
        Field.ts = Date.now();
        if(mode == 'update')
        {
            Field.isReadOnly = !layoutItem.editableForUpdate;
        }
        else if (mode == 'new')
        {
            Field.isReadOnly = !layoutItem.editableForNew;
        }

        Field.isRequired = layoutItem.required;

        Field.metadata = this.dataTypeAllFields.get(apiNamef);

        if (Field.metadata) {

            if(Field.metadata.dataType == 'Address'){
                Field.metadata.isAddress = true;
            }
            else if(Field.metadata.dataType == 'Base64')
                Field.metadata.isBase64 = true;
            else if(Field.metadata.dataType == 'Boolean')
                Field.metadata.isBoolean = true;
            else if(Field.metadata.dataType == 'ComboBox')
                Field.metadata.isComboBox = true;
            else if(Field.metadata.dataType == 'Currency')
                Field.metadata.isCurrency = true;
            else if(Field.metadata.dataType == 'Date')
                Field.metadata.isDate = true;
            else if(Field.metadata.dataType == 'DateTime')
                Field.metadata.isDateTime = true;
            else if(Field.metadata.dataType == 'Double')
                Field.metadata.isDouble = true;
            else if(Field.metadata.dataType == 'Email')
                Field.metadata.isEmail = true;
            else if(Field.metadata.dataType == 'Int')
                Field.metadata.isInt = true;
            else if(Field.metadata.dataType == 'Location')
                Field.metadata.isLocation = true;
            else if(Field.metadata.dataType == 'MultiPicklist')
                Field.metadata.isMultiPicklist = true;
            else if(Field.metadata.dataType == 'Percent')
                Field.metadata.isPercent = true;
            else if(Field.metadata.dataType == 'Phone')
                Field.metadata.isPhone = true;
            else if(Field.metadata.dataType == 'Picklist')
            {
                Field.metadata.isPicklist = true;
            }
            else if(Field.metadata.dataType == 'Reference')
            {
                Field.metadata.isReference = true;
            } 
            else if(Field.metadata.dataType == 'String')
                Field.metadata.isString = true;
            else if(Field.metadata.dataType == 'TextArea')
                Field.metadata.isTextArea = true;
            else if(Field.metadata.dataType == 'Time')
                Field.metadata.isTime = true;
            else if(Field.metadata.dataType == 'Url')
            {
                Field.metadata.isUrl = true;
            }

            Field.metadata.computedIsReadOnly = Field.isReadOnly;
            
            Field.metadata.computedIsRequired = Field.isRequired;
            //Field.metadata.isHide = false;
            if ( this.hiddenFields !== undefined && apiNamef !== undefined ){
                Field.metadata.isHide = this.hiddenFields.includes(apiNamef);
            }
        }
        return Field;


    }

    filtrolwc(apiName, isReadOnly, value){
        let campidisattivati = ['FiscalCode__c', 'VatNumber__c', 'Email__c'];
        let disattivato = isReadOnly;
        campidisattivati.forEach((fld) => {
            if( (apiName == fld && (undefined !== value && value.length>3)) || apiName == 'Nation__c'){
                disattivato = true;
            }
        });
        return disattivato;
    }

    get option() {
        return this.listRt;
    }
    get isList(){
        if(this.listRt.length > 0) 
            return true;
        else    
            return false;
    }

    // handleChangeRt(event) {
    //     this.recordTypeId = event.detail.value;
    //     var rtName = this.jsonRt[this.recordTypeId];
    //     this.loadRules = true;
    //     this.rules = {};
    //     this.configuration={};
    //     //this.getRtRules(rtName);
    // }

    handleClick(evt){
        this.isLoading = true;
        console.log("save button");
  
        const fields = {};
  
        fields.Id = this.recordId;
  
        for (var field in this.formulario) {
  
          console.log('field es ' + field);
          var seccion = this.formulario[field].seccion;
          var posicion = this.formulario[field].posicion;

          var fieldFake = false;
          if(this.formulario[field].fieldFake)
             fieldFake = true;
  
          var noUpdateable = this.infoSectionsLayout[seccion].lstFields[posicion].isReadOnly;
          console.log('noUpdateable es ' + noUpdateable);
  
          if(!noUpdateable && !fieldFake){
            fields[field]=((this.infoSectionsLayout[seccion].lstFields[posicion])[field]).fieldValue;
          }
  
          
        }
  
        console.log(JSON.stringify(fields));
  
        const recordInput = { fields };
  
        console.log(JSON.stringify(recordInput));
  
        updateRecord(recordInput)
            .then(() => {
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.objectApiName + ' updated',
                        variant: 'success'
                    })
                );
            }
        )
        .catch(error => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
  
  
    }

    

    handleChange(event) {

    } 

    loadParent(evt)
    {
        
        var parentFieldName = evt.detail.fieldApiName;
        var id = evt.detail.id;
        var parentFields = evt.detail.fields.fields;

        var seccion = this.formulario[parentFieldName].seccion;
        var posicion = this.formulario[parentFieldName].posicion;
        
        var miJson = {};
        
        miJson.fieldValue = id;
        
        for (var field in parentFields) {
          miJson[field] ={"fieldValue" : parentFields[field].value} ;
        }

        (this.infoSectionsLayout[seccion].lstFields[posicion])[parentFieldName] = miJson;
        (this.infoSectionsLayout[seccion].lstFields[posicion])[parentFieldName].Id = id;
        this.doAllActions();

    }

    buildParams(condition){

        var myParam = {};
        myParam.params=[];
        var myParamArray = new Array();
  
        for(var i =0; i< condition.params.length; i++){
      
          var param = condition.params[i];
          var paramTemp ={};
          
          if(param.type == 'field')
          {
              var paramName = param.name;
              var paramPath = paramName.split(".");
              var poramRoot = paramPath[0];
      
              var seccion = this.formulario[poramRoot].seccion;
              var posicion = this.formulario[poramRoot].posicion;
              console.log('***********');
              var value;
              var myJson = this.infoSectionsLayout[seccion].lstFields[posicion];
              for(var j =0; j<paramPath.length; j++){
                console.log('j es ' + j);
                
  
                myJson = myJson[paramPath[j]];
  
                console.log('myJson es ' +  JSON.stringify(myJson) );
              }
              if(myJson)
              {
                value = myJson.fieldValue;
              }
  
              else {
                value ='';
              }
              
              console.log(value);
              console.log('***********');
               
            paramTemp.value = value;
          }
          else if(param.type == 'value')
            paramTemp.value = param.value;
  
          paramTemp.name = param.name;
          
          
          myParamArray.push(paramTemp);
        }
        
        myParam.params=myParamArray;
  
        return myParam;
  
  
  
    }
  
    evalCondition(condition){
  
  
        var myObject = new validator();
  
        var method = condition.method;
        var myParam = this.buildParams(condition);
        
        var resultado = myObject[method](myParam);
  
        return resultado;
  
    }
  
    doConditions(conditions, logic){
          var bresul;
          for (var i = 0; i< conditions.length; i++)
          {
            var r = this.evalCondition(conditions[i]);
            
            if(i ==0)
              bresul = r;
            else if (logic == "AND")
              bresul = bresul && r;
            else if (logic == "OR") 
              bresul = bresul || r;
          }
          return bresul;
  
    }
  
    doEvents(events){
        for(var i =0; i< events.length; i++)
        {
          var campo = events[i].field;
  
          if(events[i].readonly) {
            this.doReadOnly(campo, events[i].readonly);
          }
          if(events[i].required) {
            this.doRequired(campo, events[i].required);
          }
          if(events[i].hide) {
            this.doHide(campo, events[i].hide);
          }
          if(events[i].value) {
            this.doValue(campo, events[i].value);
          }
        }
    }
  
    doValue(field, event)
    {
        var seccion = this.formulario[field].seccion;
        var posicion = this.formulario[field].posicion;
  
        var type = event.ValueType;
        var value;
  
        var result = this.doConditions(event.conditions, event.logic); 
        if(result){
          if(type == 'field'){
            var campo = event.field;

            var paramPath = campo.split(".");
            var poramRoot = paramPath[0];

            var sec = this.formulario[poramRoot].seccion;
            var pos = this.formulario[poramRoot].posicion;

            var myJson = this.infoSectionsLayout[sec].lstFields[pos];

            for(var j =0; j<paramPath.length; j++){
                myJson = myJson[paramPath[j]];
              }

            value = myJson.fieldValue;
  
  
          }else if(type == 'value'){
            value = event.value;
          }
  
          this.infoSectionsLayout[seccion].lstFields[posicion].fieldValue = value;
          ((this.infoSectionsLayout[seccion].lstFields[posicion])[field]).fieldValue =  value;
        }
        this.queueFieldUpdate.push(field);
  
  
    }
  
    doRequired(field, event)
    {
  
        var seccion = this.formulario[field].seccion;
        var posicion = this.formulario[field].posicion;
        console.log('seccion es ' + seccion);
        console.log('posicion es ' + posicion);
        console.log('campo es ' + JSON.stringify(this.infoSectionsLayout[seccion].lstFields[posicion]));
        
        var result = this.doConditions(event.conditions, event.logic); 
        
        result = result || this.infoSectionsLayout[seccion].lstFields[posicion].isRequired;     
        this.infoSectionsLayout[seccion].lstFields[posicion].metadata.computedIsRequired = result;
  
    }

    doHide(field, event)
    {
  
        var seccion = this.formulario[field].seccion;
        var posicion = this.formulario[field].posicion;
        console.log('seccion es ' + seccion);
        console.log('posicion es ' + posicion);
        console.log('campo es ' + JSON.stringify(this.infoSectionsLayout[seccion].lstFields[posicion]));
        
        var result = this.doConditions(event.conditions, event.logic); 
          
        this.infoSectionsLayout[seccion].lstFields[posicion].metadata.isHide = result;
  
    }

    doReadOnly(field, event)
      {
  
        var seccion = this.formulario[field].seccion;
        var posicion = this.formulario[field].posicion;
        console.log('seccion es ' + seccion);
        console.log('posicion es ' + posicion);
        console.log('campo es ' + JSON.stringify(this.infoSectionsLayout[seccion].lstFields[posicion]));
        
        var result = this.doConditions(event.conditions, event.logic); 
        
        result = result || this.infoSectionsLayout[seccion].lstFields[posicion].isReadOnly;     
        this.infoSectionsLayout[seccion].lstFields[posicion].metadata.computedIsReadOnly = result;
  
    }
  
    doAllActions(){

        var loaded = true;
        for (let [key, value] of this.dataTypeReference) {

            if(this.formulario[key]){

                var seccion = this.formulario[key].seccion;
                var posicion = this.formulario[key].posicion;
                var id = ((this.infoSectionsLayout[seccion].lstFields[posicion])[key]).Id;
                var fieldValue = ((this.infoSectionsLayout[seccion].lstFields[posicion])[key]).fieldValue;

                if(fieldValue != null && fieldValue !='' && !id){
                    loaded = false;
                }

            }

        }
        if(loaded){

            if(this.loadRules){
                for (var action in this.rules) {
                    if(this.formulario[action])
                    {
                        this.doTheWork(action);
                    }
                    
                }
            }
        }
    }
  
    doTheWork(field){
  
        if(this.rules[field]){
  
          var actions = this.rules[field].actions;
          //miro a ver si hay acciones para relizar sobre el campo modificado
            if(actions.length > 0)
          {
            for (var j=0; j <actions.length; j++ )
            {
              var result = this.doConditions(actions[j].conditions, actions[j].logic); 
              if(result){
                this.doEvents(actions[j].events);
              }   
            }
            }

            while(this.queueFieldUpdate.length > 0)
            {
                var newField = this.queueFieldUpdate[0];
                console.log('hay que procesar un cambio en ' + this.queueFieldUpdate[0]);
                this.queueFieldUpdate.splice(0, 1);
                this.doTheWork(newField);
            }

          
        }
    }
  
    handleClickNew(evt){
        console.log("save button");
        this.isLoading = true;
        var requiredField = [];
        const fields = {};
        fields.Id = this.recordId;
  
        for (var field in this.formulario) {
  
          console.log('field es ' + field);
          if(this.hiddenFields.includes(field)) continue;
          var seccion = this.formulario[field].seccion;
          var posicion = this.formulario[field].posicion;
          
          var fieldFake = false;
          if(this.formulario[field].fieldFake)
             fieldFake = true;
  
          var noUpdateable = this.infoSectionsLayout[seccion].lstFields[posicion].isReadOnly;
          console.log('noUpdateable es ' + noUpdateable);

          var value = ((this.infoSectionsLayout[seccion].lstFields[posicion])[field]).fieldValue;

          if(this.infoSectionsLayout[seccion].lstFields[posicion].isRequired && !value && field != 'Salutation'){
              requiredField.push(this.infoSectionsLayout[seccion].lstFields[posicion].metadata["label"]);
          }
          if(!noUpdateable && value !=''  && !fieldFake ){
            fields[field]=value;
          }
        }
   
        if(this.recordTypeId !=''){
            fields.RecordTypeId=this.recordTypeId;
        } 
        
        console.log(JSON.stringify(fields));
        if(!requiredField.length > 0){
            

            //console.debug('fields:'+JSON.stringify(fields));
            for (var fieldstep1 in this.fieldsValueStep1) {
                if(fieldstep1 == 'Company__c'){
                    fields[fieldstep1] = this.fieldsValueStep1[fieldstep1].value;
                }

                if(this.fieldsValueStep1[fieldstep1].length>1){
                    if(fieldstep1 == 'RecordTypeName'){
                        fields[fieldstep1] = this.recTypeName;
                    }else{
                        fields[fieldstep1] = this.fieldsValueStep1[fieldstep1];
                    }
                }
            }
            console.debug('fields:'+JSON.stringify(fields));

            // create Record
            const recordInput = {};
            recordInput.apiName = this.objectApiName;
            recordInput.fields = fields;
            recordInput.RecordTypeName = this.recTypeName;
            

            console.debug('recordInput:'+JSON.stringify(recordInput));

                createRecord(recordInput)
                .then(record => {
                    var newId = record.id;
                    this.showToastEvent('Operazione riuscita','','success');
                    this.dispatchEvent(new CustomEvent('next', { detail : {accountId : newId}}));
                //     evt.preventDefault();
                // const selectEvent = new CustomEvent('newobject', {
                //                         detail: { objectId: newId }
                //                     });
                // this.dispatchEvent(selectEvent);
                })
                .catch(error => {
                    console.error(JSON.stringify(error));
                    var errorMessageToDisplay = ''
                    let fieldErrors = error.body.output.fieldErrors;

                    for(var fieldName in fieldErrors){
                        let errorList = fieldErrors[fieldName];
                        for(var i=0; i < errorList.length; i++){
                            errorMessageToDisplay += ' Errore: '+ errorList[i].message + ' ';
                        }
                    }

                    
                    this.showToastEvent('Si è verificato un errore nella creazione del cliente: ',errorMessageToDisplay, 'error');
                //this.showToastEvent('Error creating record', error.body.message, 'error');
                this.isLoading = false;
                });
                this.isLoading = false;
        }else{
            //alert('Compilare i campi obbligatori '+requiredField);
            this.showToastEvent('Compilare i campi obbligatori', requiredField.toString(), 'error' );
            this.isLoading = false;
        }
    }
    

    handleSuccess(event){
        var newId = event.detail.id;
            this.showToastEvent('Operazione riuscita','','success');
            this.dispatchEvent(new CustomEvent('next', { detail : newId}));
    }

    handleError(event){
        this.showToastEvent('Error creating record', event.detail.message , 'error');
        this.isLoading = false;
    }

    showToastEvent(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }    
    cancelNew(evt){
        this.dispatchEvent(new CustomEvent('preavious'));
    }
}