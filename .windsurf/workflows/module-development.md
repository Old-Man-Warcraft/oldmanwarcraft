---
description: Create and develop new AzerothCore modules
---

# Module Development Workflow

## Overview
This workflow guides creation of new AzerothCore modules following project standards.

## Prerequisites
- Understanding of C++ and CMake
- AzerothCore development environment set up
- Module skeleton template available
- Access to development realm for testing

## Module Creation Steps

### 1. Create Module Structure
```bash
cd /root/azerothcore-wotlk/modules
./create_module.sh
```

**Prompts**:
- Module name (e.g., `mod-example-feature`)
- Module description
- Author name

**Generated structure**:
```
mod-example-feature/
├── CMakeLists.txt
├── conf/
│   └── example_feature.conf.dist
├── data/
│   └── sql/
│       ├── base/
│       └── updates/
├── src/
│   ├── ExampleFeature.cpp
│   ├── ExampleFeature.h
│   └── scripts/
└── README.md
```

### 2. Configure CMakeLists.txt

**Key sections**:
```cmake
# Set module name
set(MODULE_NAME ExampleFeature)

# Add source files
set(SOURCES
    src/ExampleFeature.cpp
)

# Add header files
set(HEADERS
    src/ExampleFeature.h
)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Create module library
add_library(${MODULE_NAME} STATIC ${SOURCES} ${HEADERS})
```

**Verify**:
- All source files listed
- All header files listed
- Include paths correct
- Module name matches directory

### 3. Create Configuration File

**File**: `conf/example_feature.conf.dist`

**Template**:
```
# Example Feature Module Configuration

# Enable/disable module
ExampleFeature.Enabled = 1

# Feature-specific settings
ExampleFeature.Setting1 = 0
ExampleFeature.Setting2 = 100
ExampleFeature.Setting3 = "default_value"
```

**Best practices**:
- All settings disabled by default (safety)
- Descriptive setting names
- Sensible default values
- Document all settings in comments

### 4. Create Base Database Schema

**File**: `data/sql/base/db_world/base_example_feature.sql`

**Template**:
```sql
-- Example Feature Module - Base Schema

-- Create custom table if needed
CREATE TABLE IF NOT EXISTS `example_feature_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `entry` int(10) unsigned NOT NULL,
  `value` int(10) unsigned NOT NULL DEFAULT 0,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_entry` (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Verify**:
- Table names descriptive
- Columns properly typed
- Primary keys defined
- Indexes on frequently queried columns
- Comments explain purpose

### 5. Create Update Scripts

**File**: `data/sql/updates/db_world/2026_02_03_00_example_feature.sql`

**Naming convention**: `YYYY_MM_DD_XX_description.sql`

**Template**:
```sql
-- Example Feature Module - Update 1
-- Description of changes

ALTER TABLE `example_feature_data` ADD COLUMN `new_column` int(10) unsigned DEFAULT 0;

-- Update existing data if needed
UPDATE `example_feature_data` SET `new_column` = 1 WHERE `entry` = 12345;
```

**Best practices**:
- One logical change per file
- Include descriptive comments
- Test on development realm first
- Backup before applying

### 6. Implement Module Class

**File**: `src/ExampleFeature.h`

```cpp
#ifndef EXAMPLE_FEATURE_H
#define EXAMPLE_FEATURE_H

#include "ScriptMgr.h"

class ExampleFeatureScript : public WorldScript
{
public:
    ExampleFeatureScript();
    
    void OnStartup() override;
    void OnShutdown() override;
    
private:
    bool IsEnabled() const;
};

#endif
```

**File**: `src/ExampleFeature.cpp`

```cpp
#include "ExampleFeature.h"
#include "Config.h"
#include "Log.h"

ExampleFeatureScript::ExampleFeatureScript() : WorldScript("ExampleFeature") { }

void ExampleFeatureScript::OnStartup()
{
    if (!IsEnabled())
        return;
    
    LOG_INFO("module.example_feature", "Example Feature Module loaded!");
}

