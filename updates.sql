--Update and modify queries
update "service"
set cost = '$14,000'
where service_id = 2;

alter table car
RENAME column "fos sale" TO for_sale;

select * from car;

select * from service;

alter table "car"
alter column price Type INTEGER;

alter table "invoice"
alter column total_price Type NUMERIC(8,2);

alter table "invoice"
drop column "date";

alter table "service_invoice"
drop column "date";

ALTER TABLE invoice
ADD "date" DATE DEFAULT CURRENT_DATE;

ALTER TABLE service_invoice
ADD "date" DATE DEFAULT CURRENT_DATE;

alter table "part_invoice"
drop column "date";

ALTER TABLE part_invoice
ADD "date" DATE DEFAULT CURRENT_DATE;
