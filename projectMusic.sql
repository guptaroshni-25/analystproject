'Q1. Who is the senior most employee based on job title?'

select * from employee
Order by levels desc
	limit 1;
	
'Q2. Which countries  have the most invoices?'

select count(*) as c, billing_country
from invoice
	group by billing_country
	order by c desc;
	
Q3. What are the top 3 values of total invoice?
	select * from invoice
	order by total desc
	limit 3;

'Q4. Which city has the best customers? We would like to throw a promotional Music Festival 
in the city we made the most money. Write a query that returns one city that has the highest 
sum of invoice totals.Return both the cityname and sum of all invoice totals.'

	select Sum(total) as tota_invoice, billing_city
	from invoice
	group by billing_city
	order by tota_invoice desc;

'Q5. Who is the best customer? the customer who has spent the most money will be declared the best customer, Write a query that returns the
person whoo has spent the most money.'

select customer.customer_id, customer.first_name, customer.last_name , SUM(invoice.total) as total
	from customer
	Join invoice on customer.customer_id = invoice.customer_id
	group by customer.customer_id
	order by total desc
	limit 5;


'Q1:Write a query to return the email, first name, last name and genre of all Rock Music listeners.
Return your list ordered alphabetically by email starting with A.'

select email, first_name, last_name 
	from customer
	JOin invoice on customer.customer_id = invoice.customer_id
	Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
	where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
	)
	order by email;
	
'Q2:Lets invite the artists who have written the most rock music in our dataset. Write a query that
	returns the artist name and total track count of the top 10 roxk bands.'

select artist.name, artist.artist_id, Count(artist.artist_id) as NumofSongs
	from track
	Join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	join genre on genre.genre_id = track.genre_id
	Where genre.name like 'Rock'
	Group by artist.artist_id
	order by NumofSongs desc
	limit 10;
	
	
'Q3: Return all the track names that have a song length longer than the average song length.
	Return the name and milliseconds for each track. Order by the song length with the longest songs listed first'

select name, milliseconds from track
	where milliseconds > 
	(select avg(milliseconds) as AvgLength from track)
	order by milliseconds desc;


'Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent'

with best_selling_artist as(
	select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 5
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
	sum(il.unit_price*il.quantity) as amount_spent
	from invoice i
	join customer c on c.customer_id = i.customer_id
	join invoice_line il on il.invoice_id = i.invoice_id
	join track t on t.track_id = il.track_id
	join album alb on alb.album_id = t.album_id
	join best_selling_artist bsa on bsa.artist_id = alb.artist_id
	group by 1,2,3,4
	order by 5 desc;
	
	
'Q2: We want to find out the most poular music genre for each contry. We determine the most popular genre as the genre with the
	highest amount of purchases. Write a query that returns each country along with the top Genre.
	For countries where the maximum number of purchases is shared return all Genres'

with popular_genre as(
	select count(il.quantity) as purchases, c.country, g.name, g.genre_id,
	row_number() over(partition by c.country order by count(il.quantity) desc) as RowNo
	from invoice_line il
	Join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1
	
'Q3: Write a query that determines the customer that has spent the most on music for each country. Write a query for each country,
	Write a query that returns the ciuntry along with the top customer and how much they spent . For countries where the top amount spent is shared, provide
	all customers who spent this amount.'

with recursive
customer_with_country as(
	select c.customer_id,first_name,last_name,billing_country, Sum(total) as total_spend
	from invoice i
	Join customer c on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 2,3 desc
),

country_max_spending as(
	select billing_country, max(total_spend) as max_spending
	from customer_with_country
	group by billing_country
)

select cc.billing_country, cc.total_spend, cc.first_name, cc.last_name
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spend = ms.max_spending
order by 1;





