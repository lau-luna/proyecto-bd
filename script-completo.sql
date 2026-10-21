do $$
begin 
drop schema if exists proyecto cascade;
create schema proyecto ;
set search_path to proyecto;

create table zapato (
	modelo varchar(30),
	color varchar(30),
	precio float not null,
	constraint pkzapato primary key(modelo , color),
	constraint checkprecio check(precio >0 and precio < 200000));
	
create table talle (numero float primary key);

create table proveedor (
	cuit int8  primary key,
	razon_social  varchar(100) not null constraint ccrazon_social unique,
	direccion varchar(100) not  null,
	tel_fijo varchar(15));
	
create table Mcelulares (
	cuit int8,
	celulares varchar(15),
 	constraint pkcelulares primary key (cuit, celulares),
 	constraint fkproveedor foreign key (cuit) references proveedor);

create table persona(
	dni integer primary key,
	nombre varchar (20) not null,
	apellido varchar(20) not null,
	direccion varchar(100)
);

create table vendedor(
	dni integer not null references persona(dni) primary key,
	numero integer not null constraint ccnumero_vendedor unique
	
);

create table cliente(
	dni integer not null references persona(dni) primary key 
);

create table minorista(
	dni integer not null references cliente(dni) primary key,
	fecha_nacimiento date not null
);

create table mayorista(
	dni integer not null references cliente(dni) primary key,
	descuento float not null
);
	 
create table venta(
	numero_factura integer primary key,
	fecha date not null,
	dni_cliente integer not null references cliente (dni),
	descuento_venta float constraint checkdescuento check(descuento_venta >= 0 and descuento_venta<=100),
	dni_vendedor integer not null references vendedor (dni),
	monto float not null 
);

create table franco(
	 numero integer primary key,
	 fecha date not null,
	 observacion varchar(100),
	 dni integer not null references vendedor(dni)
);

create table dia(
	nombre varchar(10) primary key
);

create table provee(
	cuit int8 not null references proveedor(cuit),
	modelo varchar (30) not null,
	color varchar (30)not null,
	constraint fkprovee foreign key(modelo, color) references zapato
);

create table tiene (
	modelo varchar (30) not null,
	color varchar (30)not null,
	constraint fkprovee foreign key(modelo, color) references zapato,
	numero float not null references talle(numero),
	cantidad integer not null,
	constraint pktiene primary key(modelo, color, numero)
);

create table horario(
	dni_vendedor integer references vendedor(dni),
	nombre varchar(10) references dia(nombre),
	hora_salida time not null,
	hora_entrada time not null,
	constraint pkhorario primary key (dni_vendedor, nombre)
);

create table vendio(
	modelo varchar(30) not null,
	color varchar(30) not null,
	numero float not null references talle(numero),
	numero_factura integer not null,
	cantidad integer not null,
	precio_venta float not null,
	constraint fkvendio foreign key (modelo, color, numero) references tiene,
	constraint pkvendio primary key (modelo, color, numero, numero_factura)
);

create table auditoria(
    fecha date not null,
    precio_anterior float not null,
    precio_nuevo float not null,
    modelo varchar(30),
    color varchar(30),
    usuario varchar(100)
  );


  create function auditar_actualizacion_precio() returns trigger as $fn$
  begin
  	if old.precio = new.precio then
  		return new;
  	end if;
  	
    insert into proyecto.auditoria (fecha, precio_anterior, precio_nuevo, modelo, color, usuario)
    values (now(), old.precio, new.precio, old.modelo, old.color, current_user);
    
    return new;
  end;
  $fn$ language plpgsql;
  

  create trigger auditoria_precio_zapato
    after update of precio on zapato
    for each row
    execute function auditar_actualizacion_precio();


insert into zapato(modelo,color,precio) values
	('adidas','negro',40000),
	('adidas','verde',60000),
	('nike','blanco',100000),
	('nike','azul',80800),
	('topper','negro',35000),
	('vans','negro', 165000)
	;

insert into talle(numero) values
	(35),
	(36),
	(37),
	(38),
	(39),
	(40),
	(41),
	(42),
	(43),
	(44)
	;

