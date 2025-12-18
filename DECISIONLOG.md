## On not adding incremental logic into the Workday HCM History models
Generally, when working with large volume models like the ones created by Fivetran History Mode, we tend to implement incremental models. [See Salesforce](https://github.com/fivetran/dbt_salesforce?tab=readme-ov-file#optional-step-4-utilizing-salesforce-history-mode-records) for a particular example of that implementation. 

However, in the Workday HCM case, we have found that History Mode does not fit the use case for incremental logic due to the following reasons.
* Transactions can be future-dated. The most common case is an employee being hired for a future date beyond the current date, so an incremental run will pick up numerous records in the future, leading to potential duplications down the road for an employee's records.
* There are additional cases where an employee's record can be updated in the past beyond a common incremental window.

We welcome all attempts to optimize this strategy though, and would be open to enhancements to the package!

## Why we kept the worker position organization history model separate from the employee daily history model

The intent of the `workday__employee_daily_history` model was to combine historical data from all relevant worker history models and gather a daily look at that data based on employee and worker. 

However, with `stg_workday__worker_position_organization_history`, the values for organization are too customizable, and thus impossible to just into an `employee_daily_history` model with any clear definitions.

Instead we have decided to keep the model separate in `workday__worker_position_org_history`, leaving end customers the ability to configure what organizations they end up joining into the employee daily history within their warehouses. The `int_workday__employee_history` model provides a solid guide into configuring your own custom-type history mode model.

## Workday v42.2 API Schema Migration Strategy

### Overview
Workday is migrating to v42.2 API (Jan 5, 2025 - Apr 6, 2026 transition period) with significant schema changes including new tables with "_INCOMING" suffix and personal information fields split into specialized tables.

### Decision: Using Var Override Pattern for _INCOMING Tables (Base Models)
**Pattern adopted**: Variable override with automatic detection using `does_table_exist` macro at base model level only

**Example implementation**:
```sql
table_identifier='military_service_incoming' if var('workday__using_military_service_incoming', workday.does_table_exist('military_service_incoming')) else 'military_service'
```

**Rationale**:
1. **Automatic detection by default**: Package automatically detects which table exists in the warehouse
2. **User override capability**: Users can force use of old or new tables via dbt variables
3. **Follows established patterns**: Matches approach used in dbt_shopify for similar schema migrations
4. **Backward compatibility**: Ensures seamless operation during transition period (Jan 5, 2025 - Apr 6, 2026)
5. **Future-proof**: After transition period ends (Apr 6, 2026), package will automatically use new tables

**Configuration variables provided**:
- `workday__using_military_service_incoming`
- `workday__using_person_disability_incoming`
- `workday__using_personal_information_ethnicity_incoming`
- `workday__using_relative_name_incoming`

### Decision: Use Direct Var Check in Intermediate Models (No Schema Version Macro)
**Issue**: Intermediate models need to support both old and new personal information schemas without querying information schema (which causes performance degradation).

**Solution**: Use direct var check in intermediate models

**Implementation**:
- `int_workday__personal_details` checks `workday__using_personal_info_v2_schema` var directly
- Pattern: `{%- set use_new_schema = var('workday__using_personal_info_v2_schema', false) -%}`
- Defaults to `false` (old schema) for backward compatibility
- Users must explicitly opt-in to new schema via var configuration

**Why this approach**:
- **Simplicity**: No need for wrapper macro - just use var directly
- **Consistency**: Matches pattern used elsewhere (similar to var override in base models)
- **Performance**: No information schema queries during compilation
- **Explicit control**: Users explicitly choose which schema to use
- **Backward compatible**: Defaults to old schema

**Configuration variable**:
- `workday__using_personal_info_v2_schema` - Controls whether `int_workday__personal_details` uses new split tables (default: `false`)

### Decision: Update Existing int_workday__personal_details (Not Create New Model)
**Approach**: Updated existing intermediate model with conditional logic instead of creating new model

**Analysis factors**:
1. **Structural Compatibility**: Only 3 fields affected (date_of_birth, gender, is_hispanic_or_latino); grain unchanged
2. **Breaking Changes Assessment**: Fields just moving tables; can use conditional logic; end model schemas unchanged
3. **Backward Compatibility**: Must support both schemas during Phase 2 transition
4. **Complexity**: Low - only 3 fields affected with simple schema version check

**Implementation**:
- Uses direct var check to detect schema version: `var('workday__using_personal_info_v2_schema', false)`
- Conditional logic branches between:
  - **New schema**: Joins `personal_information_common_data` + `country_personal_information_data`
  - **Old schema**: Uses single `personal_information_history` table
- Final output schema identical regardless of source schema

**Benefits**:
- Maintains existing downstream dependencies (no changes to `workday__employee_overview`)
- Keeps model naming consistent
- Handles both schemas in one place
- Backward compatible by design
- Simple to understand and maintain

**Trade-offs considered**:
- **Alternative**: Create `int_workday__personal_details_v2` model
- **Rejected because**: Would require maintaining two models and updating end models with conditional logic; unnecessary complexity for only 3 fields changing locations with no grain change

### Decision: Create Staging Models for Core New Tables Only
**Tables created**:
- `stg_workday__personal_information_common_data`
- `stg_workday__country_personal_information_data`

**Tables deferred** (not currently used by core models):
- `stg_workday__personal_information_gender`
- `stg_workday__personal_information_pronoun`
- `stg_workday__personal_information_sexual_orientation`
- `stg_workday__sexual_orientation_and_gender_identity`

**Rationale**:
- Focus on critical path: `int_workday__personal_details` only needs common_data and country_data
- Other tables for multi-value conversions (pronoun, sexual_orientation) not used in current models
- Can be added later if needed for future enhancements
- Reduces initial migration scope and complexity

### Backward Compatibility Approach
1. **Phase 2 (Current - Jan 5, 2025 to Apr 6, 2026)**: Support both old and new tables
   - Base models use var override pattern
   - Intermediate models use conditional logic
   - Automatic detection ensures correct tables used
2. **Phase 3 (After Apr 6, 2026)**: New tables only
   - Old tables renamed to *_BACKUP_2026-04-06
   - Package will automatically use new tables via `does_table_exist` checks
   - No user action required 