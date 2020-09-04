/*
    * @author RANAND
    * @date 04/09/2020
    * @group Case Closed
    * @description This batch will excute every hour to process all the closed cases by making a callout to Workforce API 
                    and update secret key in return.
 
 */
public with sharing class CaseClosure_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    //Get maximum count of reattempts to happen for each Case record in case of any failure
    Integer maxReattempt = Integer.valueOf(Label.MAX_RETRY_ATTEMPT);
    //the query returns all the closed case records due for workforce integration or failed in previous attempts
    String query = 'SELECT Id, IsClosed, Closed_By__c, Retry_Attempt__c, Secret_Key__c FROM Case WHERE IsClosed = true AND Secret_Key__c = null AND Retry_Attempt__c < ' + maxReattempt;
    /**
        * @method constructor
        * @params query- if not passed uses the default
    */
    public CaseClosure_Batch(string query) {
        if(String.isNotBlank(query)){
            this.query = query;
        }
    }
    /**
        * @method start
        * @params Database.BatchableContext context
        * @returnType Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(query);
    }
    /**
        * @method execute
        * @params Database.BatchableContext context, List<sObject> scope
        * @returnType void
    */
    public void execute(Database.BatchableContext context, List<sObject> scope){
        List<Case> caseList = (List<Case>)scope ;
        try{
            for(Case objCase : caseList){
                objCase.Secret_Key__c = callWorkforceAPI(objCase);
            }
            update caseList;
        }
        catch(Exception ex){
            System.debug('EXCEPTION : '+ ex.getMessage());
        }
    }
    /**
        * @method finish
        * @params Database.BatchableContext context
        * @returnType void
    */
    public void finish(Database.BatchableContext context){

    }
    /**
        * @method callWorkforceAPI
        * @params Case objCase
        * @returnType String - SecretKey or null
    */
    private static String callWorkforceAPI(Case objCase){
        //Create Request and Set EndPoint using Named Credentials
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:WORKFORCE_PLANNING_API');
        request.setMethod('POST');
        //Set request body with Id and AgentId
        request.setBody(JSON.serialize(new Map<String, String>{'id'=>objCase.Id, 'agentId'=>objCase.Closed_By__c}));
        Http http = new Http();
        //Callout to Workforce API
        HttpResponse response = http.send(request);
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 200){
            if(responseMap.containsKey('secretKey')){
                return String.valueOf(responseMap.get('secretKey'));
            }
        }
        else{
            //Log the errored response in case a logging for callouts is in place
            //update retry attempt by 1
            objCase.Retry_Attempt__c +=1;
        }
        return null;
    }
}
