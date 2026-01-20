public with sharing class ContactManager {

    public static Id createContact(String firstName, String lastName, String email) {
        Contact newContact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email
        );
        
        try {
            insert newContact;
            return newContact.Id;
        } catch (DmlException e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }

    public static List<Contact> getContactsByEmail(String email) {
       
        if (String.isBlank(email)) {
            return new List<Contact>();
        }

        return [
            SELECT Id, FirstName, LastName, Email 
            FROM Contact 
            WHERE Email = :email
            LIMIT 10
        ];
    }
}