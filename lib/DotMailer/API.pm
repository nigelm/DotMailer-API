package DotMailer::API;

# ABSTRACT: Interact with the DotMailer platform API

use strict;
use warnings;

# VERSION
# AUTHORITY

use Mouse;
use Method::Signatures;
use Cpanel::JSON::XS;
use LWP::ConnCache;
use LWP::UserAgent;
use URI;

with 'Web::API';

# ------------------------------------------------------------------------

=head1 DESCRIPTION

L<Web::API> based API interface to the DotDigital / DotMailer Engagement Cloud
API - as described at L<https://developer.dotdigital.com/docs>.

The lack of documentation reflects the stage in development...

=head1 SYNOPSIS

    # THIS IS AT AN EARLY STAGE OF DEVELOPMENT - PROTOTYPING REALLY
    # IT MAY CHANGE DRAMATICALLY OR EAT YOUR DATA.

    use DotMailer::API

    my $api = DotMailer::API->new(
        username => 'demo@apiconnector.com',
        password => 'demo',
        debug => 1 );

    my $res = $api->GetAccountInfo;


=head2 Attributes

=head3 api_url

Base API URL of the service.  Defaults to C<https://api.dotmailer.com>. On the
initial connection a C<GetAccountInfo> operation is carried out, and the
C<ApiEndpoint> is taken from that and replaces the value of C<api_url> so that
the correct regional URL is used for the authenticated user.


=head3 username

Username for logging in to the service.  Required.

=head3 password

Password for logging in to the service.  Required.

=head3 debug

Set debug on.  The higher the debug level, the more chatter is exposed.

=cut

# ------------------------------------------------------------------------

has api_version => (
    is      => 'ro',
    isa     => 'Num',
    default => sub {2},
);

has api_url => (
    is      => 'ro',
    isa     => 'Str',
    default => sub {'https://api.dotmailer.com'},
);

# ------------------------------------------------------------------------