void ExampleFeatureScript::OnShutdown()
{
    LOG_INFO("module.example_feature", "Example Feature Module unloaded!");
}

bool ExampleFeatureScript::IsEnabled() const
{
    return sConfigMgr->GetBoolDefault("ExampleFeature.Enabled", false);
}

void AddExampleFeatureScripts()
{
    new ExampleFeatureScript();
}
```

### 7. Create README.md

**Template**:
```markdown
# Example Feature Module

## Description
Brief description of what this module does.

## Features
- Feature 1
- Feature 2
- Feature 3

## Installation
1. Clone module into `modules/` directory
2. Rebuild AzerothCore
3. Configure `conf/example_feature.conf.dist`
4. Apply database updates

## Configuration
- `ExampleFeature.Enabled`: Enable/disable module (default: 0)
- `ExampleFeature.Setting1`: Description (default: 0)

## Usage
Instructions on how to use the module.

## Troubleshooting
Common issues and solutions.

## Contributing
Link to contribution guidelines.
```

### 8. Build and Test

**Build module**:
```bash
cd /root/azerothcore-wotlk
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=../env/dist
make -j$(nproc)
```

**Verify compilation**:
- No errors
- No warnings (if possible)
- All source files compiled

**Test on development realm**:
1. Start development server: `service ac-worldserver-dev start`
2. Enable module in config
3. Reload server
4. Check logs for module initialization
5. Test functionality

### 9. Database Integration

**Apply base schema**:
```bash
mysql -uacore -pacore acore_world < data/sql/base/db_world/base_example_feature.sql
```

**Apply updates**:
```bash
mysql -uacore -pacore acore_world < data/sql/updates/db_world/2026_02_03_00_example_feature.sql
```

**Verify**:
```sql
SHOW TABLES LIKE '%example_feature%';
DESCRIBE example_feature_data;
```

### 10. Documentation

**Create wiki page** (if applicable):
- Feature overview
- Configuration options
- Usage examples
- Troubleshooting guide
- API documentation (if applicable)

## Testing Checklist

- [ ] Module compiles without errors
- [ ] Module compiles without warnings
- [ ] CMakeLists.txt correctly configured
- [ ] Configuration file has sensible defaults
- [ ] Database schema created successfully
- [ ] Module initializes on server startup
- [ ] Module disables cleanly on shutdown
- [ ] Configuration options work as intended
- [ ] No conflicts with other modules
- [ ] Database updates apply cleanly
- [ ] README documentation complete
- [ ] Performance acceptable

## Common Issues

**Module doesn't compile**:
- Check CMakeLists.txt syntax
- Verify all source files exist
- Check include paths
- Review compiler errors carefully

**Module doesn't load**:
- Check server logs for errors
- Verify module is enabled in config
- Check database schema applied
- Verify no conflicting modules

**Configuration not working**:
- Verify setting names match code
- Check config file syntax
- Reload server after config changes
- Verify default values

**Database issues**:
- Backup before applying updates
- Check SQL syntax
- Verify table names match code
- Test on development realm first

## Useful Commands

```bash
# Create module
./create_module.sh

# Build
cmake .. && make -j$(nproc)

# Test on dev realm
service ac-worldserver-dev restart

# View logs
tail -f env/dist/logs-dev/Server.log

# Check module loaded
grep -i "module" env/dist/logs-dev/Server.log

# Apply database changes
mysql -uacore -pacore acore_world < data/sql/updates/db_world/update.sql
```

## Related Resources

- Module Creation Guide: https://www.azerothcore.org/wiki/Create-a-Module
- C++ Standards: https://www.azerothcore.org/wiki/cpp-code-standards
- Database Guide: https://www.azerothcore.org/wiki/database-world
- ScriptMgr API: https://github.com/azerothcore/azerothcore-wotlk/blob/master/src/server/game/Scripting/ScriptMgr.h