insert into persona(dni, nombre, apellido, direccion) values 
	(25345678, 'Juan', 'Perez', 'Calle Falsa 123'),
	(31567890, 'Maria', 'Gomez', 'Av Siempreviva 742'),
	(42111222, 'Carlos', 'Lopez', 'San Martin 456'),
	(20999888, 'Ana', 'Martinez', 'Belgrano 789'),
	(35444333, 'Luis', 'Fernandez', 'Sarmiento 101'),
	(30123456, 'Roberto', 'Sanchez', 'Rivadavia 202'),
	(28555444, 'Elena', 'Diaz', 'Mitre 303'),
	(32777888, 'Martin', 'Romero', 'Paz 404')
	;

insert into cliente(dni) values
	(25345678),
	(31567890),
	(42111222),
	(20999888),
	(35444333)
	;

insert into vendedor(dni, numero) values
	(30123456, 101),
	(28555444, 102),
	(32777888, 103)
	;

insert into venta (numero_factura, fecha, dni_cliente, descuento_venta, dni_vendedor, monto) values
	(1001, '2026-10-15', 25345678, 10.0, 30123456, 15400.50),
	(1002, '2026-10-16', 31567890, 0.0, 28555444, 8900.00),
	(1003, '2026-10-16', 42111222, 15.5, 30123456, 25000.75),
	(1004, '2026-10-17', 20999888, 5.0, 32777888, 4320.20),
	(1005, '2026-10-18', 35444333, 20.0, 28555444, 56700.00)
;

insert into minorista(dni, fecha_nacimiento) values
	(25345678, '1995-05-14'),
	(31567890, '1988-11-22'),
	(42111222, '2001-02-10')
	;


insert into mayorista(dni, descuento) values
	(20999888, 15.0),
	(35444333, 25.5)
	;

insert into proveedor(cuit, razon_social, direccion, tel_fijo) values
	(30111111112, 'Adidas Deportes SRL', 'Av. del Libertador 1000', '011-44445555'),
	(30222222224, 'Nike Argentina SA', 'Calle Corrientes 200', '011-55556666'),
	(30333333336, 'Distribuidora Calzados', 'Ruta 9 Km 50', '0351-4443333');

insert into Mcelulares(cuit, celulares) values
	(30111111112, '1155556666'),
	(30222222224, '1166667777');


insert into dia(nombre) values
	('Lunes'), ('Martes'), ('Miercoles'), ('Jueves'), ('Viernes'), ('Sabado');


insert into provee(cuit, modelo, color) values
	(30111111112, 'adidas', 'negro'),
	(30111111112, 'adidas', 'verde'),
	(30222222224, 'nike', 'blanco'),
	(30222222224, 'nike', 'azul'),
	(30333333336, 'topper', 'negro'),
	(30333333336, 'vans', 'negro');


insert into tiene(modelo, color, numero, cantidad) values
	('adidas', 'negro', 39, 10),
	('adidas', 'negro', 40, 15),
	('nike', 'blanco', 41, 5),
	('nike', 'blanco', 42, 8),
	('vans', 'negro', 38, 12),
	('topper', 'negro', 35, 20);


insert into horario(dni_vendedor, nombre, hora_salida, hora_entrada) values
	(30123456, 'Lunes', '17:00', '09:00'),
	(30123456, 'Martes', '17:00', '09:00'),
	(28555444, 'Miercoles', '18:00', '10:00'),
	(32777888, 'Jueves', '14:00', '08:00');


insert into franco(numero, fecha, observacion, dni) values
	(1, '2026-10-20', 'Trámites personales', 30123456),
	(2, '2026-10-21', 'Examen facultad', 28555444);


insert into vendio(modelo, color, numero, numero_factura, cantidad, precio_venta) values
	('adidas', 'negro', 40, 1001, 1, 40000),
	('nike', 'blanco', 41, 1002, 1, 100000),
	('vans', 'negro', 38, 1003, 1, 165000),
	('topper', 'negro', 35, 1004, 2, 35000),
	('adidas', 'negro', 39, 1005, 1, 40000);

end 
$$
