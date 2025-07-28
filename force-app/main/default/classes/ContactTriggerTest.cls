@IsTest
private class ContactTriggerTest {
    
    // ------------------------------------------------------------------------
    // Inner mock for Bitly callouts
    // ------------------------------------------------------------------------
    private class MockBitlyCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a successful Bitly response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody('{"link":"https://bit.ly/mock"}');
            return res;
        }
    }
    
    // ------------------------------------------------------------------------
    // Helper to create a valid Contact with required fields
    // ------------------------------------------------------------------------
    private static Contact makeTestContact(String url) {
        return new Contact(
            FirstName               = 'Test',
        LastName                = 'User',
        Mailing_Address_Type__c = 'home',        // valid picklist value
        Join_Date__c            = Date.today(),  // required date
        Survey_Link_URL__c      = url
            );
    }
    
    @IsTest
    static void testBeforeInsert() {
        // Register mock so HTTP.send() returns our fake response
        Test.setMock(HttpCalloutMock.class, new MockBitlyCallout());
        
        // Build and insert a Contact
        Contact c = makeTestContact('https://example.com');
        
        Test.startTest();
        insert c;
        Test.stopTest();
        
        // Reload and verify
        c = [SELECT Survey_Link_URL__c, Bitly_Error__c 
             FROM Contact WHERE Id = :c.Id];
        System.assertEquals(
            'https://bit.ly/mock',
        c.Survey_Link_URL__c,
        'The Survey_Link_URL__c should be replaced with the mocked short URL'
            );
        System.assertEquals(
            false,
        c.Bitly_Error__c,
        'Bitly_Error__c should be false after successful shortening'
            );
    }
    
    @IsTest
    static void testBeforeUpdate() {
        // Register mock again for this test
        Test.setMock(HttpCalloutMock.class, new MockBitlyCallout());
        
        // Insert initial record
        Contact c = makeTestContact('https://initial-url.com');
        insert c;
        
        // Change the URL and update
        c.Survey_Link_URL__c = 'https://updated-url.com';
        
        Test.startTest();
        update c;
        Test.stopTest();
        
        // Reload and verify
        c = [SELECT Survey_Link_URL__c, Bitly_Error__c 
             FROM Contact WHERE Id = :c.Id];
        System.assertEquals(
            'https://bit.ly/mock',
        c.Survey_Link_URL__c,
        'The Survey_Link_URL__c should be replaced with the mocked short URL on update'
            );
        System.assertEquals(
            false,
        c.Bitly_Error__c,
        'Bitly_Error__c should be false after successful shortening on update'
            );
    }
}