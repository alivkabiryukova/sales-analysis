-- общее количество продавцов
select count(*) as customers_count
from customers c

-- топ 10 продавцов с наибольшей выручкой
select distinct
	e.first_name || ' ' || e.last_name as seller,
	count(s.sales_person_id) over (partition by s.sales_person_id) as operations,
	floor(sum(p.price * s.quantity) over (partition by s.sales_person_id)) as income
from employees e
join sales s on s.sales_person_id = e.employee_id
join products p on p.product_id = s.product_id
order by income desc
limit 10

-- продавцы, чья выручка ниже средней выручки всех продавцов
with tab1 as (
	select distinct
		e.first_name || ' ' || e.last_name as seller,
		floor(avg(p.price * s.quantity) over (partition by s.sales_person_id)) as average_income,
		floor(avg(p.price * s.quantity) over()) as income
	from employees e
	join sales s on s.sales_person_id = e.employee_id
	join products p on p.product_id = s.product_id
)

select
	seller,
	average_income
from tab1
where average_income < income
order by average_income;

-- выручка по каждому продавцу в разрезе дня недели
with tab1 as (
	select
		e.first_name || ' ' || e.last_name as seller,
		to_char(s.sale_date, 'day') as day_of_week,
		case
			when extract(dow FROM s.sale_date) = 0 then 7
			else extract(dow FROM s.sale_date)
			end as day_number,
		p.price * s.quantity as revenue
	from sales s
	join employees e on s.sales_person_id = e.employee_id
	join products p on s.product_id = p.product_id
)

select
	seller,
	day_of_week,
	floor(sum(revenue))
from tab1
group by seller, day_of_week, day_number
order by day_number, seller

-- количество покупателей по возрастным группам
select
	'16-25' as age_category,
	count(age) as age_count
from customers
where age between 16 and 25

union

select
	'26-40' as age_category,
	count(age) as age_count
from customers
where age between 26 and 40

union

select
	'40+' as age_category,
	count(age) as age_count
from customers
where age >= 40
order by age_category

-- количество уникальных покупателей и выручка по месяцам
select
	to_char(s.sale_date, 'YYYY-MM') as selling_month,
	count (distinct s.customer_id) as total_customers,
	sum(p.price * s.quantity) as income
from sales s
join products p on p.product_id = s.product_id
group by to_char(s.sale_date, 'YYYY-MM')

-- покупатели, чья первая покупка была по акции
with tab1 as (
	select
		concat(c.first_name, ' ', c.last_name) as customer,
		s.sale_date,
		concat(e.first_name, ' ', e.last_name) as seller,
		p.price,
		row_number() over (partition by c.customer_id order by c.customer_id, s.sale_date) as row_number
	from sales s
	join products p on s.product_id =p.product_id
	join employees e on s.sales_person_id = e.employee_id
	join customers c on s.customer_id = c.customer_id
)

select
	customer,
	sale_date,
	seller
from tab1
where row_number = 1 and price = 0
order by customer_id