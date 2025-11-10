# PL/SQL Collections, Records, and GOTO Demonstration
**Author:** Hirwa Roy   24174
**Date:**7th November 2025  

---

##  Objective
This mini project demonstrates the use of **PL/SQL advanced features**:
- Collections (`Nested Table`, `Associative Array`)
- Records (`RECORD` type)
- GOTO statements (for demonstration purposes)

The scenario simulates a **hotel booking system** that calculates the total number of nights and total revenue per room type.

---

##  Features Demonstrated

| Concept | Example in Code | Explanation |
|----------|----------------|-------------|
| **Record** | `booking_rec` | Defines one booking’s structure (id, name, type, dates). |
| **Nested Table** | `booking_table` | Stores multiple booking records in memory. |
| **Associative Array** | `room_rate`, `bookings_count`, `revenue_map` | Maps room types to rates and totals. |
| **GOTO Statement** | `GOTO SKIP_BOOKING;` | Skips invalid bookings (check-out before check-in). |
| **.FIRST / .NEXT** | Iterates safely even when collection has deleted items. |

---

## Sample Output
--- Hotel Booking Summary Report ---
Room Type: Single
Bookings: 2
Total Nights: 4
Total Revenue: 280000
Room Type: Suite
Bookings: 1
Total Nights: 6
Total Revenue: 1140000

Overall Total Nights: 10
Overall Total Revenue: 1420000
Bookings collection COUNT: 5
Booking index 2 does not exist (as expected).


---

## ⚙️ How to Run

1. Open **Oracle SQL Developer** or **SQL*Plus**.  
2. Run the command:

   ```sql
   SET SERVEROUTPUT ON SIZE 1000000
   @hotel_booking_plsql.sql


View the printed output in the “DBMS Output” panel.

📘 Explanation of GOTO

In this example, the GOTO statement skips any invalid booking entry where the check-out date is earlier than the check-in date.
Example:

IF bookings(idx).check_out < bookings(idx).check_in THEN
  GOTO SKIP_BOOKING;
END IF;

