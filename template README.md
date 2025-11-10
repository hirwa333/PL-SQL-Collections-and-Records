24174 HIRWA ROY

# Hotel Booking Analytics (PL/SQL Collections & Records Demo)

## Purpose
Demonstrates PL/SQL Collections (nested tables, associative arrays), Records, and use of GOTO in a controlled example.

## Files
- `src/demo_collections.sql` — main runnable script (prints a report).
- `src/utils_package.sql` — helper functions/procedures.
- `docs/DESIGN.md` — problem statement and design decisions.
- `docs/USAGE.md` — how to run and expected output.
- `docs/ASSESSMENT.md` — grading checklist and tests.

## How to run
1. Open SQL*Plus / SQL Developer and enable DBMS_OUTPUT (e.g., `SET SERVEROUTPUT ON`)
2. Run `@src/demo_collections.sql`
3. Inspect DBMS_OUTPUT for the report.

## Notes
- GOTO is used only for demonstration and explained in `docs/DESIGN.md`. Prefer structured control (IF/LOOP/RETURN) in production code.