has username => ( is => 'ro', isa => 'Str', required => 1 );
has password => ( is => 'ro', isa => 'Str', required => 1 );

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
has endpoints => (
    is      => 'ro',
    default => sub {
        {   DeleteAddressBook => {
                description => 'Deletes an address book.',
                method      => 'DELETE',
                name        => 'DeleteAddressBook',
                path        => 'address-books/:id',
            },
            DeleteAddressBookContact => {
                description => 'Deletes a contact from a given address book.',
                method      => 'DELETE',
                name        => 'DeleteAddressBookContact',
                path        => 'address-books/:addressBookId/contacts/:contactId',
            },
            DeleteAddressBookContacts => {
                description => 'Deletes all contacts from a given address book.',
                method      => 'DELETE',
                name        => 'DeleteAddressBookContacts',
                path        => 'address-books/:addressBookId/contacts',
            },
            DeleteCampaign => {
                description =>
                    'Deletes a campaign, and any associated reporting data. If the campaign is currently in use, or being sent to, this call will not be permitted.',
                method => 'DELETE',
                name   => 'DeleteCampaign',
                path   => 'campaigns/:campaignId',
            },
            DeleteCampaignAttachment => {
                description => 'Removes an attachment from a campaign.',
                method      => 'DELETE',
                name        => 'DeleteCampaignAttachment',
                path        => 'campaigns/:campaignId/attachments/:documentId',
            },
            DeleteContact => {
                description => 'Deletes a contact.',
                method      => 'DELETE',
                name        => 'DeleteContact',
                path        => 'contacts/:id',
            },
            DeleteContactsTransactionalData => {
                description => 'Deletes a piece of transactional data by key.',
                method      => 'DELETE',
                name        => 'DeleteContactsTransactionalData',
                path        => 'contacts/transactional-data/:collectionName/:key',
            },
            DeleteContactTransactionalData => {
                description => 'Deletes all transactional data for a contact.',
                method      => 'DELETE',
                name        => 'DeleteContactTransactionalData',
                path        => 'contacts/:id/transactional-data/:collectionName',
            },
            DeleteDataField => {
                description => 'Deletes a data field within the account.',
                method      => 'DELETE',
                name        => 'DeleteDataField',
                path        => 'data-fields/:name',
            },
            DeletePreference => {
                description => 'Deletes the preference with the speficied Id',
                method      => 'DELETE',
                name        => 'DeletePreference',
                path        => 'preferences/:id',
            },
            DeleteSmsCampaign => {
                description => 'Delete an SMS Campaign.',
                method      => 'DELETE',
                name        => 'DeleteSmsCampaign',
                path        => 'sms/campaigns/:id',
            },
            GetAccountInfo => {
                description =>
                    'Gets a summary of information about the current status of the account.',
                method => 'GET',
                name   => 'GetAccountInfo',
                path   => 'account-info',
            },
            GetAddressBookById => {
                description => 'Gets an address book by ID.',
                method      => 'GET',
                name        => 'GetAddressBookById',
                path        => 'address-books/:id',
            },
            GetAddressBookCampaigns => {
                description  => 'Gets any campaigns that have been sent to an address book.',
                method       => 'GET',
                name         => 'GetAddressBookCampaigns',
                path         => 'address-books/:addressBookId/campaigns',
                query_params => [ 'select', 'skip' ],
            },
            GetAddressBookContacts => {
                description  => 'Gets a list of contacts in a given address book.',
                method       => 'GET',
                name         => 'GetAddressBookContacts',
                path         => 'address-books/:addressBookId/contacts',
                query_params => [ 'withFullData', 'select', 'skip' ],
            },
            GetAddressBookContactsModifiedSinceDate => {
                description =>
                    'Gets a list of contacts who were modified since a given date, in a given address book.',
                method       => 'GET',
                name         => 'GetAddressBookContactsModifiedSinceDate',
                path         => 'address-books/:addressBookId/contacts/modified-since/:date',
                query_params => [ 'withFullData', 'select', 'skip' ],
            },
            GetAddressBookContactsScore => {
                description  => 'Gets a list of contact scoring data in specified address book.',
                method       => 'GET',
                name         => 'GetAddressBookContactsScore',
                path         => 'address-books/:addressBookId/contacts/score',
                query_params => [ 'select', 'skip' ],
            },
            GetAddressBookContactsUnsubscribedSinceDate => {
                description =>
                    'Gets a list of contacts who have unsubscribed from a given address book.',
                method       => 'GET',
                name         => 'GetAddressBookContactsUnsubscribedSinceDate',
                path         => 'address-books/:addressBookId/contacts/unsubscribed-since/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetAddressBookContactsWithPreferenceByPreferenceId => {
                description =>
                    'Gets a list of contacts from a given address book, subscribed to the specified preference',
                method       => 'GET',
                name         => 'GetAddressBookContactsWithPreferenceByPreferenceId',
                path         => 'address-books/:bookId/contacts/with-preference/:preferenceId',
                query_params => ['minContactId'],
            },
            GetAddressBookContactsWithPreferenceOptInsSinceSinceDate => {
                description =>
                    'Gets a list of contacts, from a given address book, who have opted in to a preference, since the specified date',
                method => 'GET',
                name   => 'GetAddressBookContactsWithPreferenceOptInsSinceSinceDate',
                path =>
                    'address-books/:bookId/contacts/with-preference/:preferenceId/opt-ins-since/:sinceDate',
                query_params => ['minContactId'],
            },
            GetAddressBooks => {
                description  => 'Gets all address books',
                method       => 'GET',
                name         => 'GetAddressBooks',
                path         => 'address-books',
                query_params => [ 'select', 'skip' ],
            },
            GetAddressBooksPrivate => {
                description  => 'Gets all private address books',
                method       => 'GET',
                name         => 'GetAddressBooksPrivate',
                path         => 'address-books/private',
                query_params => [ 'select', 'skip' ],
            },
            GetAddressBooksPublic => {
                description  => 'Gets all public address books',
                method       => 'GET',
                name         => 'GetAddressBooksPublic',
                path         => 'address-books/public',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivities => {
                description =>
                    'Gets a list of contacts who were sent a campaign, with their activity.',
                method       => 'GET',
                name         => 'GetCampaignActivities',
                path         => 'campaigns/:campaignId/activities',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivitiesSinceDateByDate => {
                description =>
                    'Gets a list of contacts who were sent a campaign, and retrieves only those contacts who showed activity (e.g. they clicked, opened) after a specified date.',
                method       => 'GET',
                name         => 'GetCampaignActivitiesSinceDateByDate',
                path         => 'campaigns/:campaignId/activities/since-date/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivityByContactId => {
                description => 'Gets activity for a given contact and campaign.',
                method      => 'GET',
                name        => 'GetCampaignActivityByContactId',
                path        => 'campaigns/:campaignId/activities/:contactId',
            },
            GetCampaignActivityClicks => {
                description  => 'Gets a list of campaign link clicks for a contact.',
                method       => 'GET',
                name         => 'GetCampaignActivityClicks',
                path         => 'campaigns/:campaignId/activities/:contactId/clicks',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivityClicksWithGroups => {
                description  => undef,
                method       => 'GET',
                name         => 'GetCampaignActivityClicksWithGroups',
                path         => 'campaigns/:campaignId/activities/:contactId/clicks-with-groups',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivityOpens => {
                description  => 'Gets a list of campaign opens for a contact.',
                method       => 'GET',
                name         => 'GetCampaignActivityOpens',
                path         => 'campaigns/:campaignId/activities/:contactId/opens',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivityPageViews => {
                description  => 'Gets a list of page views for a contact.',
                method       => 'GET',
                name         => 'GetCampaignActivityPageViews',
                path         => 'campaigns/:campaignId/activities/:contactId/page-views',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivityReplies => {
                description =>
                    'Gets a list of campaign replies for a contact. You may not request more than 5 records at a time using the \'select\' parameter.',
                method       => 'GET',
                name         => 'GetCampaignActivityReplies',
                path         => 'campaigns/:campaignId/activities/:contactId/replies',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivityRoiDetails => {
                description  => 'Gets a list of ROI information for a contact.',
                method       => 'GET',
                name         => 'GetCampaignActivityRoiDetails',
                path         => 'campaigns/:campaignId/activities/:contactId/roi-details',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignActivitySocialBookmarkViews => {
                description  => 'Gets campaign social bookmark views for a contact.',
                method       => 'GET',
                name         => 'GetCampaignActivitySocialBookmarkViews',
                path         => 'campaigns/:campaignId/activities/:contactId/social-bookmark-views',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignAddressBooks => {
                description  => 'Gets any address books that a campaign has ever been sent to.',
                method       => 'GET',
                name         => 'GetCampaignAddressBooks',
                path         => 'campaigns/:campaignId/address-books',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignAttachments => {
                description => 'Gets documents that are currently attached to a campaign.',
                method      => 'GET',
                name        => 'GetCampaignAttachments',
                path        => 'campaigns/:campaignId/attachments',
            },
            GetCampaignById => {
                description => 'Gets a campaign by ID.',
                method      => 'GET',
                name        => 'GetCampaignById',
                path        => 'campaigns/:id',
            },
            GetCampaignClicks => {
                description  => 'Gets a list of campaign link clicks.',
                method       => 'GET',
                name         => 'GetCampaignClicks',
                path         => 'campaigns/:campaignId/clicks',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignClicksSinceDateByDate => {
                description  => 'Gets a list of link clicks for a campaign after a specified date',
                method       => 'GET',
                name         => 'GetCampaignClicksSinceDateByDate',
                path         => 'campaigns/:campaignId/clicks/since-date/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignClicksWithGroups => {
                description  => undef,
                method       => 'GET',
                name         => 'GetCampaignClicksWithGroups',
                path         => 'campaigns/:campaignId/clicks-with-groups',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignClicksWithGroupsSinceDateByDate => {
                description  => undef,
                method       => 'GET',
                name         => 'GetCampaignClicksWithGroupsSinceDateByDate',
                path         => 'campaigns/:campaignId/clicks-with-groups/since-date/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignHardBouncingContacts => {
                description =>
                    'Gets a list of contacts who hard bounced when sent a particular campaign.',
                method       => 'GET',
                name         => 'GetCampaignHardBouncingContacts',
                path         => 'campaigns/:campaignId/hard-bouncing-contacts',
                query_params => [ 'withFullData', 'select', 'skip' ],
            },
            GetCampaignOpens => {
                description  => 'Gets a list of campaign opens.',
                method       => 'GET',
                name         => 'GetCampaignOpens',
                path         => 'campaigns/:campaignId/opens',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignOpensSinceDateByDate => {
                description  => 'Gets a list of opens for a campaign after a specified date',
                method       => 'GET',
                name         => 'GetCampaignOpensSinceDateByDate',
                path         => 'campaigns/:campaignId/opens/since-date/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignPageViewsSinceDateByDate => {
                description  => 'Gets a list of page views for a campaign after a specified date.',
                method       => 'GET',
                name         => 'GetCampaignPageViewsSinceDateByDate',
                path         => 'campaigns/:campaignId/page-views/since-date/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignRoiDetailsSinceDateByDate => {
                description =>
                    'Retrieves a list of ROI information for a campaign after the specified date.',
                method       => 'GET',
                name         => 'GetCampaignRoiDetailsSinceDateByDate',
                path         => 'campaigns/:campaignId/roi-details/since-date/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaigns => {
                description  => 'Gets all campaigns',
                method       => 'GET',
                name         => 'GetCampaigns',
                path         => 'campaigns',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignSocialBookmarkViews => {
                description  => 'Gets campaign social bookmark views for a campaign.',
                method       => 'GET',
                name         => 'GetCampaignSocialBookmarkViews',
                path         => 'campaigns/:campaignId/social-bookmark-views',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignSplitTest => {
                description => 'Gets the split test results of a given campaign.',
                method      => 'GET',
                name        => 'GetCampaignSplitTest',
                path        => 'campaigns/:campaignId/split-test',
            },
            GetCampaignsSendBySendId => {
                description => 'Gets the send status using send ID.',
                method      => 'GET',
                name        => 'GetCampaignsSendBySendId',
                path        => 'campaigns/send/:sendId',
            },
            GetCampaignSummary => {
                description => 'Gets a summary of reporting information for a specified campaign.',
                method      => 'GET',
                name        => 'GetCampaignSummary',
                path        => 'campaigns/:campaignId/summary',
            },
            GetCampaignsWithActivitySinceDate => {
                description =>
                    'Gets all sent campaigns, which have had activity (e.g. clicks, opens) after a specified date.',
                method       => 'GET',
                name         => 'GetCampaignsWithActivitySinceDate',
                path         => 'campaigns/with-activity-since/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetCampaignWithDetails => {
                description =>
                    'Gets a campaign by ID with additional information like type and assigned tags',
                method => 'GET',
                name   => 'GetCampaignWithDetails',
                path   => 'campaigns/:campaignId/with-details',
            },
            GetContactAddressBooks => {
                description  => 'Gets any address books that a contact is in.',
                method       => 'GET',
                name         => 'GetContactAddressBooks',
                path         => 'contacts/:contactId/address-books',
                query_params => [ 'select', 'skip' ],
            },
            GetContactByEmail => {
                description => 'Gets a contact by email address.',
                method      => 'GET',
                name        => 'GetContactByEmail',
                path        => 'contacts/:email',
            },
            GetContactById => {
                description =>
                    'Gets a contact by ID. Unsubscribed or suppressed contacts will not be retrieved.',
                method => 'GET',
                name   => 'GetContactById',
                path   => 'contacts/:id',
            },
            GetContactPreferences => {
                description => 'Gets the preferences for the specified contact',
                method      => 'GET',
                name        => 'GetContactPreferences',
                path        => 'contacts/:contactID/preferences',
            },
            GetContacts => {
                description  => 'Gets a list of all contacts in the account',
                method       => 'GET',
                name         => 'GetContacts',
                path         => 'contacts',
                query_params => [ 'withFullData', 'select', 'skip' ],
            },
            GetContactScore => {
                description => 'Gets particular contact scoring data.',
                method      => 'GET',
                name        => 'GetContactScore',
                path        => 'contacts/:id/score',
            },
            GetContactsCount => {
                description => 'Gets the total number of contacts in an account.',
                method      => 'GET',
                name        => 'GetContactsCount',
                path        => 'contacts/count',
            },
            GetContactsCreatedSinceDate => {
                description  => 'Gets a list of created contacts after a specified date.',
                method       => 'GET',
                name         => 'GetContactsCreatedSinceDate',
                path         => 'contacts/created-since/:date',
                query_params => [ 'withFullData', 'select', 'skip' ],
            },
            GetContactsDeletionDeletionRequestId => {
                description =>
                    'Gets the status of a previously started request to delete contacts from an address book.',
                method => 'GET',
                name   => 'GetContactsDeletionDeletionRequestId',
                path   => 'contacts/deletion/:deletionRequestId',
            },
            GetContactsGetAllContactsCount => {
                description => 'Gets the total number of contacts in an account.',
                method      => 'GET',
                name        => 'GetContactsGetAllContactsCount',
                path        => 'contacts/get-all-contacts-count',
            },
            GetContactsImportByImportId => {
                description => 'Gets the import status of a previously started contact import.',
                method      => 'GET',
                name        => 'GetContactsImportByImportId',
                path        => 'contacts/import/:importId',
            },
            GetContactsImportReport => {
                description =>
                    'Gets a report with statistics about what was successfully imported, and what was unable to be imported.',
                method => 'GET',
                name   => 'GetContactsImportReport',
                path   => 'contacts/import/:importId/report',
            },
            GetContactsImportReportFaults => {
                description =>
                    'Gets all records that were not successfully imported. The data are returned in CSV file, which is UTF-8 encoded. This data will only be available for approximately one week after import.',
                method => 'GET',
                name   => 'GetContactsImportReportFaults',
                path   => 'contacts/import/:importId/report-faults',
            },
            GetContactsModifiedSinceDate => {
                description  => 'Gets a list of modified contacts after a specified date.',
                method       => 'GET',
                name         => 'GetContactsModifiedSinceDate',
                path         => 'contacts/modified-since/:date',
                query_params => [ 'withFullData', 'select', 'skip' ],
            },
            GetContactsScore => {
                description  => 'Gets a list of contact scoring data.',
                method       => 'GET',
                name         => 'GetContactsScore',
                path         => 'contacts/score',
                query_params => [ 'select', 'skip' ],
            },
            GetContactsScoreModifiedSinceDate => {
                description  => 'Gets a list of contact scoring data ordered by modified date.',
                method       => 'GET',
                name         => 'GetContactsScoreModifiedSinceDate',
                path         => 'contacts/score/modified-since/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetContactsSuppressedSinceDate => {
                description =>
                    'Gets a list of suppressed contacts after a given date along with the reason for suppression.',
                method       => 'GET',
                name         => 'GetContactsSuppressedSinceDate',
                path         => 'contacts/suppressed-since/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetContactsTransactionalDataByKey => {
                description => 'Gets a piece of transactional data by key.',
                method      => 'GET',
                name        => 'GetContactsTransactionalDataByKey',
                path        => 'contacts/transactional-data/:collectionName/:key',
            },
            GetContactsTransactionalDataImportByImportId => {
                description =>
                    'Gets the import status of a previously started transactional import.',
                method => 'GET',
                name   => 'GetContactsTransactionalDataImportByImportId',
                path   => 'contacts/transactional-data/import/:importId',
            },
            GetContactsTransactionalDataImportReport => {
                description =>
                    'Gets a report with statistics about what was successfully imported, and what was unable to be imported.',
                method => 'GET',
                name   => 'GetContactsTransactionalDataImportReport',
                path   => 'contacts/transactional-data/import/:importId/report',
            },
            GetContactSubscriptions => {
                description => 'Gets the subscriptions for the specified contact',
                method      => 'GET',
                name        => 'GetContactSubscriptions',
                path        => 'contacts/:contactEmail/subscriptions',
            },
            GetContactsUnsubscribedSinceDate => {
                description =>
                    'Gets a list of unsubscribed contacts who unsubscribed after a given date.',
                method       => 'GET',
                name         => 'GetContactsUnsubscribedSinceDate',
                path         => 'contacts/unsubscribed-since/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetContactsWithPreferenceByPreferenceId => {
                description  => 'Gets a list of contacts subscribed to the specified preference',
                method       => 'GET',
                name         => 'GetContactsWithPreferenceByPreferenceId',
                path         => 'contacts/with-preference/:preferenceId',
                query_params => ['minContactId'],
            },
            GetContactsWithPreferenceOptInsSinceSinceDate => {
                description =>
                    'Gets a list of contacts who have opted in to a preference since the specified date',
                method       => 'GET',
                name         => 'GetContactsWithPreferenceOptInsSinceSinceDate',
                path         => 'contacts/with-preference/:preferenceId/opt-ins-since/:sinceDate',
                query_params => ['minContactId'],
            },
            GetContactTransactionalDataByCollectionName => {
                description =>
                    'Gets a list of all transactional data for a contact (100 most recent only).',
                method => 'GET',
                name   => 'GetContactTransactionalDataByCollectionName',
                path   => 'contacts/:id/transactional-data/:collectionName',
            },
            GetContactWithConsent => {
                description => 'Gets a contact by ID with consent records',
                method      => 'GET',
                name        => 'GetContactWithConsent',
                path        => 'contacts/:id/with-consent',
            },
            GetCustomFromAddresses => {
                description  => 'Gets all custom from addresses which can be used in a campaign.',
                method       => 'GET',
                name         => 'GetCustomFromAddresses',
                path         => 'custom-from-addresses',
                query_params => [ 'select', 'skip' ],
            },
            GetDataFields => {
                description => 'Lists the data fields within the account.',
                method      => 'GET',
                name        => 'GetDataFields',
                path        => 'data-fields',
            },
            GetDocumentFolderDocuments => {
                description => 'Gets all uploaded documents.',
                method      => 'GET',
                name        => 'GetDocumentFolderDocuments',
                path        => 'document-folders/:folderId/documents',
            },
            GetDocumentFolders => {
                description => 'Fetches the document folder tree structure.',
                method      => 'GET',
                name        => 'GetDocumentFolders',
                path        => 'document-folders',
            },
            GetEcommerceFullsummary => {
                description => 'Returns Retail KPI summaries across every data range',
                method      => 'GET',
                name        => 'GetEcommerceFullsummary',
                path        => 'ecommerce/fullsummary',
            },
            GetEcommerceSummaries => {
                description  => 'Returns the Retail KPI summaries for the specified date range',
                method       => 'GET',
                name         => 'GetEcommerceSummaries',
                path         => 'ecommerce/summaries',
                query_params => ['dateRange'],
            },
            GetEcommerceSummaryBySummaryType => {
                description  => 'Gets a KPI metric of a specified type over a specified date range',
                method       => 'GET',
                name         => 'GetEcommerceSummaryBySummaryType',
                path         => 'ecommerce/summary/:summaryType',
                query_params => ['dateRange'],
            },
            GetEmailStatsSinceDateByStartDate => {
                description  => 'Gets aggregated transactional email statistics.',
                method       => 'GET',
                name         => 'GetEmailStatsSinceDateByStartDate',
                path         => 'email/stats/since-date/:startDate',
                query_params => [ 'endDate', 'aggregatedBy' ],
            },
            GetImageFolderById => {
                description => 'Gets an image folder by id.',
                method      => 'GET',
                name        => 'GetImageFolderById',
                path        => 'image-folders/:id',
            },
            GetImageFolders => {
                description => 'Fetches the campaign image folder tree structure.',
                method      => 'GET',
                name        => 'GetImageFolders',
                path        => 'image-folders',
            },
            GetPreferences => {
                description => 'Gets the preferences, as a tree structure',
                method      => 'GET',
                name        => 'GetPreferences',
                path        => 'preferences',
            },
            GetPreferencesModifiedSinceSinceDate => {
                description =>
                    'Gets an array of preferences that have been modified since the specified date',
                method => 'GET',
                name   => 'GetPreferencesModifiedSinceSinceDate',
                path   => 'preferences/modified-since/:sinceDate',
            },
            GetProductsRecommendations => {
                description => 'Gets all product recommendations for the account.',
                method      => 'GET',
                name        => 'GetProductsRecommendations',
                path        => 'products/recommendations',
            },
            GetProgramById => {
                description => 'Gets a program by id.',
                method      => 'GET',
                name        => 'GetProgramById',
                path        => 'programs/:id',
            },
            GetPrograms => {
                description  => 'Gets all programs.',
                method       => 'GET',
                name         => 'GetPrograms',
                path         => 'programs',
                query_params => [ 'select', 'skip' ],
            },
            GetProgramsEnrolmentByEnrolmentId => {
                description => 'Gets an enrolment by id.',
                method      => 'GET',
                name        => 'GetProgramsEnrolmentByEnrolmentId',
                path        => 'programs/enrolments/:enrolmentId',
            },
            GetProgramsEnrolmentByStatus => {
                description  => 'Gets enrolments by status.',
                method       => 'GET',
                name         => 'GetProgramsEnrolmentByStatus',
                path         => 'programs/enrolments/:status',
                query_params => [ 'select', 'skip' ],
            },
            GetProgramsEnrolmentReportFaults => {
                description => 'Gets an enrolment by id.',
                method      => 'GET',
                name        => 'GetProgramsEnrolmentReportFaults',
                path        => 'programs/enrolments/:enrolmentId/report-faults',
            },
            GetSegments => {
                description  => 'Gets all segments.',
                method       => 'GET',
                name         => 'GetSegments',
                path         => 'segments',
                query_params => [ 'select', 'skip' ],
            },
            GetSegmentsRefreshById => {
                description => 'Gets the refresh progress for a segment.',
                method      => 'GET',
                name        => 'GetSegmentsRefreshById',
                path        => 'segments/refresh/:id',
            },
            GetServerTime => {
                description => 'Gets the UTC time as set on the server.',
                method      => 'GET',
                name        => 'GetServerTime',
                path        => 'server-time',
            },
            GetSmsCampaignById => {
                description => 'Get SMS Campaign by Id.',
                method      => 'GET',
                name        => 'GetSmsCampaignById',
                path        => 'sms/campaigns/:id',
            },
            GetSmsCampaigns => {
                description  => 'Get SMS Campaigns.',
                method       => 'GET',
                name         => 'GetSmsCampaigns',
                path         => 'sms/campaigns',
                query_params => [ 'select', 'skip' ],
            },
            GetSurveyById => {
                description => '[BETA] Gets a single survey by its ID.',
                method      => 'GET',
                name        => 'GetSurveyById',
                path        => 'surveys/:id',
            },
            GetSurveyFields => {
                description =>
                    '[BETA] Gets a list of survey pages, each containing a list of the fields on that page.',
                method => 'GET',
                name   => 'GetSurveyFields',
                path   => 'surveys/:id/fields',
            },
            GetSurveyResponses => {
                description  => '[BETA] Gets a list of all responses for a given survey.',
                method       => 'GET',
                name         => 'GetSurveyResponses',
                path         => 'surveys/:id/responses',
                query_params => [ 'select', 'skip' ],
            },
            GetSurveyResponsesWithActivitySinceDate => {
                description =>
                    '[BETA] Gets a list of responses that have changed since the specified date.',
                method       => 'GET',
                name         => 'GetSurveyResponsesWithActivitySinceDate',
                path         => 'surveys/:id/responses/with-activity-since/:date',
                query_params => [ 'select', 'skip' ],
            },
            GetSurveys => {
                description  => '[BETA] Gets a list of all surveys in the account.',
                method       => 'GET',
                name         => 'GetSurveys',
                path         => 'surveys',
                query_params => [ 'assignedToAddressBookOnly', 'select', 'skip' ],
            },
            GetSurveysWithActivitySinceDate => {
                description =>
                    '[BETA] Gets a list of surveys in the account that have changed since the specified date.',
                method       => 'GET',
                name         => 'GetSurveysWithActivitySinceDate',
                path         => 'surveys/with-activity-since/:date',
                query_params => [ 'assignedToAddressBookOnly', 'select', 'skip' ],
            },
            GetTemplateById => {
                description => 'Gets a template by ID.',
                method      => 'GET',
                name        => 'GetTemplateById',
                path        => 'templates/:id',
            },
            GetTemplates => {
                description  => 'Gets list of all templates.',
                method       => 'GET',
                name         => 'GetTemplates',
                path         => 'templates',
                query_params => [ 'select', 'skip' ],
            },
            GetTransactionalDataByCollectionName => {
                description =>
                    'Gets a list of account scoped transactional data for given collection',
                method       => 'GET',
                name         => 'GetTransactionalDataByCollectionName',
                path         => 'transactional-data/:collectionName',
                query_params => [ 'select', 'skip' ],
            },
            PostAccountsEmptyRecycleBin => {
                description => q[Empties the account's recycle bin.],
                method      => 'POST',
                name        => 'PostAccountsEmptyRecycleBin',
                path        => 'accounts/empty-recycle-bin',
            },
            PostAddressBookContacts => {
                description => 'Adds a contact to a given address book.',
                method      => 'POST',
                name        => 'PostAddressBookContacts',
                path        => 'address-books/:addressBookId/contacts',
            },
            PostAddressBookContactsDelete => {
                description =>
                    'Deletes multiple contacts from an address book. This will run in the background, and for larger address books may take some minutes to fully delete.',
                method => 'POST',
                name   => 'PostAddressBookContactsDelete',
                path   => 'address-books/:addressBookId/contacts/delete',
            },
            PostAddressBookContactsImport => {
                description =>
                    'Bulk creates, or bulk updates, contacts. Import format can either be CSV or Excel. Must include one column called \'Email\'. Any other columns will attempt to map to your custom data fields. The ID of returned object can be used to query import progress.',
                method => 'POST',
                name   => 'PostAddressBookContactsImport',
                path   => 'address-books/:addressBookId/contacts/import',
            },
            PostAddressBookContactsImportWithMergeOption => {
                description =>
                    'Bulk creates, or bulk updates, contacts with merge options. Import format can either be CSV or Excel. Must include one column called \'Email\'. Passing a valid \'mergeOption\' parameter is compulsory. Any other columns will attempt to map to your custom data fields. The ID of returned object can be used to query import progress.',
                method => 'POST',
                name   => 'PostAddressBookContactsImportWithMergeOption',
                path =>
                    'address-books/:addressBookId/contacts/import/with-merge-option/:mergeOption',
            },
            PostAddressBookContactsResubscribe => {
                description =>
                    'Resubscribes a previously unsubscribed contact to a given address book.',
                method => 'POST',
                name   => 'PostAddressBookContactsResubscribe',
                path   => 'address-books/:addressBookId/contacts/resubscribe',
            },
            PostAddressBookContactsResubscribeWithNoChallenge => {
                description =>
                    'Resubscribes a previously unsubscribed contact to a given address book with no challenge.',
                method => 'POST',
                name   => 'PostAddressBookContactsResubscribeWithNoChallenge',
                path   => 'address-books/:addressBookId/contacts/resubscribe-with-no-challenge',
            },
            PostAddressBookContactsUnsubscribe => {
                description => 'Unsubscribes contact from a given address book.',
                method      => 'POST',
                name        => 'PostAddressBookContactsUnsubscribe',
                path        => 'address-books/:addressBookId/contacts/unsubscribe',
            },
            PostAddressBooks => {
                description => 'Creates an address book.',
                method      => 'POST',
                name        => 'PostAddressBooks',
                path        => 'address-books',
            },
            PostCampaignAttachments => {
                description => 'Adds a document to a campaign as an attachment.',
                method      => 'POST',
                name        => 'PostCampaignAttachments',
                path        => 'campaigns/:campaignId/attachments',
            },
            PostCampaignCopy => {
                description => 'Copies a given campaign returning the new campaign.',
                method      => 'POST',
                name        => 'PostCampaignCopy',
                path        => 'campaigns/:campaignId/copy',
            },
            PostCampaigns => {
                description => 'Creates a campaign.',
                method      => 'POST',
                name        => 'PostCampaigns',
                path        => 'campaigns',
            },
            PostCampaignsSend => {
                description =>
                    'Sends a specified campaign to one or more address books, segments or contacts at a specified time. Leave the address book array empty to send to All Contacts.',
                method => 'POST',
                name   => 'PostCampaignsSend',
                path   => 'campaigns/send',
            },
            PostCampaignsSendTimeOptimised => {
                description =>
                    'Sends a specified campaign to one or more address books, segments or contacts at the most appropriate time based upon their previous open. Leave the address book array empty to send to All Contacts.',
                method => 'POST',
                name   => 'PostCampaignsSendTimeOptimised',
                path   => 'campaigns/send-time-optimised',
            },
            PostCampaignsSplitTest => {
                description => 'Creates a split test campaign.',
                method      => 'POST',
                name        => 'PostCampaignsSplitTest',
                path        => 'campaigns/split-test',
            },
            PostContacts => {
                description => 'Creates a contact.',
                method      => 'POST',
                name        => 'PostContacts',
                path        => 'contacts',
            },
            PostContactsImport => {
                description =>
                    'Bulk creates, or bulk updates, contacts. Import format can either be CSV or Excel. Must include one column called \'Email\'. Any other columns will attempt to map to your custom data fields. The ID of returned object can be used to query import progress.',
                method => 'POST',
                name   => 'PostContactsImport',
                path   => 'contacts/import',
            },
            PostContactsImportWithMergeOption => {
                description =>
                    'Bulk creates, or bulk updates, contacts with merge options. This API works on both contact data fields and marketing preferences. Import format can either be CSV or Excel. Must include one column called \'Email\'. Passing a valid \'mergeOption\' parameter is compulsory. Any other columns will attempt to map to your custom data fields. The ID of returned object can be used to query import progress.',
                method => 'POST',
                name   => 'PostContactsImportWithMergeOption',
                path   => 'contacts/import/with-merge-option/:mergeOption',
            },
            PostContactsResubscribe => {
                description => 'Resubscribes a previously unsubscribed contact.',
                method      => 'POST',
                name        => 'PostContactsResubscribe',
                path        => 'contacts/resubscribe',
            },
            PostContactsResubscribeWithNoChallenge => {
                description => 'Resubscribes a previously unsubscribed contact with no challenge.',
                method      => 'POST',
                name        => 'PostContactsResubscribeWithNoChallenge',
                path        => 'contacts/resubscribe-with-no-challenge',
            },
            PostContactsTransactionalData => {
                description  => 'Adds a single piece of transactional data to a contact.',
                method       => 'POST',
                name         => 'PostContactsTransactionalData',
                path         => 'contacts/transactional-data/:collectionName',
                query_params => [ 'Key', 'ContactIdentifier', 'Json' ],
            },
            PostContactsTransactionalDataImport => {
                description =>
                    'Adds multiple pieces of transactional data to contacts asynchronously, returning an identifier that can be used to check for import progress.',
                method       => 'POST',
                name         => 'PostContactsTransactionalDataImport',
                path         => 'contacts/transactional-data/import/:collectionName',
                query_params => [
                    'apiTransactionalData0Key',
                    'apiTransactionalData0ContactIdentifier',
                    'apiTransactionalData0Json',
                    'apiTransactionalData1Key',
                    'apiTransactionalData1ContactIdentifier',
                    'apiTransactionalData1Json',
                ],
            },
            PostContactsUnsubscribe => {
                description => 'Unsubscribes contact from account.',
                method      => 'POST',
                name        => 'PostContactsUnsubscribe',
                path        => 'contacts/unsubscribe',
            },
            PostContactsWithConsent => {
                description => 'Creates a contact with consent records.',
                method      => 'POST',
                name        => 'PostContactsWithConsent',
                path        => 'contacts/with-consent',
            },
            PostContactsWithConsentAndPreferences => {
                description => 'Creates a contact with consent and preference records.',
                method      => 'POST',
                name        => 'PostContactsWithConsentAndPreferences',
                path        => 'contacts/with-consent-and-preferences',
            },
            PostDataFields => {
                description => 'Creates a data field within the account.',
                method      => 'POST',
                name        => 'PostDataFields',
                path        => 'data-fields',
            },
            PostDocumentFolder => {
                description => 'Creates a new document folder.',
                method      => 'POST',
                name        => 'PostDocumentFolder',
                path        => 'document-folders/:folderId',
            },
            PostDocumentFolderDocuments => {
                description => 'Upload a document to the specified folder.',
                method      => 'POST',
                name        => 'PostDocumentFolderDocuments',
                path        => 'document-folders/:folderId/documents',
            },
            PostEcommerceSummaries => {
                description => 'Requests a refreshing of metric data',
                method      => 'POST',
                name        => 'PostEcommerceSummaries',
                path        => 'ecommerce/summaries',
            },
            PostEmail => {
                description =>
                    'Sends a transactional email. If sending to multiple recipients, please separate addresses with a comma.',
                method => 'POST',
                name   => 'PostEmail',
                path   => 'email',
            },
            PostEmailTriggeredCampaign => {
                description =>
                    'Sends a transactional email with content taken from a triggered campaign. If sending to multiple recipients, please separate addresses with a comma.',
                method => 'POST',
                name   => 'PostEmailTriggeredCampaign',
                path   => 'email/triggered-campaign',
            },
            PostImageFolder => {
                description => 'Creates a new campaign image folder.',
                method      => 'POST',
                name        => 'PostImageFolder',
                path        => 'image-folders/:id',
            },
            PostImageFolderImages => {
                description => 'Uploads a new campaign image to the specified folder.',
                method      => 'POST',
                name        => 'PostImageFolderImages',
                path        => 'image-folders/:folderId/images',
            },
            PostPreferences => {
                description => 'Creates a new preference or a new preference category',
                method      => 'POST',
                name        => 'PostPreferences',
                path        => 'preferences',
            },
            PostProgramsEnrolments => {
                description =>
                    'Creates an enrolment. Please note that your account can only call this a maximum of 20 times per hour, across all programs',
                method => 'POST',
                name   => 'PostProgramsEnrolments',
                path   => 'programs/enrolments',
            },
            PostSegmentsRefresh => {
                description => 'Refreshes a segment by ID.',
                method      => 'POST',
                name        => 'PostSegmentsRefresh',
                path        => 'segments/refresh/:id',
            },
            PostSmsCampaigns => {
                description => 'Create an SMS campaign.',
                method      => 'POST',
                name        => 'PostSmsCampaigns',
                path        => 'sms/campaigns',
            },
            PostSmsCampaignsCopy => {
                description => 'Copy an SMS Campaign.',
                method      => 'POST',
                name        => 'PostSmsCampaignsCopy',
                path        => 'sms/campaigns/copy',
            },
            PostSmsMessagesSendTo => {
                description => 'Send a single SMS message.',
                method      => 'POST',
                name        => 'PostSmsMessagesSendTo',
                path        => 'sms-messages/send-to/:telephoneNumber',
            },
            PostTemplates => {
                description => 'Creates a template.',
                method      => 'POST',
                name        => 'PostTemplates',
                path        => 'templates',
            },
            UpdateAddressBook => {
                description => 'Updates an address book.',
                method      => 'PUT',
                name        => 'UpdateAddressBook',
                path        => 'address-books/:id',
            },
            UpdateCampaign => {
                description => 'Updates a given campaign.',
                method      => 'PUT',
                name        => 'UpdateCampaign',
                path        => 'campaigns/:id',
            },
            UpdateContact => {
                description => 'Updates a contact.',
                method      => 'PUT',
                name        => 'UpdateContact',
                path        => 'contacts/:id',
            },
            UpdateContactPreferences => {
                description => 'Sets the subscribed preferences for a contact',
                method      => 'PUT',
                name        => 'UpdateContactPreferences',
                path        => 'contacts/:contactId/preferences',
            },
            UpdateContactWithConsent => {
                description => 'Updates a contact with consent records.',
                method      => 'PUT',
                name        => 'UpdateContactWithConsent',
                path        => 'contacts/:id/with-consent',
            },
            UpdateContactWithConsentAndPreferences => {
                description => 'Updates a contact with consent and preference records.',
                method      => 'PUT',
                name        => 'UpdateContactWithConsentAndPreferences',
                path        => 'contacts/:id/with-consent-and-preferences',
            },
            UpdatePreference => {
                description => 'Update the preference with the specified Id',
                method      => 'PUT',
                name        => 'UpdatePreference',
                path        => 'preferences/:id',
            },
            UpdateSmsCampaign => {
                description => 'Update an SMS campaign.',
                method      => 'PUT',
                name        => 'UpdateSmsCampaign',
                path        => 'sms/campaigns/:id',
            },
            UpdateTemplate => {
                description => 'Updates a template.',
                method      => 'PUT',
                name        => 'UpdateTemplate',
                path        => 'templates/:id',
            },
        };
    },
);

method commands () { return $self->endpoints; }

# ------------------------------------------------------------------------
has connection_cache => (
    is         => 'ro',
    isa        => 'LWP::ConnCache',
    lazy_build => 1,
);

method _build_connection_cache () { return LWP::ConnCache->new( total_capacity => 5 ); }

# ------------------------------------------------------------------------
has json_coder => (
    is         => 'ro',
    isa        => 'Cpanel::JSON::XS',
    lazy_build => 1,
);

method _build_json_coder () { return Cpanel::JSON::XS->new->utf8; }

# ------------------------------------------------------------------------
method BUILD ($args) {
    $self->user_agent( __PACKAGE__ . ' ' . ( $DotMailer::API::VERSION || '' ) );
    $self->base_url( $self->api_url . '/v' . $self->api_version );
    $self->auth_type('basic');
    $self->user( $self->username );
    $self->api_key( $self->password );
    $self->content_type('application/json');
    $self->decoder( sub { $self->json_coder->decode( shift || '{}' ) } );
    #
    # Now attempt a GetAccountInfo and fill in the correct API end point
    my $res = $self->GetAccountInfo;
    if ( $res->{code} == 200 ) {
        foreach my $prop ( @{ $res->{content}{properties} } ) {
            if ( $prop->{name} eq 'ApiEndpoint' ) {
                $self->api_url( $prop->{value} );
                $self->base_url( $self->api_url . '/v' . $self->api_version );
                last;
            }
        }
    }
    else {
        die "Unable to get account info";
    }
}

# ------------------------------------------------------------------------
method _build_agent () {
    my $ua = LWP::UserAgent->new(
        agent      => $self->user_agent,
        cookie_jar => $self->cookies,
        timeout    => $self->timeout,
        con_cache  => $self->connection_cache,
        keep_alive => 1,
        ssl_opts   => { verify_hostname => $self->strict_ssl },
    );
    return $ua;
}

# ------------------------------------------------------------------------

# ------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

1;

