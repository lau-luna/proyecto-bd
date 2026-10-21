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

end;
$$
