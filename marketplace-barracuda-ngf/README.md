## new marketplace template for ngf ##
This is an internal Barracuda draft for CGFW ARM template

# Testing #
Use the link below to run the UI part in your browser. in the last step, open JS console from the browser developer tools and grab the resulting JSON block. Save it as a file and refer to as parameter file during mainTemplate.json deployment.

[test ui](https://portal.azure.com/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"initialData":{},"providerConfig":{"createUiDefinition":"https%3A%2F%2Fraw.githubusercontent.com%2Fbartekmo%2Fng-azure%2Fngf2%2Fmarketplace-barracuda-ngf%2FCreateUiDefinition.json"}})


# Notes #
* when deploying into existing VNet, routing table for Protected Subnet will be replaced
* if deployed into existing VNet, during rollback, routing table for Protected Subnet must be changed manually

# Known issues #
