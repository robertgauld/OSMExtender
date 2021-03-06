@reminder_email
@email_reminder
@email_reminder_item
@reminder_mailer
@osm

Feature: Reminder Email
    As a section leader
    In order to keep on top of what's happening with my section
    I want to be reminded by email of key information on a weekly basis
    And I want to control which day the email is sent
    And I want to be able to edit the configuration of each part of the email

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	    | programme  | read    |
	    | register   | read    |
	    | badge      | read    |
	    | events     | read    |
	And no emails have been sent


    Scenario: Add reminder email
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Email reminders"
        And I follow "create one"
        And I select "Tuesday" from "Send on"
        And I press "Create Email reminder"
        Then I should see "successfully created"
        And I should see "now add some items to your reminder"
        And I should see "Tuesday"
	And I should see "This email reminder has no items yet"
        And "alice@example.com" should have 1 email reminder

    Scenario: Add reminder email (not the current section)
	Given an OSM request to "get roles" will give 2 roles
	And an OSM request to get_api_access for section "2" will have the permissions
	    | permission | granted |
	    | member     | read    |
	    | programme  | read    |
	    | register   | read    |
	    | badge      | read    |
		| events     | read    |
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Email reminders"
        And I follow "create one"
	And I select "1st Somewhere : Section 2" from "Section"
        And I select "Tuesday" from "Send on"
        And I press "Create Email reminder"
        Then I should see "successfully created"
	And I should see "1st Somewhere : Section 2"
	And I should see "now add some items to your reminder"
        And I should see "Tuesday"
	And I should see "This email reminder has no items yet"
        And "alice@example.com" should have 1 email reminder
        When I follow "Birthdays"
        And I press "Create birthdays item"
        Then I should see "Item was successfully added"
        When I follow "Events"
        And I press "Create events item"
        Then I should see "Item was successfully added"
        When I follow "add_email_reminder_item_programme"
        And I press "Create programme item"
        Then I should see "Item was successfully added"
        When I follow "Members not seen"
        And I press "Create members not seen item"
        Then I should see "Item was successfully added"
        When I follow "Advised absences"
        And I press "Create advised absences item"
        Then I should see "Item was successfully added"
        When I follow "Due badges"
        And I press "Create due badges item"
        Then I should see "Item was successfully added"
        When I follow "Section Notepad"
        And I press "Create section notepad item"
        Then I should see "Item was successfully added"

    Scenario: Should see only own reminders
        Given I have the following user records
	    | email_address     | name  |
	    | bob@example.com   | Bob   |
	And "bob@example.com" is connected to OSM
        And "bob@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a reminder email for section 1 on "Monday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
	Then I should see "Monday"
	And I should not see "Tuesday"

    Scenario: Message and no table when no reminders
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
	Then I should see "You do not currently have any email reminders"
	And I should not see "Send on"

    Scenario: Add birthday item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "Birthdays"
        And I fill in "How many months into the past?" with "3"
        And I fill in "How many months into the future?" with "4"
        And I press "Create birthdays item"
        Then I should see "Item was successfully added"
        And I should see "From 3 months ago to 4 months time." in the "Configuration" column of the "Birthdays" row

    Scenario: Add event item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "Events"
        And I fill in "How many months into the future?" with "6"
        And I press "Create events item"
        Then I should see "Item was successfully added"
        And I should see "For the next 6 months, without attendance breakdown." in the "Configuration" column of the "Events" row

    Scenario: Add programme item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "add_email_reminder_item_programme"
        And I fill in "How many weeks into the future?" with "8"
        And I press "Create programme item"
        Then I should see "Item was successfully added"
        And I should see "For the next 8 weeks." in the "Configuration" column of the "Programme" row

    Scenario: Add not seen item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "Members not seen"
        And I fill in "For how many weeks?" with "1"
		And I uncheck "Include leaders?"
        And I press "Create members not seen item"
        Then I should see "Item was successfully added"
        And I should see "In the last 1 week, excluding leaders." in the "Configuration" column of the "Members not seen" row

    Scenario: Add advised absences item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "Advised absences"
        And I fill in "For how many weeks?" with "1"
        And I press "Create advised absences item"
        Then I should see "Item was successfully added"
        And I should see "For the next 1 week." in the "Configuration" column of the "Advised absences" row

    Scenario: Add due badge item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "Due badges"
        And I press "Create due badges item"
        Then I should see "Item was successfully added"
        And I should see "Without badge stock levels." in the "Configuration" column of the "Due badges" row

    Scenario: Add notepad item to reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "Section Notepad"
        And I press "Create section notepad item"
        Then I should see "Item was successfully added"
        And I should see "There are no settings for this item." in the "Configuration" column of the "Section Notepad" row

    Scenario: Message and no list when no more items to add to reminder
	Given "alice@example.com" has a reminder email for section 1 on "Tuesday" with all items
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
	Then I should see "There are no more items you can add"
	And I should not see "You can add an item"

    Scenario: Edit reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I select "Wednesday" from "Send on"
        And I press "Update Email reminder"
        Then I should see "successfully updated"
        And I should see "Wednesday"

    Scenario: Edit birthday item in reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a birthday item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Birthdays" row
        And I fill in "How many months into the past?" with "3"
        And I fill in "How many months into the future?" with "4"
        And I press "Update birthdays item"
        Then I should see "Item was successfully updated"
        And I should see "From 3 months ago to 4 months time." in the "Configuration" column of the "Birthdays" row

    Scenario: Edit event item in reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has an event item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Events" row
		And I check "Include attendance breakdown?"
        And I fill in "How many months into the future?" with "6"
        And I press "Update events item"
        Then I should see "Item was successfully updated"
        And I should see "For the next 6 months, with attendance breakdown." in the "Configuration" column of the "Events" row

    Scenario: Edit programme item in reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a programme item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Programme" row
        And I fill in "How many weeks into the future?" with "8"
        And I press "Update programme item"
        Then I should see "Item was successfully updated"
        And I should see "For the next 8 weeks." in the "Configuration" column of the "Programme" row

    Scenario: Edit not seen item in reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a not seen item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Members not seen" row
        And I fill in "For how many weeks?" with "1"
		And I check "Include leaders?"
        And I press "Update members not seen item"
        Then I should see "Item was successfully updated"
        And I should see "In the last 1 week." in the "Configuration" column of the "Members not seen" row
        And I should not see "excluding leaders." in the "Configuration" column of the "Members not seen" row

    Scenario: Edit advised absences item in reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has an advised absences item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Advised absence" row
        And I fill in "For how many weeks?" with "1"
        And I press "Update advised absences item"
        Then I should see "Item was successfully updated"
        And I should see "For the next 1 week." in the "Configuration" column of the "Advised absences" row

    Scenario: Edit due badges item in reminder email
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a due badges item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Due badges" row
        And I check "Show stock level of badges?"
        And I press "Update due badges item"
        Then I should see "Item was successfully updated"
        And I should see "With badge stock levels." in the "Configuration" column of the "Due badges" row


    Scenario: Edit birthday item in reminder email (invalid configuration)
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a birthday item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Birthdays" row
        And I fill in "How many months into the past?" with "invalid"
        And I fill in "How many months into the future?" with "invalid"
        And I press "Update birthdays item"
        Then I should not see "Item was successfully updated"
        And "How many months into the past?" should contain "2"
        And "How many months into the future?" should contain "1"

    Scenario: Edit event item in reminder email (invalid configuration)
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has an event item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Events" row
        And I fill in "How many months into the future?" with "invalid"
        And I press "Update events item"
        Then I should not see "Item was successfully updated"
        And "How many months into the future?" should contain "3"

    Scenario: Edit programme item in reminder email (invalid configuration)
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a programme item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Programme" row
        And I fill in "How many weeks into the future?" with "invalid"
        And I press "Update programme item"
        Then I should not see "Item was successfully updated"
        And "How many weeks into the future?" should contain "4"

    Scenario: Edit not seen item in reminder email (invalid configuration)
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a not seen item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Members not seen" row
        And I fill in "For how many weeks?" with "invalid"
        And I press "Update members not seen item"
        Then I should not see "Item was successfully updated"
        And "For how many weeks?" should contain "2"

    Scenario: Edit advised absences item in reminder email (invalid configuration)
        Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has an advised absences item in her "Tuesday" email reminder for section 1
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit]" in the "Actions" column of the "Tuesday" row
        And I follow "[Edit]" in the "Actions" column of the "Advised absences" row
        And I fill in "For how many weeks?" with "invalid"
        And I press "Update advised absences item"
        Then I should not see "Item was successfully updated"
        And "For how many weeks?" should contain "2"


    Scenario: Preview the email
	Given "alice@example.com" has a reminder email for section 1 on "Tuesday" with all items
	And an OSM request to get sections will give 1 section
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | email1         | email2         | email3         | email4         | grouping_id | date_of_birth |
	    | a1@example.com | a2@example.com | a3@example.com | a4@example.com | 1           |               |
	    | b1@example.com | b2@example.com | b3@example.com | b4@example.com | 2           | 0000-00-00    |
	And an OSM request to get events for section 1 will have the events
	    | name    | in how many days |
	    | Event 1 | 7                |
	    | Event 2 | 300              |
	And an OSM request to get event 1 in section 1 will have no fields
	And an OSM request to get event 2 in section 1 will have no fields
	And an OSM request to get programme for section 1 term 1 will have 2 programme items
	And an OSM request to get activity 11 will have tags "global"
	And an OSM request to get activity 12 will have tags "outdoors"
	And an OSM request to get activity 21 will have tags "belief, values"
	And an OSM request to get activity 22 will have tags "global, outdoors"
	And an OSM request to get the register structure for term 1 and section 1 will cover the last 4 weeks
	And an OSM request to get the register for term 1 and section 1 will have the following members and attendance
	    | name  | from weeks ago | to weeks ago |
	    | Alice | 4              | 1            |
	    | Bob   | 4              | 3            |
	And an OSM request to get due badges for section 1 and term 1 will result in the following being due their "Test" badge
	    | name  | completed | extra |
	    | Alice | 4         | info  |
	    | Bob   | 5         |       |
	And an OSM request to get the notepad for section 1 will give "This is a test notepad message."
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Preview]" in the "Actions" column of the "Tuesday" row
        Then I should see "This is your reminder email for Section 1 (1st Somewhere)"
	And I should not see "Fake data has been used in order to ensure that all the selected items have something to show."
	And I should see "Section Notepad"
	And I should see "Birthdays"
        And I should see "Due Badges"
        And I should see "Events"
        And I should see "Programme"
        And I should see "Members Not Seen"
	And I should see "Advised Absence"

    Scenario: Sample the email
	Given "alice@example.com" has a reminder email for section 1 on "Tuesday" with all items
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Sample]" in the "Actions" column of the "Tuesday" row
        Then I should see "This is your reminder email for Section 1 (1st Somewhere)"
	And I should see "Fake data has been used in order to ensure that all the selected items have something to show."
	And I should see "Section Notepad"
	And I should see "Birthdays"
        And I should see "Due Badges"
        And I should see "Events"
        And I should see "Programme"
        And I should see "Members Not Seen"
	And I should see "Advised Absence"


    @send_email
    Scenario: Send the email
	Given "alice@example.com" has a reminder email for section 1 on "Tuesday" with all items
	And an OSM request to get sections will give 1 section
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | email1         | email2         | email3         | email4         | grouping_id | date_of_birth |
	    | a1@example.com | a2@example.com | a3@example.com | a4@example.com | 1           |               |
	    | b1@example.com | b2@example.com | b3@example.com | b4@example.com | 2           | 0000-00-00    |
	And an OSM request to get events for section 1 will have the events
	    | name    | in how many days |
	    | Event 1 | 7                |
	    | Event 2 | 300              |
	And an OSM request to get event 1 in section 1 will have no fields
	And an OSM request to get event 2 in section 1 will have no fields
	And an OSM request to get programme for section 1 term 1 will have 2 programme items
	And an OSM request to get activity 11 will have tags "global"
	And an OSM request to get activity 12 will have tags "outdoors"
	And an OSM request to get activity 21 will have tags "belief, values"
	And an OSM request to get activity 22 will have tags "global, outdoors"
	And an OSM request to get the register structure for term 1 and section 1 will cover the last 4 weeks
	And an OSM request to get the register for term 1 and section 1 will have the following members and attendance
	    | name  | from weeks ago | to weeks ago |
	    | Alice | 4              | 1            |
	    | Bob   | 4              | 3            |
	And an OSM request to get due badges for section 1 and term 1 will result in the following being due their "Test" badge
	    | name  | completed | extra |
	    | Alice | 4         | info  |
	    | Bob   | 5         |       |
	And an OSM request to get the notepad for section 1 will give "This is a test notepad message."

        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Send]" in the "Actions" column of the "Tuesday" row
	Then "alice@example.com" should receive 1 email with subject "Reminder Email for Section 1 (1st Somewhere)"

        When "alice@example.com" opens the email with subject "Reminder Email for Section 1 (1st Somewhere)"
        Then I should see "This is your reminder email for Section 1 (1st Somewhere)" in the email body
	And I should see "Section Notepad" in the email body
	And I should see "Birthdays" in the email body
        And I should see "Due Badges" in the email body
        And I should see "Events" in the email body
        And I should see "Programme" in the email body
        And I should see "Members Not Seen" in the email body

    @send_email
    Scenario: An item has an error
	Given "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a due badges item in her "Tuesday" email reminder for section 1
	And an OSM request to get sections will give 1 section
	And an OSM request to get terms for section 1 will have no terms

        When "alice@example.com"'s reminder email for section 1 on "Tuesday" is sent
	Then "alice@example.com" should receive 1 email with subject "Reminder Email for Section 1 (1st Somewhere)"

        When "alice@example.com" opens the email with subject "Reminder Email for Section 1 (1st Somewhere)"
        Then I should see "Due Badges - There is no current term for the section." in the email body
