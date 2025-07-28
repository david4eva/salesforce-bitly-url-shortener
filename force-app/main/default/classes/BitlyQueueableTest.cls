@IsTest
private class BitlyQueueableTest {
    
    // ------------------------------------------------------------------------
    // Mock for successful Bitly HTTP callouts
    // ------------------------------------------------------------------------
    private class MockBitlySuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            // Return a predictable short link
            res.setBody('{"link":"https://bit.ly/mock"}');
            return res;
        }
    }
    
    // ------------------------------------------------------------------------
    // Mock for error Bitly HTTP callouts (e.g., 403 Forbidden)
    // ------------------------------------------------------------------------
    private class MockBitlyError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(403);
            res.setBody('{"message":"FORBIDDEN"}');
            return res;
        }
    }
    
    // ------------------------------------------------------------------------
    // Helper to create a valid Contact with required fields
    // ------------------------------------------------------------------------
    private static Contact makeContact(String url) {
        return new Contact(
            FirstName               = 'Test',
        LastName                = 'User',
        Mailing_Address_Type__c = 'Home',        // valid picklist
        Join_Date__c            = Date.today(),  // required date
        Survey_Link_URL__c      = url
            );
    }
    
    @IsTest
    static void testQueueable_Success() {
        // Register success mock
        Test.setMock(HttpCalloutMock.class, new MockBitlySuccess());
        
        // Create and insert two contacts
        Contact c1 = makeContact('https://example.com/one');
        Contact c2 = makeContact('https://example.com/two');
        insert new List<Contact>{c1, c2};
        
        // Build map for queueable
        Map<Id,String> mapToShorten = new Map<Id,String>{
            c1.Id => c1.Survey_Link_URL__c,
            c2.Id => c2.Survey_Link_URL__c
        };
        
        Test.startTest();
        System.enqueueJob(new BitlyQueueable(mapToShorten));
        Test.stopTest();
        
        // Verify both contacts were updated with the mock short link
        c1 = [SELECT Survey_Link_URL__c, Bitly_Error__c, Bitly_Error_Code__c, Bitly_Error_Message__c
              FROM Contact WHERE Id = :c1.Id];
        c2 = [SELECT Survey_Link_URL__c, Bitly_Error__c
              FROM Contact WHERE Id = :c2.Id];
        
        System.assertEquals('https://bit.ly/mock', c1.Survey_Link_URL__c);
        System.assertEquals(false, c1.Bitly_Error__c);
        System.assertEquals(null, c1.Bitly_Error_Code__c);
        System.assertEquals(null, c1.Bitly_Error_Message__c);
        
        System.assertEquals('https://bit.ly/mock', c2.Survey_Link_URL__c);
        System.assertEquals(false, c2.Bitly_Error__c);
    }
    
    @IsTest
    static void testQueueable_Error() {
        // Register error mock
        Test.setMock(HttpCalloutMock.class, new MockBitlyError());
        
        // Create and insert one contact
        Contact c = makeContact('https://example.com/error');
        insert c;
        
        // Build map for queueable
        Map<Id,String> mapToShorten = new Map<Id,String>{
            c.Id => c.Survey_Link_URL__c
        };
        
        Test.startTest();
        System.enqueueJob(new BitlyQueueable(mapToShorten));
        Test.stopTest();
        
        // Verify the contact was flagged with the error details
        c = [SELECT Survey_Link_URL__c, Bitly_Error__c, Bitly_Error_Code__c, Bitly_Error_Message__c
             FROM Contact WHERE Id = :c.Id];
        
        // The original URL remains unchanged
        System.assertEquals('https://example.com/error', c.Survey_Link_URL__c);
        System.assertEquals(true, c.Bitly_Error__c);
        System.assertEquals('403', c.Bitly_Error_Code__c);
        System.assertEquals('FORBIDDEN', c.Bitly_Error_Message__c);
    }
}