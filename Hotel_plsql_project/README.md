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


