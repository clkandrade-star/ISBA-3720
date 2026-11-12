-- =====================================================================
-- PPM Group 4 verification query. Run after ppm_group4_data.sql.
-- Every row should show status = 'OK'.
-- =====================================================================
set search_path to ppm;

select check_name, expected, actual,
       case when expected = actual then 'OK' else 'PROBLEM' end as status
from (
  values
    ('Item types',              3::bigint, (select count(*) from item_type)),
    ('Items',                   9,         (select count(*) from item)),
    ('BOM lines',              11,         (select count(*) from bom_component)),
    ('Operations',             10,         (select count(*) from operation)),
    ('Routings (incl. revs)',   4,         (select count(*) from routing)),
    ('FG4-100 revisions',       2,         (select count(*) from routing r join item i using (item_id) where i.item_code = 'FG4-100')),
    ('Routing steps',          24,         (select count(*) from routing_step)),
    ('Inspection steps',       14,         (select count(*) from routing_step where requires_inspection)),
    ('Sales orders',            3,         (select count(*) from sales_order)),
    ('Sales order lines',       5,         (select count(*) from sales_order_line)),
    ('Units ordered',          36,         (select sum(quantity_ordered)::bigint from sales_order_line)),
    ('Production orders',       5,         (select count(*) from production_order)),
    ('Units to manufacture',   28,         (select sum(quantity_planned)::bigint from production_order)),
    ('Allocations',             5,         (select count(*) from production_allocation)),
    ('Allocations wrong item',  0,         (select count(*) from production_allocation pa
                                              join sales_order_line sol using (sales_order_line_id)
                                              join production_order po using (production_order_id)
                                              join routing r on r.routing_id = po.routing_id
                                             where r.item_id <> sol.item_id)),
    ('Shop-floor rows (must be 0)', 0,     (select (select count(*) from production_item)
                                                 + (select count(*) from operation_activity)
                                                 + (select count(*) from inspection)
                                                 + (select count(*) from rework_authorization)
                                                 + (select count(*) from correction)))
) as t(check_name, expected, actual);

-- Production order traceability: demand -> production order -> routing revision
select po.production_order_id                         as prod_order,
       so.sales_order_id                              as sales_order,
       so.customer_name,
       i.item_code,
       r.revision_no                                  as routing_rev,
       sol.quantity_ordered,
       sol.quantity_ordered - pa.allocated_quantity   as from_stock,
       po.quantity_planned                            as to_manufacture
from production_order po
join production_allocation pa using (production_order_id)
join sales_order_line sol using (sales_order_line_id)
join sales_order so using (sales_order_id)
join routing r on r.routing_id = po.routing_id
join item i on i.item_id = r.item_id
order by po.production_order_id;
