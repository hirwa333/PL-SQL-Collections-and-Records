-- hotel_booking_plsql.sql
-- Demonstration of PL/SQL Collections, Records, and GOTO
-- Author: Hirwa Roy
-- Date: November 2025
-- Run this in Oracle SQL Developer or SQL*Plus

SET SERVEROUTPUT ON SIZE 1000000

DECLARE
  -- ===========================================
  -- 1. Record definition (Represents a booking)
  -- ===========================================
  TYPE booking_rec IS RECORD (
    booking_id   PLS_INTEGER,
    client_name  VARCHAR2(60),
    room_type    VARCHAR2(30),
    check_in     DATE,
    check_out    DATE
  );

  -- ===========================================
  -- 2. Nested table (Collection of records)
  -- ===========================================
  TYPE booking_table IS TABLE OF booking_rec;
  bookings booking_table := booking_table();

  -- ===========================================
  -- 3. Associative arrays for room data
  -- ===========================================
  TYPE rate_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  room_rate rate_map;

  TYPE num_map IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);
  bookings_count num_map;
  total_nights  num_map;
  revenue_map   rate_map;

  -- ===========================================
  -- 4. Variables
  -- ===========================================
  idx PLS_INTEGER;
  k VARCHAR2(30);
  nights PLS_INTEGER;
  total_sum_nights PLS_INTEGER := 0;
  total_revenue NUMBER := 0;

BEGIN
  -- ===========================================
  -- 5. Initialize room rates (Associative Array)
  -- ===========================================
  room_rate('Single') := 70000;
  room_rate('Double') := 120000;
  room_rate('Suite')  := 190000;

  -- ===========================================
  -- 6. Load sample booking data (Nested Table)
  -- ===========================================
  bookings.EXTEND(5);
  bookings(1) := booking_rec(1, 'Alice', 'Single', TO_DATE('2025-10-01','YYYY-MM-DD'), TO_DATE('2025-10-03','YYYY-MM-DD'));
  bookings(2) := booking_rec(2, 'Bob',   'Double', TO_DATE('2025-10-05','YYYY-MM-DD'), TO_DATE('2025-10-07','YYYY-MM-DD'));
  bookings(3) := booking_rec(3, 'Celine','Suite',  TO_DATE('2025-09-25','YYYY-MM-DD'), TO_DATE('2025-10-01','YYYY-MM-DD'));
  bookings(4) := booking_rec(4, 'Roy',   'Single', TO_DATE('2025-10-10','YYYY-MM-DD'), TO_DATE('2025-10-12','YYYY-MM-DD'));
  bookings(5) := booking_rec(5, 'Mark',  'Double', TO_DATE('2025-10-15','YYYY-MM-DD'), TO_DATE('2025-10-12','YYYY-MM-DD')); -- invalid dates

  -- Delete booking 2 to show .FIRST/.NEXT iteration
  bookings.DELETE(2);

  -- ===========================================
  -- 7. Process all bookings
  -- ===========================================
  idx := bookings.FIRST;
  WHILE idx IS NOT NULL LOOP
    -- Check for invalid dates
    IF bookings(idx).check_out < bookings(idx).check_in THEN
      GOTO SKIP_BOOKING;  -- Demonstrate GOTO (skip invalid booking)
    END IF;

    -- Compute stay length
    nights := bookings(idx).check_out - bookings(idx).check_in;
    k := bookings(idx).room_type;

    -- Initialize aggregation maps if first time seeing this room type
    IF NOT bookings_count.EXISTS(k) THEN
      bookings_count(k) := 0;
      total_nights(k)   := 0;
      revenue_map(k)    := 0;
    END IF;

    -- Update per-room-type totals
    bookings_count(k) := bookings_count(k) + 1;
    total_nights(k)   := total_nights(k) + nights;
    revenue_map(k)    := revenue_map(k) + (room_rate(k) * nights);

    ::SKIP_BOOKING::
    NULL; -- Label target (control resumes here)

    idx := bookings.NEXT(idx);
  END LOOP;

  -- ===========================================
  -- 8. Print report per room type
  -- ===========================================
  DBMS_OUTPUT.PUT_LINE('--- Hotel Booking Summary Report ---');
  k := bookings_count.FIRST;
  WHILE k IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('Room Type: ' || k);
    DBMS_OUTPUT.PUT_LINE('  Bookings: ' || bookings_count(k));
    DBMS_OUTPUT.PUT_LINE('  Total Nights: ' || total_nights(k));
    DBMS_OUTPUT.PUT_LINE('  Total Revenue: ' || revenue_map(k));
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    total_sum_nights := total_sum_nights + total_nights(k);
    total_revenue := total_revenue + revenue_map(k);
    k := bookings_count.NEXT(k);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Overall Total Nights: ' || total_sum_nights);
  DBMS_OUTPUT.PUT_LINE('Overall Total Revenue: ' || total_revenue);

  -- ===========================================
  -- 9. Demonstrate collection methods
  -- ===========================================
  DBMS_OUTPUT.PUT_LINE('Bookings collection COUNT: ' || bookings.COUNT);
  IF bookings.EXISTS(2) THEN
    DBMS_OUTPUT.PUT_LINE('Booking index 2 exists.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Booking index 2 does not exist (as expected).');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unhandled error: ' || SQLERRM);
END;
/
