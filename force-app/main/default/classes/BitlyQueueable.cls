/**
 * Queueable class to handle shortening of survey URLs using the Bitly API.
 * This design ensures we stay within Salesforce governor limits while respecting
 * Bitly's requirement of one URL per API call.
 *
 * Why Queueable?
 * - Bitly only allows one URL per request.
 * - @future methods are limited to 50 calls per transaction and don’t support complex data types.
 * - Queueable allows us to process all records in one job with 100 callouts and 150 DML updates.
 *
 * Best practice: Avoid DML inside loops — use a collection and update in bulk.
 */
public class BitlyQueueable implements Queueable, Database.AllowsCallouts {
    private Map<Id, String> contactIdToUrlMap;
    
    public BitlyQueueable(Map<Id, String> contactIdToUrlMap) {
        this.contactIdToUrlMap = contactIdToUrlMap;
    }
    
    public void execute(QueueableContext context) {
        List<Contact> contactsToUpdate = new List<Contact>();
        
        // Loop through each contact needing a shortened URL
        for (Id contactId : contactIdToUrlMap.keySet()) {
            String longUrl = contactIdToUrlMap.get(contactId);
            
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:Bitly_API/v4/shorten');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                
                // Bitly accepts only one long_url per call
                Map<String, Object> payload = new Map<String, Object>{
                    'long_url' => longUrl,
                    'domain' => 'bit.ly'
                };
                request.setBody(JSON.serialize(payload));
                
                HttpResponse response = http.send(request);
                
                Contact updateContact = new Contact(Id = contactId);
                
                if (response.getStatusCode() == 200) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    String shortUrl = (String) result.get('link');
                    
                    updateContact.Survey_Link_URL__c = shortUrl;
                    updateContact.Bitly_Error__c = false;
                    updateContact.Bitly_Error_Code__c = null;
                    updateContact.Bitly_Error_Message__c = null;
                } else {
                    Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    updateContact.Bitly_Error__c = true;
                    updateContact.Bitly_Error_Code__c = String.valueOf(response.getStatusCode());
                    updateContact.Bitly_Error_Message__c = (String) errorMap.get('message');
                }
                
                contactsToUpdate.add(updateContact);
                
            } catch (Exception e) {
                // Handle unexpected error during callout
                if (contactId != null) {
                    Contact errorContact = new Contact(
                        Id = contactId,
                    Bitly_Error__c = true,
                    Bitly_Error_Code__c = 'EXCEPTION',
                    Bitly_Error_Message__c = e.getMessage()
                        );
                    contactsToUpdate.add(errorContact);
                }
            }
        }
        
        // ✅ Bulk-safe DML outside the loop
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}