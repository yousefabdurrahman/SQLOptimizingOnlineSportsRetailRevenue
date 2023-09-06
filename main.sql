
-- Count all columns as total_rows
-- Count the number of non-missing entries for description, listing_price, and last_visited
-- Join info, finance, and traffic
select count(i.*) as total_rows,count(i.description) as count_description ,count(f.listing_price)as count_listing_price, count(t.last_visited) as count_last_visited
from info as i
left join finance as f
on i.product_id=f.product_id
left join traffic as t
on i.product_id=t.product_id

----------------------------------------------------------
-- Select the brand, listing_price as an integer, and a count of all products in finance 
-- Join brands to finance on product_id
-- Filter for products with a listing_price more than zero
-- Aggregate results by brand and listing_price, and sort the results by listing_price in descending order
select b.brand ,f.listing_price::int ,count(f.*)  
from brands as b
inner join finance as f
on b.product_id=f.product_id
where b.brand ='Adidas' or b.brand ='Nike' and f.listing_price>0
group by b.brand,f.listing_price
order by f.listing_price desc

--------------------------------
-- Select the brand, a count of all products in the finance table, and total revenue
-- Create four labels for products based on their price range, aliasing as price_category
-- Join brands to finance on product_id and filter out products missing a value for brand
-- Group results by brand and price_category, sort by total_revenue
select b.brand ,count(f.*), sum(f.revenue) as total_revenue,
case 
when f.listing_price < 42 then 'Budget'
when f.listing_price >= 42 and f.listing_price<74 then 'Average'
when f.listing_price>=74 and f.listing_price<129 then 'Expensive'
when f.listing_price>=129 then 'Elite'
end as price_category
from brands as b
left join finance as f 
on b.product_id=f.product_id
where brand is not null 
group by b.brand , price_category
order by total_revenue desc

-------------------------------------

-- Select brand and average_discount as a percentage
-- Join brands to finance on product_id
-- Aggregate by brand
-- Filter for products without missing values for brand
select b.brand , avg(f.discount)*100 as average_discount 
from brands as b 
inner join finance as f
on b.product_id = f.product_id
where b.brand is not null
group by b.brand

------------------------------------------------

-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id
select corr(r.reviews,f.revenue)as review_revenue_corr
from reviews as r 
left join finance as f
on r.product_id= f.product_id

-----------------------------------------


-- Calculate description_length
-- Convert rating to a numeric data type and calculate average_rating
-- Join info to reviews on product_id and group the results by description_length
-- Filter for products without missing values for description, and sort results by description_length
select (length(i.description)-length(i.description )%100)as description_length, round(avg(r.rating::numeric),2)as average_rating
from info as i
left join reviews as r
on i.product_id= r.product_id
where i.description is not null
group by description_length
order by description_length

---------------------------------

-- Select brand, month from last_visited, and a count of all products in reviews aliased as num_reviews
-- Join traffic with reviews and brands on product_id
-- Group by brand and month, filtering out missing values for brand and month
-- Order the results by brand and month
select b.brand, extract(month from t.last_visited)as month , count(r.product_id) as num_reviews
from traffic as t
inner join reviews as r
on t.product_id= r.product_id
inner join brands as b
on t.product_id = b.product_id
where extract(month from t.last_visited) is not null and b.brand is not null
group by b.brand,month
order by b.brand,month

-------------------------------


-- Create the footwear CTE, containing description and revenue
-- Filter footwear for products with a description containing %shoe%, %trainer, or %foot%
-- Also filter for products that are not missing values for description
-- Calculate the number of products and median revenue for footwear products
with footwear as(
    select i.description as description , f.revenue as revenue
    from info as i
    inner join finance as f
    on i.product_id=f.product_id
    where i.description ilike '%shoe%' or i.description ilike '%trainer%' or i.description ilike '%foot%'
)
select count(*)as num_footwear_products,PERCENTILE_disc(.5)
within group (order BY revenue) as median_footwear_revenue
from footwear

---------------------------------


-- Copy the footwear CTE from the previous task
-- Calculate the number of products in info and median revenue from finance
-- Inner join info with finance on product_id
-- Filter the selection for products with a description not in footwear
with footwear as(
    select i.description as description , f.revenue as revenue
    from info as i
    inner join finance as f
    on i.product_id=f.product_id
    where i.description ilike '%shoe%' or i.description ilike '%trainer%' or i.description ilike '%foot%'
)
select count(i.*) as num_clothing_products, percentile_disc(.5) within group(order by(f.revenue))as median_clothing_revenue
from info as i
inner join finance as f 
on i.product_id=f.product_id
where i.description not in (select description from footwear)


---------------------------

