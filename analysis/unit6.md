# Unit 6 Analysis

A booking is an event and a flight is a producer. I use `fare_paid` for fare comparisons. A failure is a booking with the cancellation reason `Passenger no show`. The rate uses all bookings in the denominator.

## Task 6.1 — Flight averages and rankings

Which bookings were far above or below the average fare for their flight? The window query returns all 200 bookings with the flight average beside each fare. Booking 18 on flight 2 was 47.81, or 30.79 above the flight average of 17.02. The `GROUP BY` version returns 13 rows, one for each flight with bookings. It gives me the same averages but drops the booking IDs and individual fares I need to find those differences.

The booking leaderboard includes all 15 flights, including two with zero bookings. Flights 5 and 7 both have 18 bookings. `ROW_NUMBER` gives them positions 4 and 5. `RANK` gives both fourth place and puts the next flight sixth. `DENSE_RANK` also gives both fourth place and puts the next flight fifth. I would use `RANK` for the operations dashboard leaderboard because flights with the same number of bookings should share a place.

`NTILE(4)` puts four flights in each of the first three bands and three in the last. Flight 5 is in band 1 and flight 7 is in band 2. The flight ID breaks the tie at the boundary. Both flights have the same booking volume, so I would use the bands to divide review work and show the actual counts when comparing flights.

## Task 6.2 — Booking changes over time

### A. Neighboring fares

Flight 2's fare went from 47.81 on May 4 to 15.22 on June 3, a drop of 32.59 between consecutive bookings. A change that large is a reason to check the two records for things like a fare multiplier, a cancellation, or a data entry problem. I would check for repeated changes before calling it a pricing trend. The first booking has no previous fare and the last has no next fare.

### B. Running total and moving average

I set a sample target of 50 bookings for the first quarter of 2023. The running total reached 50 on March 22 and ended at 53, three above target. A plain `SUM` gives me 53. The running total also shows when the team reached the target.

I used the latest seven days with bookings to smooth out a busy day without averaging over the whole quarter. The last seven active days averaged 1.00 booking each. Days without bookings are absent, so the last seven rows span March 15 through March 28. At the start there are fewer than seven rows in the average.

`ROWS` counts individual rows. With `RANGE` ending at the current row, rows tied on the sort value share the same frame, so a running total ordered by date would include every tied row on that date.

### C. Gaps

Three flights went more than 90 days between recorded bookings. Flight 9 had the longest gap, about 112 days from January 5 to April 28, 2023. Both bookings appear in the source data, so I can confirm a gap in recorded activity. To tell whether it was a real pause or a data issue, I would compare the flight's availability and reservation records for those dates.

## Task 6.3 — Top fares and monthly reporting

### A. Top three per flight

I would use this in a fare review panel for the operations team. Three bookings give the reviewer a short list and enough examples to see whether the top fare stands apart. For flight 4, the highest fare was 70.86 and the next two were 22.77 and 14.34. Showing one would hide that difference, and showing ten would turn the panel into a longer booking list. The report returns 39 rows across 13 flights. Equal fares at the cutoff are ordered by booking ID so the list stays at three rows per flight with at least three bookings.

### B. Month-to-month no-show rates

All 12 months of 2023 are present. The rate went from 11.76% in May to 5.00% in June, a relative drop of 57.50%. The counts went from two no-shows out of 17 bookings to one out of 20. I would look at the counts and check which flights had the no-shows before changing a policy based on a large percentage change. The percent change is blank when there is no prior month or when the prior rate is zero.

## Reflection

One question I would want to answer is which bookings were far above the usual fare for the same flight. I would start with the booking ID, flight ID, and fare. Then I would put the flight average on the same row and calculate the difference. For flight 2, I can point to booking 18 and see that its fare was 30.79 above the average. That gives me a specific record to check.

If I group by flight, I get one row with an average for each flight. I can compare two flights that way, but I lose the booking details that tell me which fares were unusual. Grouping by booking ID as well would give each booking its own group. I could calculate the averages first and join them back to the bookings, but that adds another step. The window version lets me keep the booking rows and calculate the flight average in the same query.

I would also check the zero fares before using the results to make a pricing decision. The average includes cancelled bookings, so I would first find out how the platform records the fare after a cancellation.