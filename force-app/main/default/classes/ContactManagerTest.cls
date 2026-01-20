@isTest
private class ContactManagerTest {

    @isTest
    static void testCreateContact() {
        String fName = 'Ivan';
        String lName = 'Testov';
        String email = 'ivan@test.com';


        Test.startTest();
        Id contactId = ContactManager.createContact(fName, lName, email);
        Test.stopTest();

        Assert.areNotEqual(null, contactId, 'ID should not be null');
        
        Contact storedContact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        Assert.areEqual(email, storedContact.Email, 'Email should match the input email');
    }


    @isTest
    static void testGetContactsByEmail() {

        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0; i<3; i++) {
            testContacts.add(new Contact(LastName='User'+i, Email='search@test.com'));
        }
        insert testContacts;

        Test.startTest();
        List<Contact> results = ContactManager.getContactsByEmail('search@test.com');
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'Should return exactly 3 contacts');
        Assert.areEqual('search@test.com', results[0].Email, 'Email should match the search query');
    }
}