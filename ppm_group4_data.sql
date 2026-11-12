-- =====================================================================
-- PPM Group 4 data load (Group4_TraceabilityData.docx)
-- Run ONCE in the Supabase SQL Editor, after ppm_schema.sql.
-- Runs as one transaction: if anything fails, nothing is saved.
--
-- ID conventions (the ERD has no separate "code" column for these):
--   operation_id        = number in the operation code   (OP-10  -> 10)
--   sales_order_id      = digits of the sales order no.  (SO4-101 -> 4101)
--   production_order_id = digits of the prod. order no.  (PO4-201 -> 4201)
-- Items keep their real codes in item.item_code (FG4-100, etc.).
-- =====================================================================

begin;
set search_path to ppm;

-- ---------------------------------------------------------------------
-- Item types
-- ---------------------------------------------------------------------
insert into item_type (item_type_id, type_code, type_name) values
  (1, 'FG', 'Finished Good'),
  (2, 'SA', 'Subassembly'),
  (3, 'RM', 'Raw Material');

-- ---------------------------------------------------------------------
-- Items (section B)
-- ---------------------------------------------------------------------
insert into item (item_id, item_type_id, item_code, item_name, description, base_unit_of_measure) values
  (1, 1, 'FG4-100', 'Pipe Support Clamp',        'Finished good: secures a single pipe',                       'EA'),
  (2, 1, 'FG4-110', 'Dual Pipe Clamp',           'Finished good: two backing subassemblies, supports two pipes', 'EA'),
  (3, 2, 'SA4-100', 'Clamp Backing Subassembly', 'Subassembly used by FG4-100 and FG4-110',                     'EA'),
  (4, 3, 'RM4-100', 'U-Bolt',                    'Raw material',                                                'EA'),
  (5, 3, 'RM4-110', 'Clamp Plate',               'Raw material',                                                'EA'),
  (6, 3, 'RM4-120', 'Rubber Insert',             'Raw material',                                                'EA'),
  (7, 3, 'RM4-130', 'M8 Nut',                    'Raw material',                                                'EA'),
  (8, 3, 'RM4-140', 'Washer',                    'Raw material',                                                'EA'),
  (9, 3, 'RM4-150', 'Mounting Channel',          'Raw material',                                                'EA');

-- ---------------------------------------------------------------------
-- Bill of materials (section B, Product Composition)
-- ---------------------------------------------------------------------
insert into bom_component (bom_component_id, parent_item_id, component_item_id, quantity_per) values
  -- SA4-100 Clamp Backing Subassembly
  ( 1, 3, 5, 1),   -- Clamp Plate
  ( 2, 3, 9, 1),   -- Mounting Channel
  ( 3, 3, 7, 2),   -- M8 Nut
  -- FG4-100 Pipe Support Clamp
  ( 4, 1, 3, 1),   -- Clamp Backing Subassembly
  ( 5, 1, 4, 1),   -- U-Bolt
  ( 6, 1, 6, 1),   -- Rubber Insert
  ( 7, 1, 8, 2),   -- Washer
  -- FG4-110 Dual Pipe Clamp
  ( 8, 2, 3, 2),   -- Clamp Backing Subassembly
  ( 9, 2, 4, 2),   -- U-Bolt
  (10, 2, 6, 2),   -- Rubber Insert
  (11, 2, 8, 4);   -- Washer

-- ---------------------------------------------------------------------
-- Operations (section A)
-- ---------------------------------------------------------------------
insert into operation (operation_id, operation_name, description) values
  ( 10, 'Material preparation and cutting',       'OP-10'),
  ( 20, 'Drilling and hole preparation',          'OP-20'),
  ( 30, 'Clamp backing assembly',                 'OP-30'),
  ( 40, 'U-bolt installation',                    'OP-40'),
  ( 50, 'Rubber insert installation',             'OP-50'),
  ( 60, 'Pipe clamp positioning and alignment',   'OP-60'),
  ( 70, 'Nut fastening and torque adjustment',    'OP-70'),
  ( 80, 'Dimensional and alignment verification', 'OP-80'),
  ( 90, 'Clamp load and stability testing',       'OP-90'),
  (100, 'Packaging and labeling',                 'OP-100');

-- ---------------------------------------------------------------------
-- Routings and revisions (section C)
-- Effective dates are not given in the source data; 2026-11-01 assumed.
-- ---------------------------------------------------------------------
insert into routing (routing_id, item_id, revision_no, effective_date, obsolete_date, routing_status) values
  (1, 3, 'A', '2026-11-01', null, 'Approved'),   -- SA4-100 Standard Clamp Backing Assembly
  (2, 1, 'A', '2026-11-01', null, 'Approved'),   -- FG4-100 Standard Pipe Support Clamp
  (3, 1, 'B', '2026-11-01', null, 'Approved'),   -- FG4-100 Enhanced Load Verification
  (4, 2, 'A', '2026-11-01', null, 'Approved');   -- FG4-110 Dual Pipe Clamp Assembly

