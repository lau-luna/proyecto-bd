set search_path to proyecto;
-- consulta 6a: Devolver el Nº más vendido por c/modelo de zapatos.
SELECT v.modelo, v.numero
FROM proyecto.vendio v
GROUP BY v.modelo, v.numero
HAVING SUM(v.cantidad) >= ALL (
    SELECT SUM(v2.cantidad)
    FROM proyecto.vendio v2
    WHERE v2.modelo = v.modelo
    GROUP BY v2.numero
);

-- consulta 6b: Listado de vendedores con sus ventas totales(monto total) durante 2025.
-- corregida
select vd.dni, sum(vt.monto) as monto_total
from venta vt
inner join vendedor vd on vt.dni_vendedor = vd.dni
where extract (year from vt.fecha) = 2025
group by vd.dni;

-- consulta 6c: Apellido y Nombre de los vendedores que no han tenido francos en enero de 2026.
SELECT p.apellido, p.nombre
FROM proyecto.vendedor v
NATURAL JOIN proyecto.persona p
WHERE NOT EXISTS (
    SELECT 1
    FROM proyecto.franco f
    WHERE f.dni = v.dni
      AND f.fecha >= '2026-01-01'
      AND f.fecha < '2026-02-01'
)
ORDER BY v.dni;

-- ACTIVIDAD D) consultas propias
set search_path to proyecto;

-- Consulta d1: cantidad total vendida por cada color de mayor a menor
select color, sum(cantidad) as cantidad_total_vendida
from vendio
group by color
order by cantidad_total_vendida desc;

-- d2: Modelo, calor y precio de los zapatos el cual su precio es mayor al promedio de precio de todos los zapatos
select modelo, color, precio
from proyecto.zapato
where precio > (
  select avg(precio)
  from proyecto.zapato
);

--d3: Nombre, apellido y la suma total gastada por cliente
select per.nombre, per.apellido, sum(v.monto) as total_gastado
from proyecto.venta v
inner join proyecto.persona per on v.dni_cliente = per.dni
group by per.dni, per.nombre, per.apellido;
