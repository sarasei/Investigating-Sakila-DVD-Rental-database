/* Query 1 - Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out. */
SELECT
  film_title,
  category_name,
  COUNT(film_title) AS rental_count
FROM
  (
    SELECT
      f.title film_title,
      c.name category_name,
      r.rental_id
    FROM
      film_category fc
      JOIN film f ON fc.film_id = f.film_id
      JOIN category c ON c.category_id = fc.category_id
      JOIN Inventory i ON i.film_id = f.film_id
      JOIN rental r ON r.inventory_id = i.Inventory_id
    WHERE
      c.name IN (
        'Children', 'Music', 'Classics', 'Comedy',
        'Family', 'Animation'
      )
  ) t1
GROUP BY
  film_title,
  category_name
ORDER BY
  category_name;
--------------------------------------------------------------

/* Query 2 - We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for */
SELECT
  DATE_PART('month', r.rental_date) rental_month,
  DATE_PART('year', r.rental_date) rental_year,
  st.store_id,
  COUNT(r.rental_id)
FROM
  rental r
  JOIN staff sf ON r.staff_id = sf.staff_id
  JOIN store st ON sf.store_id = st.store_id
GROUP BY
  1,
  2,
  3
ORDER BY
  4 DESC
  --------------------------------------------------------------

  /* Query 3 - We need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. */
SELECT
  f.title,
  c.name,
  f.rental_duration,
  NTILE(4) OVER (
    ORDER BY
      f.rental_duration
  ) AS standard_quartile
FROM
  film f
  JOIN film_category fc ON fc.film_id = f.film_id
  JOIN category c ON fc.category_id = c.category_id
WHERE
  c.name IN (
    SELECT
      c.name
    FROM
      category c
    WHERE
      c.name IN (
        'Children', 'Music', 'Family', 'Animation',
        'Classics', 'Comedy'
      )
  )
GROUP BY
  f.title,
  c.name,
  f.rental_duration
ORDER BY
  f.rental_duration;
--------------------------------------------------------------

/* Query 4 - provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category */
SELECT
  t1.name,
  t1.standard_quartile,
  COUNT(*)
FROM
  (
    SELECT
      c.name,
      f.rental_duration,
      NTILE(4) OVER (
        ORDER BY
          f.rental_duration
      ) AS standard_quartile
    FROM
      film f
      JOIN film_category fc ON fc.film_id = f.film_id
      JOIN category c ON fc.category_id = c.category_id
    WHERE
      c.name IN (
        'Children', 'Music', 'Family', 'Animation',
        'Classics', 'Comedy'
      )
  ) t1
GROUP BY
  t1.name,
  t1.standard_quartile
ORDER BY
  t1.name,
  t1.standard_quartile;