insert into routing_step (routing_step_id, routing_id, operation_id, sequence_no, requires_inspection) values
  -- C1. SA4-100 Rev A
  ( 1, 1,  10, 10, false),
  ( 2, 1,  20, 20, true ),
  ( 3, 1,  30, 30, false),
  ( 4, 1,  80, 40, true ),
  -- C2. FG4-100 Rev A (Standard)
  ( 5, 2,  40, 10, false),
  ( 6, 2,  50, 20, false),
  ( 7, 2,  60, 30, false),
  ( 8, 2,  70, 40, true ),
  ( 9, 2,  90, 50, true ),
  (10, 2, 100, 60, false),
  -- C2. FG4-100 Rev B (Enhanced Load Verification)
  (11, 3,  50, 10, true ),
  (12, 3,  40, 20, true ),
  (13, 3,  60, 30, true ),
  (14, 3,  70, 40, true ),
  (15, 3,  80, 50, true ),
  (16, 3,  90, 60, true ),
  (17, 3, 100, 70, false),
  -- C3. FG4-110 Rev A
  (18, 4,  30, 10, false),
  (19, 4,  50, 20, false),
  (20, 4,  40, 30, true ),
  (21, 4,  60, 40, true ),
  (22, 4,  70, 50, true ),
  (23, 4,  90, 60, true ),
  (24, 4, 100, 70, false);

-- ---------------------------------------------------------------------
-- Sales orders (section D)
-- ---------------------------------------------------------------------
insert into sales_order (sales_order_id, customer_name, order_date, order_status) values
  (4101, 'Pacific Pipeline Systems',   '2026-11-02', 'Open'),   -- SO4-101
  (4102, 'Western Industrial Piping',  '2026-11-03', 'Open'),   -- SO4-102
  (4103, 'Sierra Mechanical Services', '2026-11-04', 'Open');   -- SO4-103

insert into sales_order_line (sales_order_line_id, sales_order_id, item_id, quantity_ordered) values
  (1, 4101, 1, 10),   -- SO4-101 FG4-100
  (2, 4101, 2,  6),   -- SO4-101 FG4-110
  (3, 4102, 1,  8),   -- SO4-102 FG4-100
  (4, 4102, 2,  5),   -- SO4-102 FG4-110
  (5, 4103, 1,  7);   -- SO4-103 FG4-100

-- ---------------------------------------------------------------------
-- Production orders (section E)
-- quantity_planned = quantity ordered - available stock allocated
-- ---------------------------------------------------------------------
insert into production_order (production_order_id, routing_id, quantity_planned, release_date, order_status) values
  (4201, 2, 7, '2026-11-06', 'Planned'),   -- PO4-201 FG4-100 Rev A : 10 - 3
  (4202, 4, 4, '2026-11-06', 'Planned'),   -- PO4-202 FG4-110 Rev A :  6 - 2
  (4203, 3, 8, '2026-11-06', 'Planned'),   -- PO4-203 FG4-100 Rev B :  8 - 0
  (4204, 4, 4, '2026-11-06', 'Planned'),   -- PO4-204 FG4-110 Rev A :  5 - 1
  (4205, 2, 5, '2026-11-06', 'Planned');   -- PO4-205 FG4-100 Rev A :  7 - 2

-- Links each production order to the customer demand that caused it
insert into production_allocation (production_allocation_id, sales_order_line_id, production_order_id, allocated_quantity) values
  (1, 1, 4201, 7),
  (2, 2, 4202, 4),
  (3, 3, 4203, 8),
  (4, 4, 4204, 4),
  (5, 5, 4205, 5);

-- ---------------------------------------------------------------------
-- Move auto-numbering past the IDs used above so future inserts work
-- ---------------------------------------------------------------------
select setval(pg_get_serial_sequence('ppm.item_type',             'item_type_id'),             (select max(item_type_id)             from item_type));
select setval(pg_get_serial_sequence('ppm.item',                  'item_id'),                  (select max(item_id)                  from item));
select setval(pg_get_serial_sequence('ppm.bom_component',         'bom_component_id'),         (select max(bom_component_id)         from bom_component));
select setval(pg_get_serial_sequence('ppm.operation',             'operation_id'),             (select max(operation_id)             from operation));
select setval(pg_get_serial_sequence('ppm.routing',               'routing_id'),               (select max(routing_id)               from routing));
select setval(pg_get_serial_sequence('ppm.routing_step',          'routing_step_id'),          (select max(routing_step_id)          from routing_step));
select setval(pg_get_serial_sequence('ppm.sales_order',           'sales_order_id'),           (select max(sales_order_id)           from sales_order));
select setval(pg_get_serial_sequence('ppm.sales_order_line',      'sales_order_line_id'),      (select max(sales_order_line_id)      from sales_order_line));
select setval(pg_get_serial_sequence('ppm.production_order',      'production_order_id'),      (select max(production_order_id)      from production_order));
select setval(pg_get_serial_sequence('ppm.production_allocation', 'production_allocation_id'), (select max(production_allocation_id) from production_allocation));

commit;
