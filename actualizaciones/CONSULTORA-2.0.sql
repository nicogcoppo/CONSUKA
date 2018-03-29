/* CONSUKA ACTUALIZACION 1 */
/* Software Consultoria Aeronautica */

USE CONSULTORIA_AERONAUTICA;

/*############################## ACTUALIZACIONES #####################*/

ALTER TABLE DATO_ESTUDIO DROP INDEX index_D_ESTUDIO, ADD UNIQUE KEY DATO_ESTUDIO_D2 (ESTUDIO,TIPO_DATO_ESTUDIO,MAGNITUD,MODELO,FECHA);


/*############################## PARTE B #############################*/

ALTER TABLE DATO_ESTUDIO CHANGE FECHA REGISTRO DATETIME;

/*############################## PARTE C #############################*/

ALTER TABLE RELEVANCIA_DATOS CHANGE FECHA REGISTRO DATETIME;

INSERT INTO SCRIPTS VALUES ('3','aeronaves_vigentes.sh','0'),('4','esquema_estudio_ahp.sh','0'),('5','estudio_AHP.sh','0'),('6','vista_relacion_ahp.sh','0'); 

INSERT INTO UBICACIONES VALUES ('15','VIDAT','0'),('16','ESTD','0'),('17','ESTDAHP','0');

INSERT INTO NOMBRE_MENU VALUES ('37','VISUALIZACION DATOS','0'),('38','MODELOS DE AERONAVES','0'),('39','ESTUDIOS','0'),('40','Proceso Analitico Jerarquico (AHP)','0'),('41','MODELOS DATEADOS','0'),('42','RELACION ENTRE VARIABLES','0'),('43','CALCULAR','0');

INSERT INTO MENU VALUES (41,37,1,15,1,15,37,17,'UNIDADES',1,1,3),(42,38,15,1,3,15,37,38,'UNIDADES',1,1,3),(43,39,1,16,1,15,39,17,'UNIDADES',1,1,3),(44,40,16,17,1,15,39,40,'UNIDADES',1,1,3),(45,41,17,1,4,15,39,40,'UNIDADES',1,1,3),(46,42,17,1,6,15,39,40,'UNIDADES',1,1,3),(47,43,17,1,5,15,39,40,'UNIDADES',1,1,3);

/*############################ PARTE D #########################*/

CREATE TABLE IF NOT EXISTS TIPO_OPERACION (topID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,TIPO VARCHAR(100), UNIQUE KEY OPERACION_TIPO (TIPO));

INSERT INTO TIPO_OPERACION VALUES (1,'GENERAL'),(2,'TRANSPORTE');

CREATE TABLE TALLERES_ANAC (
  talID int(11) NOT NULL AUTO_INCREMENT,
  TALLER varchar(100) DEFAULT NULL,
  RAZON_SOCIAL varchar(100) DEFAULT NULL,
  UBICACION varchar(100) DEFAULT NULL,
  DIRECCION varchar(100) DEFAULT NULL,
  NACIONALIDAD int(11) NOT NULL,
  OPERACION int(11) NOT NULL,
  ESPECIFICACION_OPERACION varchar(5000) DEFAULT NULL,
  NOTAS varchar(2000) DEFAULT NULL,
  TELEFONO varchar(100) DEFAULT NULL,
  CONTACTO_A varchar(100) DEFAULT NULL,
  TELEFONO_A varchar(100) DEFAULT NULL,
  EMAIL_A varchar(100) DEFAULT NULL,
  CONTACTO_B varchar(100) DEFAULT NULL,
  TELEFONO_B varchar(100) DEFAULT NULL,
  EMAIL_B varchar(100) DEFAULT NULL,
  PRIMARY KEY (talID),
  UNIQUE KEY taller_anac (TALLER,RAZON_SOCIAL),
  CONSTRAINT NACIONALIDAD_taller FOREIGN KEY (NACIONALIDAD) REFERENCES NACIONALIDAD (ncID) ON DELETE CASCADE,
  CONSTRAINT operacion_taller FOREIGN KEY (OPERACION) REFERENCES TIPO_OPERACION (topID) ON DELETE CASCADE
) ENGINE=InnoDB;
