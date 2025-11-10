SET SERVEROUTPUT ON SIZE 1000000
DECLARE
  -- Record that models a booking
  TYPE booking_rec IS RECORD (
    booking_id   PLS_INTEGER,
    client_name  VARCHAR2(60),
    room_type    VARCHAR2(30),
    check_in     DATE,
    check_out    DATE
  );

  -- Nested table of booking records
  TYPE booking_table IS TABLE OF booking_rec;
  bookings booking_table := booking_table();

  -- Associative array: room_type -> nightly rate
  TYPE rate_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  room_rate rate_map;

  -- Aggregation associative arrays indexed by room_type
  TYPE num_map IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);
  bookings_count num_map;
  total_nights  num_map;
  revenue_map   rate_map;

  -- Temporary variables
  idx PLS_INTEGER;
  k VARCHAR2(30);
  nights PLS_INTEGER;
  total_sum_nights PLS_INTEGER := 0;
  total_revenue NUMBER := 0;

  -- GOTO label for demonstration
  invalid_booking EXCEPTION;
  -- (we'll use explicit label instead of exception for goto)
BEGIN
  -- Initialize room rates (associative array)
  room_rate('Single') := 70000;
  room_rate('Double') := 120000;
  room_rate('Suite')  := 190000;

  -- Seed sample bookings (index as 1..n)
  bookings.EXTEND(5);
  bookings(1) := booking_rec(1, 'Alice', 'Single', TO_DATE('2025-10-01','YYYY-MM-DD'), TO_DATE('2025-10-03','YYYY-MM-DD'));
  bookings(2) := booking_rec(2, 'Bob',   'Double', TO_DATE('2025-10-05','YYYY-MM-DD'), TO_DATE('2025-10-07','YYYY-MM-DD'));
  bookings(3) := booking_rec(3, 'Celine','Suite',  TO_DATE('2025-09-25','YYYY-MM-DD'), TO_DATE('2025-10-01','YYYY-MM-DD'));
  bookings(4) := booking_rec(4, 'Roy',   'Single', TO_DATE('2025-10-10','YYYY-MM-DD'), TO_DATE('2025-10-12','YYYY-MM-DD'));
  bookings(5) := booking_rec(5, 'Mark',  'Double', TO_DATE('2025-10-15','YYYY-MM-DD'), TO_DATE('2025-10-12','YYYY-MM-DD')); -- invalid: check_out before check_in

  -- Intentionally delete booking 2 to demonstrate gaps
  bookings.DELETE(2); -- booking_id 2 removed from collection

  -- Initialize aggregator maps (will create keys lazily)
  -- Iterate bookings using FIRST/NEXT (resilient to gaps)
  idx := bookings.FIRST;
  WHILE idx IS NOT NULL LOOP
    -- Validate booking dates; if invalid, skip using GOTO (demo only)
    IF bookings(idx).check_out < bookings(idx).check_in THEN
      -- Demonstration of GOTO style skip: jump to label SKIP_BOOKING
      -- NOTE: GOTO is generally not recommended; prefer continue-style logic
      GOTO SKIP_BOOKING;
    END IF;

    -- compute nights
    nights := bookings(idx).check_out - bookings(idx).check_in;
    k := bookings(idx).room_type;

    -- Use EXISTS before reading/writing maps for clarity
    IF NOT bookings_count.EXISTS(k) THEN
      bookings_count(k) := 0;
      total_nights(k)  := 0;
      revenue_map(k)   := 0;
    END IF;

    -- update aggregations
    bookings_count(k) := bookings_count(k) + 1;
    total_nights(k)   := total_nights(k) + nights;

    -- revenue uses room_rate lookup
    IF room_rate.EXISTS(k) THEN
      revenue_map(k) := revenue_map(k) + (room_rate(k) * nights);
    ELSE
      -- unknown room type: treat as zero revenue (or handle error)
      DBMS_OUTPUT.PUT_LINE('Warning: Unknown room type for booking id ' || bookings(idx).booking_id);
    END IF;

    ::SKIP_BOOKING:
    NULL; -- target for GOTO; control resumes here when skipping

    idx := bookings.NEXT(idx);
  END LOOP;

  -- Print per-room-type aggregates
  DBMS_OUTPUT.PUT_LINE('--- Report per room type ---');
  k := bookings_count.FIRST;
  WHILE k IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('Room Type: ' || k);
    DBMS_OUTPUT.PUT_LINE('  Bookings: ' || bookings_count(k));
    DBMS_OUTPUT.PUT_LINE('  Total nights: ' || total_nights(k));
    DBMS_OUTPUT.PUT_LINE('  Revenue: ' || revenue_map(k));
    DBMS_OUTPUT.PUT_LINE('----------------------------');
    total_sum_nights := total_sum_nights + total_nights(k);
    total_revenue := total_revenue + revenue_map(k);
    k := bookings_count.NEXT(k);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Overall total nights: ' || total_sum_nights);
  DBMS_OUTPUT.PUT_LINE('Overall total revenue: ' || total_revenue);

  -- Show usage of COUNT and EXISTS directly
  DBMS_OUTPUT.PUT_LINE('Bookings collection COUNT (highest index): ' || bookings.COUNT);
  IF bookings.EXISTS(2) THEN
    DBMS_OUTPUT.PUT_LINE('Booking index 2 exists (should be false because we deleted it).');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Booking index 2 does not exist (as expected).');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unhandled error: ' || SQLERRM);
END;
/
