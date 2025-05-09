# Custom API Connections

1. [Setup Endpoints](#setup-endpoints)
1. [Make Callout From Salesforce](#make-callout-from-your-salesforce)
1. [Accept Callout From External Connection](#allow-callout-to-your-salesforce)
1. [Mocking HttpCallouts](#callout-test-classes)
1. [Addtional Resources](#additional-resources)

## Setup Endpoints
The Following Steps are for creating Endpoints for a Salesforce-to-Salesforce Connection. 
Steps might differ slightly for Endpoint Connections to other Systems.
1. In Target Org, Create **Connected App**
    - Setup > App Manager > New Connected App > Create Connected App
        - **Connected App Name**: Source Org Name
        - **Contact Email**: Your Email
        - **Enable OAuth Settings**: Checked
        - **Callback URL**: https://login.salesforce.com/services/oauth2/callback (This is a placeholder)
        - **Available OAuth Scopes**: 
            - Manage user data via APIs (api)
            - Perform requests on your behalf at any time (refresh_token, offline_access)
            - (More can be added based on requirements)
    - Click Save
    - Click Continue
    - Click Manage Consumer Details
    - Verify Identity By Logging into Current Org
    - Save or Copy **Consumer Key** and **Consumer Secret** 
1. In Source Org, Create **Auth Provider**
    - Go To Setup > Auth. Providers > New
        - **Provider Type**: Salesforce
        - **Name**: Target Org Name
        - **Consumer Key**: Paste from Connected App
        - **Consumer Secret**: Paste from Connected App
    - Click Save
    - Copy **Callback URL** Generated
1. In Target Org, Update **Callback URL** on **Connected App** with New **Callback URL**
1. In Source Org, Create **Named Credential** 
    - Go To Setup > Named Credential > New Legacy
        - **Label**: Target Org Name
        - **URL**: https:// + Paste Salesforce Instance URL for Target Org
        - **Identity Type**: Named Principal
        - **Authentication Protocol**: OAuth 2.0
        - **Provider**: Lookup the **Auth Provider** just created
        - **Scope**: api refresh_token (Should match the OAuth Scopes added to the Connected App)
        - **Generate Authorization Header**: Checked
    - Click Save
    - Login to Target Org (Might have to wait up to 10 Minutes)
    - Click Allow
    - Click Confirm

[(Back to Top)](#custom-api-connections)

## Make Callout FROM Your Salesforce

### Remote Site Settings

If your endpoint is just a URL, a related Remote Site Settings Record will need to be created to allow Salesforce to send the connection

[Remote Site Setting Example](/force-app/main/default/remoteSiteSettings/BoardGameGeek.remoteSite-meta.xml)

### HttpCallout
```
Http http = new Http();
HttpRequest request = new HttpRequest();

// This is the Endpoint URL for the Callout. 
// Should be stored as Custom Setting or Named Credential but can just be the URL
String endpoint = String.format('callout:{0}/services/apexrest/{1}', new List<String>{ namedCredential, RestResourceName});

// This is the Data that will be sent over for POST, PUT, or PATCH Methods
String jsonString = '{"Name":"Test Name"}'; 

request.setEndpoint(endpoint);
request.setMethod('POST'); // Method Types: GET, POST, PUT, PATCH, DELETE
request.setHeader('Content-Type', 'application/json');
request.setBody(jsonString); // GET Methods cannot have Body

try {
    HttpResponse response = http.send(request);
    If(response.getStatusCode()==200){ // Status codes may vary depending 

        // Do Work For Success
    
    } else {

        // Do Work For Failure

    }
} catch (Exception e) {
        // Error Handling
}
```
[(Back to Top)](#custom-api-connections)
## Allow Callout TO Your Salesforce

### RestResource Class Template
1. [Header](#header) 
1. [@HttpGet](#get)
1. [@HttpPost](#post)
1. [@HttpPut](#put)
1. [@HttpDelete](#delete)

#### Header
```
@RestResource(urlMapping='/MyResource/*') 
global with sharing class MyRestResource
```
#### Get
```
// GET: /services/apexrest/MyResource/{id}
@HttpGet
global static Account doGet() {
    
    RestRequest req = RestContext.request;   // What is coming in
    RestResponse res = RestContext.response; // What is going out

    String recordId  = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

    try {

        //Do Work
        
        res.statusCode = 200;
    } catch (Exception e) {
        res.statusCode = 404;
        res.responseBody = Blob.valueOf('{"error": "Record not found"}');
    }

}
```
#### Post
```
// POST: /services/apexrest/MyResource
@HttpPost
global static void doPost() {

    RestRequest req = RestContext.request;   // What is coming in
    RestResponse res = RestContext.response; // What is going out
    
    try {
        String jsonBody = req.requestBody.toString();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

        //Do Work

        res.statusCode = 201;
        res.responseBody = Blob.valueOf(JSON.serialize(myResults));
    } catch (Exception e) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
    }
}
```
#### Put
```

// PUT: /services/apexrest/MyResource/{id}
@HttpPut
global static void doPut() {

    RestRequest req = RestContext.request;   // What is coming in
    RestResponse res = RestContext.response; // What is going out

    String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    
    try {
        
        //Do Work

        res.statusCode = 204;
    } catch (Exception e) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
    }
}
```
#### Delete
```
// DELETE: /services/apexrest/MyResource/{id}
@HttpDelete
global static void doDelete() {

    RestRequest req = RestContext.request;   // What is coming in
    RestResponse res = RestContext.response; // What is going out

    String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    
    try {

        //Do Work

        res.statusCode = 204;
    } catch (Exception e) {
        res.statusCode = 404;
        res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
    }
}
```
[(Back to Top)](#custom-api-connections)

## Callout Test Classes

Since Test Classes cannot make Callouts, we need to be able to Mock HTTP Callouts in our Test Classes

#### Setup HttpCalloutMock Class
```
// Mock HttpResponse class to simulate the actual HTTP response for callouts
public class MockHttpResponse implements HttpCalloutMock {
    private String responseBody;
    private Integer statusCode;
    
    public MockHttpResponse(String responseBody, Integer statusCode) {
        this.responseBody = responseBody;
        this.statusCode = statusCode;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        response.setBody(this.responseBody);
        response.setStatusCode(this.statusCode);
        return response;
    }
}
```
#### Mocking HTTP Response

```
//From Static Resource
StaticResource staticResource = [SELECT Body FROM StaticResource WHERE Name = 'Success_Example.xml' LIMIT 1];
String responseBody staticResource.Body.toString();

// OR Manually set
String responseBody = '{"Test":"TestName"}';

Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseBody, 200));
```

[(Back to Top)](#custom-api-connections)

## Additional Resources

[REST Annotations](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotations_rest.htm)

[REST Resource Examples](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_code_sample_basic.htm)

