# AzerothCore Module: Welcome Mail System

## Overview
Create a configurable module that automatically sends a welcome mail to characters upon their first login. The module should support configurable mail content (subject, body), currency, and items, with database tracking of recipients.

## Requirements

### Core Functionality
- Detect when a character logs in for the first time
- Send an in-game mail to the character automatically
- Store a record in the database indicating which characters have already received the welcome mail
- Prevent duplicate mail sending to the same character

### Configuration
Create a configuration file (e.g., `welcome_mail.conf`) with the following settings:

```ini
# Enable or disable the module
WelcomeMail.Enabled = 1

# Mail settings
WelcomeMail.Subject = "Welcome to the Server!"
WelcomeMail.Body = "Thank you for joining our server! Here are some starter items to help you on your journey."

# Currency to include (0 for none)
WelcomeMail.Gold = 100
WelcomeMail.Silver = 0
WelcomeMail.Copper = 0

# Items to include (format: itemID,count;itemID,count)
# Example: 25,5;38,10 would send 5 linen cloth and 5 healing potions
WelcomeMail.Items = "25,5;38,10"

# Mail sender name
WelcomeMail.Sender = "System"
```

### Database Schema
Create a table to track which characters have received the welcome mail:

```sql
CREATE TABLE IF NOT EXISTS `welcome_mail_sent` (
  `guid` INT(10) UNSIGNED NOT NULL COMMENT 'Character GUID',
  `account_id` INT(10) UNSIGNED NOT NULL COMMENT 'Account ID',
  `send_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`guid`),
  KEY `account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks characters who received welcome mail';
```

### Implementation Details

#### Hook Point
Use the `OnLogin` player script hook to detect first-time logins.

#### Logic Flow
1. On player login, check if the character's GUID exists in the `welcome_mail_sent` table
2. If not found:
   - Parse configuration settings
   - Send mail with configured subject, body, currency, and items
   - Insert record into `welcome_mail_sent` table
3. If found, do nothing

#### Error Handling
- Gracefully handle missing or invalid configuration values
- Log errors if mail sending fails
- Validate item IDs before attempting to send
- Handle database connection errors

### Module Structure
```
modules/
└── welcome_mail/
    ├── CMakeLists.txt
    ├── welcome_mail.conf
    ├── welcome_mail.cpp
    ├── welcome_mail.h
    └── README.md
```

### CMakeLists.txt
Standard AzerothCore module CMake configuration:
- Set module name
- Add source files
- Link against AzerothCore libraries
- Install configuration file

### Code Standards
- Follow AzerothCore coding conventions
- Use proper null checks
- Add appropriate logging using sLog->outMessage
- Include proper header guards
- Use smart pointers where applicable
- Comment complex logic

### Testing
- Test with module enabled and disabled
- Verify mail is sent only on first login
- Verify duplicate mail is not sent on subsequent logins
- Test with various configuration values
- Test with invalid item IDs (should not crash)
- Verify database records are created correctly
- Test with multiple characters on same account

### Documentation
Include a README.md with:
- Module description
- Installation instructions
- Configuration guide
- Database setup instructions
- Usage examples
- Troubleshooting tips
