# Unit 5 Analysis

### Task 5.1: Connect the tables

The three-table join returns 200 bookings with passenger names, flight numbers, and booking dates. A booking history report could use this to show who booked each flight and when.

The airport query returns flights 2, 3, 5, 10, and 11 for Changi Airport (SIN). Flights 2 and 3 share this connection, but that does not explain their higher no-show rates. The flight_routes junction table lets each flight connect to several airports without repeating flight information.

The self join compares flights from the same origin country. Flight 2 has 320 seats, compared with 90 and 193 for the other flights from Japan. Flight 3 also has 320 seats, the same as flight 5 from Korea. Flight 3 is inactive while the other Korean flights are active. We would need more information to connect these differences to no-shows.

### Task 5.2: Records joins exclude

The LEFT JOIN includes 15 distinct flights. The INNER JOIN includes 13, excluding:

| Flight ID | Flight number | Active |
|---|---|---|
| 14 | VN214 | Yes |
| 15 | VN215 | Yes |

Both flights have no bookings in this dataset. I used distinct flight IDs so multiple bookings would not inflate the flight count.

The LEFT JOIN returns 202 rows: 200 bookings plus the two flights without bookings. The reversed RIGHT JOIN returns the same rows. The FULL OUTER JOIN also returns 202 rows because every booking has a matching flight. A FULL OUTER JOIN could reveal unmatched records on either side, but here only flights lack matches.

NOT EXISTS and EXCEPT both identify flights 14 and 15. NOT EXISTS checks for missing matches. EXCEPT removes flights with bookings from the full flight list.

An INNER JOIN report would hide these two flights. Leadership should check whether they were available for booking and whether their records are complete before assuming low demand. Being marked active does not explain why they have no bookings.

### Task 5.3: Join performance

The CROSS JOIN returns 75 combinations: 15 flights × 5 airports. This could help build a checklist of possible routes. It does not show actual routes. Using it accidentally in a route report would include connections that do not exist.

The execution plan uses:

- **Hash Join** to connect bookings and passengers.
- **Nested Loop** with the flight primary key index to find matching flights.
- **Memoize** to reuse repeated flight lookups.
- **Sort** to put the results in booking ID order.

The tables are small, and the flight lookup has an index. Those features help explain the plan. Its row counts and costs are estimates, not actual timings. For example, it estimates 100 passengers while the table contains 30.

As bookings grow, reading and sorting more rows will take more work. More distinct flight IDs could also require more lookups. Reading the plan helps identify where that work happens.

### Reflection

PostgreSQL could choose a different join algorithm if table sizes, indexes, or the number of matching records changed. The current plan uses a Hash Join for passengers and a Nested Loop with an index lookup for flights.

If bookings grew to several million rows, repeated flight lookups could become more expensive. A Hash Join might then be a better choice, especially if the report still needed most bookings. Repeated flight IDs can reuse cached lookups, so the number of different IDs matters too.

An index could help when selecting a small number of bookings for one flight. For a report using nearly every booking, reading the whole table might still be cheaper. A Merge Join could become useful if both inputs were available in matching order.

More matching records also mean more rows to process and sort. PostgreSQL makes these choices using estimates. I would check the plan again after a large data change instead of assuming the same approach would always be best.