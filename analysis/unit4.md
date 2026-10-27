# Unit 4: SQL Aggregation and Grouping

## Definitions

For this analysis, an event is a booking, a producer is a flight, and an actor is a passenger. The numeric metric is fare_paid. I use booking_country as a regional dimension.

I count a failure when cancellation_reason is 'Passenger no show'. The denominator includes all bookings.

## Task 4.1: Measure the platform

### Platform summary

The dataset contains 200 bookings from 30 distinct passengers. Total fares are 3,628.19, and the average fare is 18.14. The minimum fare is 0.00, and the maximum is 70.86.

The zero minimum needs attention. All 34 zero-fare bookings have a cancelled status in the supplied data. This could explain the zeros, but I would check how fares are recorded after cancellation before deciding whether they are errors.

### Per-flight comparison

Flight 6 has the most bookings, with 21. Flight 4 has the fewest among flights with bookings, with 6.

Average fares also vary. Flight 5 has an average fare of 23.06, while flight 11 has an average of 11.94. Flight 6 has the most bookings but does not have the highest average fare.

The airline operations manager could use this breakdown to decide which flights need a closer review. An average fare hides the individual fares and their spread. A booking count also does not tell us how many different passengers made those bookings.

Next, I would look at the fare distribution, distinct passengers per flight, and booking dates.

### Minimum booking threshold

I chose at least 15 bookings as the threshold. This keeps 8 of the 13 flights with bookings and removes the smallest groups from the baseline comparison.

The threshold is a practical choice for this small dataset. It does not make the rates certain. For example, flight 4 has a 16.67% no-show rate, but that comes from only one no-show in six bookings.

### Two dimensions

Grouping by booking_country and flight_id gives one row for each country and flight combination present in the data. This lets regional readers compare activity, average fares, and no-show rates within their booking country.

Some combinations contain very few bookings, so their percentages need to be read alongside their booking counts.

## Task 4.2: Build the breakdown

### Part A: Conditional aggregation

The query answers two questions side by side:

- How many total bookings does each flight have?
- How many of those bookings are passenger no-shows?

COUNT(*) includes every booking. SUM with CASE counts only the bookings with the passenger no-show reason. This keeps bookings with missing reasons in the total.

Flight 2 has the most no-shows, with 3. Flight 3 follows with 2. Every other flight has either one or none.

### Part B: Regional subtotals and grand total

The regional director needs country subtotals rather than individual booking rows. Each named country row is a regional subtotal. The row labeled Platform total is the grand total.

Thailand has 4 no-shows out of 40 bookings, or 10.00%. Japan has 1 out of 43, or 2.33%.

The grand total shows 12 no-shows out of 200 bookings, or 6.00%. It supports a decision about overall platform performance. The country rows show where results differ, but no single country row gives the overall rate.

### Part C: CTE pipeline

The pipeline answers: What is the combined passenger no-show rate for flights with at least 15 bookings?

The CTE first counts bookings and no-shows for each flight. The outer query keeps qualifying flights and combines their counts.

The 8 qualifying flights have 145 bookings and 7 no-shows. Their combined rate is 4.83%. This is calculated from total no-shows divided by total bookings, rather than averaging the flight percentages.

## Reflection

Conditional aggregation lets one query count all bookings and passenger no-shows together. COUNT(*) counts every booking, while SUM(CASE WHEN ... THEN 1 ELSE 0 END) adds one only when a booking has the passenger no-show reason. Both results use the same rows and appear beside each other.

With two separate queries, I would first count all bookings and then run another query filtered to passenger no-shows. That is easy to understand, but it can require the database to read the same table twice. At a million rows, repeating that work can mean more reading and processing, especially when several metrics are needed.

Putting the counts together also makes the result easier to check. Each flight has its total and failure count on the same row, so I can calculate a rate without matching two separate outputs. It also helps avoid accidentally using different filters for the numerator and denominator.

The exact speed difference depends on how the database runs the queries. For this assignment, the main benefit is calculating related measures together while keeping the full booking count visible.

# Passenger No-Show Findings

We have 12 recorded passenger no-shows out of 200 bookings. The actual recorded no-show rate is 6%.

There are 34 cancelled bookings, but only 12 have the passenger no-show reason. The other cancellation reasons should not be counted as no-shows. Bookings with missing cancellation reasons remain part of the total count.

No-show rates vary across flights. The eight flights with at least 15 bookings have a combined rate of 4.

I would investigate two flights first:

| Flight ID | Total bookings | No-shows | No-show rate |
|---|---:|---:|---:|
| 2 | 16 | 3 | 18.75% |
| 3 | 13 | 2 | 15.38% |

Flights 2 and 3 account for 5 of the platform's 12 no-shows, or 42%. Flight 2 exceeds both the platform rate and the higher-volume baseline. Flight 3 also has an elevated rate, but falls below the 15-booking threshold.

Flight 4 has a rate of 17%, but that is based on one no-show in only six bookings. I would collect more data here. 

These results identify flights worth reviewing, but they do not explain why passengers did not show.