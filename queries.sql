-- общее количество продавцов
select count(*) as customers_count
from customers;

-- топ 10 продавцов с наибольшей выручкой
select
    e.first_name || ' ' || e.last_name as seller,
    count(s.sales_person_id) as operations,
    floor(sum(p.price * s.quantity)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by e.first_name, e.last_name
order by income desc
limit 10;

-- продавцы с выручкой ниже средней выручки всех продавцов
select
    e.first_name || ' ' || e.last_name as seller,
    floor(avg(p.price * s.quantity)) as average_income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by e.first_name, e.last_name
having
    floor(avg(p.price * s.quantity)) < (
        select floor(avg(p.price * s.quantity))
        from sales as s
        inner join products as p on s.product_id = p.product_id
    )
order by average_income;

-- выручка по каждому продавцу в разрезе дня недели
select
    e.first_name || ' ' || e.last_name as seller,
    to_char(s.sale_date, 'day') as day_of_week,
    floor(sum(p.price * s.quantity)) as revenue
from sales as s
inner join employees as e on s.sales_person_id = e.employee_id
inner join products as p on s.product_id = p.product_id
group by seller, day_of_week, extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;

-- количество покупателей по возрастным группам
select
    case
        when age >= 16 and age <= 25 then '16-25'
        when age >= 26 and age <= 40 then '26-40'
        else '40+'
    end as age_category,
    count(age) as age_count
from customers
group by age_category
order by age_category;

-- количество уникальных покупателей и выручка по месяцам
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(p.price * s.quantity)) as income
from sales as s
inner join products as p on s.product_id = p.product_id
group by to_char(s.sale_date, 'YYYY-MM');

-- покупатели, чья первая покупка была по акции
select distinct on (c.customer_id)
    concat(c.first_name, ' ', c.last_name) as customer,
    s.sale_date,
    concat(e.first_name, ' ', e.last_name) as seller
from sales as s
inner join products as p on s.product_id = p.product_id
inner join employees as e on s.sales_person_id = e.employee_id
inner join customers as c on s.customer_id = c.customer_id
where p.price = 0
order by c.customer_id;
