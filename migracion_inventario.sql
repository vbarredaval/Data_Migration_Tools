/*
 script de migración: inventario legacy -> nuevo sistema
 victor barreda
*/

-- 1. estructura destino (schema limpio)
create table if not exists productos_moderno (
    id_producto serial primary key,
    sku varchar(20) unique not null,
    nombre varchar(100),
    stock_actual int default 0,
    ultimo_conteo timestamp default current_timestamp
);

-- 2. staging area (carga de datos sucios)
-- simulación de data cruda del sistema viejo
create temporary table raw_data_legacy (
    codigo_sucio varchar(50),
    descripcion_mix varchar(200),
    fecha_ingreso varchar(20)
);

insert into raw_data_legacy values 
('LPT-001 ', 'Laptop Gamer HP | 10', '2023/01/01'),
('MON-002', 'Monitor LG 24in | 5', '2023-05-15'),
('MS-003  ', 'Mouse Logi | 100', '2023-08-20');

-- 3. ejecución del etl
begin;
    insert into productos_moderno (sku, nombre, stock_actual, ultimo_conteo)
    select 
        -- normalizo sku quitando espacios
        trim(split_part(codigo_sucio, ' ', 1)),
        
        -- separo nombre del producto
        trim(split_part(descripcion_mix, '|', 1)),
        
        -- extraigo stock y convierto a entero
        cast(trim(split_part(descripcion_mix, '|', 2)) as integer),
        
        -- parseo de fecha
        to_date(fecha_ingreso, 'YYYY/MM/DD')
    from raw_data_legacy
    where codigo_sucio is not null;
commit;

-- validación de carga
-- select * from productos_moderno;
