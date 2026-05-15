public with sharing class DynamicContactForm {

    public class CreateContactResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Id contactId;
    }

    @AuraEnabled
    public static CreateContactResult createContact(Map<String, Object> contactData){
        System.debug('Contact Data : ' + contactData);
        CreateContactResult res = new CreateContactResult();

        // Return early validations
        if (contactData == null) {
            res.success = false;
            res.message = 'No contact data provided';
            return res;
        }
        // Extract values from generic map to avoid wrapper serialization issues
        String firstName = (String) contactData.get('firstName');
        String lastName  = (String) contactData.get('lastName');
        String email     = (String) contactData.get('email');
        String phone     = (String) contactData.get('phone');

        if (String.isBlank(lastName)) {
            res.success = false;
            res.message = 'Last Name is required';
            return res;
        }

        try {
            Contact con = new Contact(
                FirstName = firstName,
                LastName  = lastName,
                Email     = email,
                Phone     = phone
            );

            // Perform DML in USER_MODE and capture result
            List<Database.SaveResult> srs = Database.insert(new List<Contact>{ con }, AccessLevel.USER_MODE);

            if (srs != null && !srs.isEmpty() && srs[0].isSuccess()) {
                res.success = true;
                res.contactId = srs[0].getId();
                res.message = 'Contact created';
            } else {
                res.success = false;
                if (srs != null && !srs.isEmpty() && srs[0].getErrors().size() > 0) {
                    res.message = srs[0].getErrors()[0].getMessage();
                } else {
                    res.message = 'Unknown error';
                }
            }
        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }

        return res;
    }
}