/* CONFIGURADOR INCIAL BASE DATOS CONSUKA */
/* Software Consultoria Aeronautica */

/* ################ CREACION BASE DE DATOS ################### */

DROP DATABASE IF EXISTS barba;
CREATE DATABASE barba;
USE barba;

/* ################ CREACION TABLAS CARACTERISTICAS ################### */

CREATE TABLE IF NOT EXISTS NACIONALIDAD (ncID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,NACION VARCHAR(100),MONEDA VARCHAR(100),RELATIVA_DOLLAR DOUBLE);
CREATE TABLE IF NOT EXISTS FABRICANTE (fbID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,NOMBRE_COMERCIAL VARCHAR(100),NACIONALIDAD INT NOT NULL,DIRECCION VARCHAR(200),TELEFONO VARCHAR(100),CONTACTO_A VARCHAR(100),TELEFONO_A VARCHAR(100),EMAIL_A VARCHAR(100),CONTACTO_B VARCHAR(100),TELEFONO_B VARCHAR(100),EMAIL_B VARCHAR(100),
       	     	    	  CONSTRAINT `NACIONALIDAD`
					FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;
							      
CREATE TABLE IF NOT EXISTS FABRICANTE_MOTOR (fbmID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,NOMBRE_COMERCIAL VARCHAR(100),NACIONALIDAD INT NOT NULL,DIRECCION VARCHAR(200),TELEFONO VARCHAR(100),CONTACTO_A VARCHAR(100),TELEFONO_A VARCHAR(100),EMAIL_A VARCHAR(100),CONTACTO_B VARCHAR(100),TELEFONO_B VARCHAR(100),EMAIL_B VARCHAR(100),
       	     	    	  CONSTRAINT `NACIONALIDAD_motor`
					FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;
							      
CREATE TABLE IF NOT EXISTS MODELO (moID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,FABRICANTE INT NOT NULL,MODELO VARCHAR(100),UNIQUE index_MODELO (FABRICANTE,MODELO),
       	     	    	  CONSTRAINT `FABRICANTE`
					FOREIGN KEY (FABRICANTE) REFERENCES FABRICANTE (fbID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS MODELO_MOTOR (momID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,FABRICANTE_MOTOR INT NOT NULL,MODELO VARCHAR(100),UNIQUE index_MODELO (FABRICANTE_MOTOR,MODELO),
       	     	    	  CONSTRAINT `FABRICANTE_MOTOR`
					FOREIGN KEY (FABRICANTE_MOTOR) REFERENCES FABRICANTE_MOTOR (fbmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS VENDEDOR (vdID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,NOMBRE_COMERCIAL VARCHAR(100),NACIONALIDAD INT NOT NULL,DIRECCION VARCHAR(200),TELEFONO VARCHAR(100),CONTACTO_A VARCHAR(100),TELEFONO_A VARCHAR(100),EMAIL_A VARCHAR(100),CONTACTO_B VARCHAR(100),TELEFONO_B VARCHAR(100),EMAIL_B VARCHAR(100),
       	     	    	  CONSTRAINT `NACIONALIDAD_VENTA`
					FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS AERONAVE (aeID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,MODELO INT NOT NULL,MODELO_MOTOR INT NOT NULL,VENDEDOR INT NOT NULL,ANO INT NOT NULL,HS_ACUMULADAS DOUBLE,FECHA DATE,UNIQUE index_MODELO (MODELO,MODELO_MOTOR,VENDEDOR,ANO,HS_ACUMULADAS),
       	     	    	  CONSTRAINT `MODELO`
					FOREIGN KEY (MODELO) REFERENCES MODELO (moID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
       	     	    	  CONSTRAINT `MODELO_MOTOR`
					FOREIGN KEY (MODELO_MOTOR) REFERENCES MODELO_MOTOR (momID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,							       	     	    	  CONSTRAINT `VENDEDOR`
					FOREIGN KEY (VENDEDOR) REFERENCES VENDEDOR (vdID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS BANCO (bcID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,DENOMINACION VARCHAR(100),NACIONALIDAD INT NOT NULL,UNIQUE index_BANCO (DENOMINACION,NACIONALIDAD),
       	     	    	  CONSTRAINT `NACIONALIDAD_BANCARIA`
					FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS FINANCIACION (fcID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,TIPO VARCHAR(100),UNIQUE index_FINAN (TIPO));


CREATE TABLE IF NOT EXISTS PRECIO_AERONAVE (paeID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,AERONAVE INT NOT NULL,FINANCIACION INT NOT NULL,BANCO INT NOT NULL,MONTO_INICIAL DOUBLE,MONTO_FINANCIADO DOUBLE,INTERES_ANUAL DOUBLE,FECHA DATE,UNIQUE index_PRECIO (AERONAVE,FINANCIACION,BANCO,MONTO_INICIAL,MONTO_FINANCIADO,INTERES_ANUAL,FECHA),
       	     	    	  CONSTRAINT `AERONAVE`
					FOREIGN KEY (AERONAVE) REFERENCES AERONAVE (aeID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
       	     	    	  CONSTRAINT `FINANCIACION`
					FOREIGN KEY (FINANCIACION) REFERENCES FINANCIACION (fcID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,							       	     	    	  CONSTRAINT `BANCO`
					FOREIGN KEY (BANCO) REFERENCES BANCO (bcID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS DATO_DINAMICO (tddID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,TIPO VARCHAR(100),UNIDADES VARCHAR(100),UNIQUE index_TIPODIN (TIPO,UNIDADES));

CREATE TABLE IF NOT EXISTS DINAMICOS (ddID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,DATO_DINAMICO INT NOT NULL,MODELO INT NOT NULL,MAGNITUD DOUBLE,FECHA DATE,UNIQUE index_DDINAMICO (DATO_DINAMICO,MODELO,MAGNITUD,FECHA),
       	     	    	  CONSTRAINT `TIPO`
					FOREIGN KEY (DATO_DINAMICO) REFERENCES DATO_DINAMICO (tddID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
       	     	    	  CONSTRAINT `MODELO_DINAMICO`
					FOREIGN KEY (MODELO) REFERENCES MODELO (moID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS DATO_DINAMICO_MOTOR (tddID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,TIPO VARCHAR(100),UNIDADES VARCHAR(100),UNIQUE index_TIPODIN (TIPO,UNIDADES));

CREATE TABLE IF NOT EXISTS DINAMICOS_MOTOR (ddID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,DATO_DINAMICO_MOTOR INT NOT NULL,MODELO_MOTOR INT NOT NULL,MAGNITUD DOUBLE,FECHA DATE,UNIQUE index_DDINAMICO (DATO_DINAMICO_MOTOR,MODELO_MOTOR,MAGNITUD,FECHA),
       	     	    	  CONSTRAINT `TIPO_MOT`
					FOREIGN KEY (DATO_DINAMICO_MOTOR) REFERENCES DATO_DINAMICO_MOTOR (tddID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
       	     	    	  CONSTRAINT `MODELO_DINAMICO_MOT`
					FOREIGN KEY (MODELO_MOTOR) REFERENCES MODELO_MOTOR (momID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS PROVEEDOR (pvID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,NOMBRE_COMERCIAL VARCHAR(100),NACIONALIDAD INT NOT NULL,DIRECCION VARCHAR(200),TELEFONO VARCHAR(100),CONTACTO_A VARCHAR(100),TELEFONO_A VARCHAR(100),EMAIL_A VARCHAR(100),CONTACTO_B VARCHAR(100),TELEFONO_B VARCHAR(100),EMAIL_B VARCHAR(100),
       	     	    	  CONSTRAINT `NACIONALIDAD_PROVEE`
					FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS MANTENIMIENTO (mtID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,MODELO INT NOT NULL,DESCRIPCION VARCHAR(100),HS_ACUMULADAS DOUBLE,TIEMPO_TRANSCURRIDO DOUBLE,DURACION DOUBLE,RECURSIVO INT NOT NULL,UNIQUE index_MANT (MODELO,DESCRIPCION,HS_ACUMULADAS,TIEMPO_TRANSCURRIDO,DURACION,RECURSIVO),
       	     	    	  CONSTRAINT `MODELO_MNT`
					FOREIGN KEY (MODELO) REFERENCES MODELO (moID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS COSTO_MANTENIMIENTO (cmtID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,PROVEEDOR INT NOT NULL,MANTENIMIENTO INT NOT NULL,MONTO DOUBLE,FECHA DATE,UNIQUE index_COST_MANT (PROVEEDOR,MANTENIMIENTO,MONTO,FECHA),
       	     	    	  CONSTRAINT `PROVEEDOR_MNT`
					FOREIGN KEY (PROVEEDOR) REFERENCES PROVEEDOR (pvID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
       	     	    	  CONSTRAINT `TRABAJO_MNT`
					FOREIGN KEY (MANTENIMIENTO) REFERENCES MANTENIMIENTO (mtID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS PROVEEDOR_MOTOR (pvmID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,NOMBRE_COMERCIAL VARCHAR(100),NACIONALIDAD INT NOT NULL,DIRECCION VARCHAR(200),TELEFONO VARCHAR(100),CONTACTO_A VARCHAR(100),TELEFONO_A VARCHAR(100),EMAIL_A VARCHAR(100),CONTACTO_B VARCHAR(100),TELEFONO_B VARCHAR(100),EMAIL_B VARCHAR(100),
       	     	    	  CONSTRAINT `NACIONALIDAD_PROVEE_M`
					FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT					     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS MANTENIMIENTO_MOTOR (mtmID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,MODELO_MOTOR INT NOT NULL,DESCRIPCION VARCHAR(100),HS_ACUMULADAS DOUBLE,TIEMPO_TRANSCURRIDO DOUBLE,DURACION DOUBLE,RECURSIVO INT NOT NULL,UNIQUE index_MANT (MODELO_MOTOR,DESCRIPCION,HS_ACUMULADAS,TIEMPO_TRANSCURRIDO,DURACION,RECURSIVO),
       	     	    	  CONSTRAINT `MODELO_MNT_M`
					FOREIGN KEY (MODELO_MOTOR) REFERENCES MODELO_MOTOR (momID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS COSTO_MANTENIMIENTO_MOTOR (cmtmID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,PROVEEDOR_MOTOR INT NOT NULL,MANTENIMIENTO_MOTOR INT NOT NULL,MONTO DOUBLE,FECHA DATE,UNIQUE index_COST_MANT (PROVEEDOR_MOTOR,MANTENIMIENTO_MOTOR,MONTO,FECHA),
       	     	    	  CONSTRAINT `PROVEEDOR_MNT_M`
					FOREIGN KEY (PROVEEDOR_MOTOR) REFERENCES PROVEEDOR_MOTOR (pvmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
       	     	    	  CONSTRAINT `TRABAJO_MNT_M`
					FOREIGN KEY (MANTENIMIENTO_MOTOR) REFERENCES MANTENIMIENTO_MOTOR (mtmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT      
							      
							      ) ENGINE = InnoDB;

/* ################ CREACION TABLAS FUNCIONAMIENTO INTERNO ################### */

CREATE TABLE IF NOT EXISTS SCRIPTS (scID INT NOT NULL PRIMARY KEY,tipo_sc VARCHAR(50),nota_sc DOUBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS UBICACIONES (ubID INT NOT NULL PRIMARY KEY,ubicacion_ub VARCHAR(50),nota_ub DOUBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS NOMBRE_MENU (nmID INT NOT NULL PRIMARY KEY,nombre_nm VARCHAR(100),nota_nm DOUBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS MENU (mID INT NOT NULL PRIMARY KEY,nombre_m INT NOT NULL,ubicacion_m INT NOT NULL,proxubi_m INT NOT NULL,cont_m INT NOT NULL,para1_m INT,para2_m INT,para3_m INT,para4_m VARCHAR(60),para5_m VARCHAR(60),para6_m VARCHAR(60),para7_m VARCHAR(60),			  CONSTRAINT `PROXIMA_UBICACION`
					FOREIGN KEY (proxubi_m) REFERENCES UBICACIONES (ubID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
			  CONSTRAINT `CONTIENE_SCRIPT`
					FOREIGN KEY (cont_m) REFERENCES SCRIPTS (scID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
			  CONSTRAINT `NOMBRE_MENU`
					FOREIGN KEY (nombre_m) REFERENCES NOMBRE_MENU (nmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
			  CONSTRAINT `UBICACION_MENU`
					FOREIGN KEY (ubicacion_m) REFERENCES UBICACIONES (ubID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
			  CONSTRAINT `FONDO`
					FOREIGN KEY (para1_m) REFERENCES NOMBRE_MENU (nmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
			  CONSTRAINT `TITULO`
					FOREIGN KEY (para2_m) REFERENCES NOMBRE_MENU (nmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT,
			  CONSTRAINT `SUB-TITULO`
					FOREIGN KEY (para3_m) REFERENCES NOMBRE_MENU (nmID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT							     
							      
							      ) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS RECURSOS_HUMANOS (rhID INT NOT NULL PRIMARY KEY,rh_rh VARCHAR(30) NOT NULL,notas_nc DOUBLE);

CREATE TABLE IF NOT EXISTS RECURSOS_HUMANOS_DISPONIBLES (rhdID INT NOT NULL PRIMARY KEY,nombre_rhd VARCHAR(50),tipo_rhd INT NOT NULL,USUARIO VARCHAR(50),ACCESO VARCHAR(100),NIVEL INT,notas_cd DOUBLE,
			  CONSTRAINT `TIPO DE RECURSO`
					FOREIGN KEY (tipo_rhd) REFERENCES RECURSOS_HUMANOS (rhID)
						    ON DELETE CASCADE
						       	      ON UPDATE RESTRICT							     
							      
							      ) ENGINE = InnoDB;


/* ################ CARGA DE DATOS INICIALES ################### */

INSERT INTO RECURSOS_HUMANOS VALUES ('1','ADMINISTRADOR','0'),('2','CONTABLE','0'),('3','CADETE','0');  

INSERT INTO SCRIPTS VALUES ('1','clasico.sh','0'),('2','carga_estandar.sh','0'); 

INSERT INTO UBICACIONES VALUES ('1','PPAL','0'),('2','CDAT','0'),('3','AER','0'),('4','AERC','0'),('5','AERM','0'),('6','AERD','0');

INSERT INTO UBICACIONES VALUES ('7','MOT','0'),('8','MOTC','0'),('9','MOTM','0'),('10','MOTD','0'),('11','COP','0');

INSERT INTO NOMBRE_MENU VALUES ('1','CARGA DE DATOS','0'),('2','AERONAVES','0'),('3','PLANTAS DE PODER','0'),('4','COSTOS y PRECIOS','0'),('5','CARACTERIZACION','0'),('6','DATOS DE MANTENIMIENTO','0'),('7','DATOS VARIABLES','0'),('8','DIRECTIVAS MANTENIMIENTO','0'),('9','NUEVO MODELO','0'),('10','NUEVO EJEMPLAR','0'),('11','GENERALES','0'),('12','PRECIO VIGENTE AERONAVE','0'),('13','COSTO VIGENTE MANTENIMIENTO AERONAVE','0'),('14','COSTO VIGENTE MANTENIMIENTO MOTOR','0'),('15','CONSUKA v1.0  Consultoria Aeronautica ','0'),('16','MENU PRINCIPAL','0'),('17','SELECCIONE UNA OPCION','0');

INSERT INTO MENU VALUES (1,1,1,2,1,15,1,17,1,1,1,3),(2,2,2,3,1,1,2,17,1,1,1,3),(3,5,3,4,1,1,5,17,1,1,1,3),(4,6,3,5,1,6,17,1,1,1,1,3),(5,7,3,6,1,7,17,1,1,1,1,3);
