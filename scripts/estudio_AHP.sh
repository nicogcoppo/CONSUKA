#!/bin/bash
#
# Script para el calculo automatizado de AHP (Saaty)
#

temp=temporales/116/

rm temporales/116/*

############## DECLARACIONES ###########################

declare -r SCI_SCRIPT=""${temp}"/"${RANDOM}".sci"

declare -r SCI_SALIDA=""${RANDOM}"-SALIDA.sci"

################# FUNCIONES ############################

user=ivo
pass=macaco12
DB=CONSULTORIA_AERONAUTICA

###############  SCRIPT ###########################

## Armado de script de SCILAB
# Se define la matriz principal de relaciones entre Tipos de dato

echo 'function j=criterioAlonso(x);j=x+0.1*(1.7699*x-4.3513);endfunction' >${SCI_SCRIPT}

echo "M=([])" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('M(',t1.TIPO_DATO_ESTUDIO,',',t1.RELATIVO,')=',t1.MAGNITUD) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.FECHA < t2.FECHA) WHERE t2.FECHA IS NULL;" | tail -n +2 >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('M(',t1.RELATIVO,',',t1.TIPO_DATO_ESTUDIO,')=',1 / t1.MAGNITUD) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.FECHA < t2.FECHA) WHERE t2.FECHA IS NULL;" | tail -n +2  >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente

echo "M(M==0)=1" >>${SCI_SCRIPT}

## Saco Autovalores y Autovectores

echo "[R,data]=spec(M)" >>${SCI_SCRIPT}

echo "[landaPrioridad,j]=max(real(data))" >>${SCI_SCRIPT}

echo "autoVectorPrioridad=R(:,j(2))/norm(R(:,j(2)))" >>${SCI_SCRIPT}

echo "n=size(M,1)" >>${SCI_SCRIPT}

echo 'if criterioAlonso(n) > landaPrioridad then disp("Verifica consistencia"); else disp("NO VERIFICA"); end' >>${SCI_SCRIPT}


#Se definen las matrices para cada uno de los elementos de interes

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DISTINCT(TIPO) FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO);" | tail -n +2 | sed 's/$/=([])/' >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(TIPO,'(',t1.MODELO,',',t3.MODELO,')=',t1.MAGNITUD / t3.MAGNITUD) FROM DATO_ESTUDIO t1 LEFT JOIN DATO_ESTUDIO t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.MODELO = t2.MODELO AND t1.FECHA < t2.FECHA) LEFT JOIN DATO_ESTUDIO t3 ON (t1.TIPO_DATO_ESTUDIO = t3.TIPO_DATO_ESTUDIO AND t1.MODELO < t3.MODELO) JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=t1.TIPO_DATO_ESTUDIO) LEFT JOIN DATO_ESTUDIO t4 ON (t3.TIPO_DATO_ESTUDIO = t4.TIPO_DATO_ESTUDIO AND t3.MODELO = t4.MODELO AND t3.FECHA < t4.FECHA) WHERE t2.FECHA IS NULL AND t4.FECHA IS NULL AND t1.ESTUDIO=1 ORDER BY t1.TIPO_DATO_ESTUDIO,t1.MODELO;" | tail -n +2 | grep -v "NULL" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(TIPO,'(',t3.MODELO,',',t1.MODELO,')=',t3.MAGNITUD / t1.MAGNITUD) FROM DATO_ESTUDIO t1 LEFT JOIN DATO_ESTUDIO t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.MODELO = t2.MODELO AND t1.FECHA < t2.FECHA) LEFT JOIN DATO_ESTUDIO t3 ON (t1.TIPO_DATO_ESTUDIO = t3.TIPO_DATO_ESTUDIO AND t1.MODELO < t3.MODELO) JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=t1.TIPO_DATO_ESTUDIO) LEFT JOIN DATO_ESTUDIO t4 ON (t3.TIPO_DATO_ESTUDIO = t4.TIPO_DATO_ESTUDIO AND t3.MODELO = t4.MODELO AND t3.FECHA < t4.FECHA) WHERE t2.FECHA IS NULL AND t4.FECHA IS NULL AND t1.ESTUDIO=1 ORDER BY t1.TIPO_DATO_ESTUDIO,t1.MODELO;" | tail -n +2 | grep -v "NULL" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(TIPO,'(',TIPO,'==0)=1') FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT '[R,data]=spec(',TIPO,');','[landa',TIPO,',j]=max(real(data));','autoVector',TIPO,'=R(:,j(2))/norm(R(:,j(2)));n=size(',TIPO,',1);if!criterioAlonso(n)!>!landa',TIPO,'!then!disp(''Verifica!consistencia'');!else!disp(''NO!VERIFICA'');!end' FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 | tr '\t' ' ' | sed 's/ //g' | tr '!' ' '>>${SCI_SCRIPT}

# Matriz Final prioridad

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT 'autoVector',TIPO FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 | tr '\n' ',' | sed 's/.$//' | tr '\t' ' ' | sed 's/ //g' | sed 's/^/matrizPrioridadFinal=[/'| sed 's/$/];/' >>${SCI_SCRIPT}

## Saco la ponderacion final

echo "vectorResultados=([])" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('vectorResultados(',MODELO,')=matrizPrioridadFinal(',MODELO,',:)*autoVectorPrioridad;') FROM DATO_ESTUDIO GROUP BY MODELO ORDER BY MODELO;" | tail -n +2 >>${SCI_SCRIPT}

echo "escritura=fullfile('"${PWD}/${temp}"','"${SCI_SALIDA}"')" >>${SCI_SCRIPT}

echo "csvWrite(vectorResultados,escritura)" >>${SCI_SCRIPT}

scilab -nwni <${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};CREATE TABLE SALIDA_AHP (ahpID INT NOT NULL, MODELO INT NOT NULL, MAGNITUD DOUBLE);SELECT MODELO FROM DATO_ESTUDIO GROUP BY MODELO ORDER BY MODELO;" | tail -n +2 >${temp}/resultado.ahp 

paste -d ',' ${temp}/resultado.ahp ${temp}/resultado.ahp ${temp}${SCI_SALIDA} | sed 's/^/INSERT INTO SALIDA_AHP VALUES(/' | sed 's/$/);/' >${temp}/resultado.sql   

mysql -u "${user}" --password="${pass}" -D${DB} <${temp}/resultado.sql   

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT MODELO.MODELO, MAGNITUD FROM SALIDA_AHP JOIN(MODELO) ON(SALIDA_AHP.MODELO=MODELO.moID) ORDER BY MAGNITUD DESC;"

read culo

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};DROP TABLE SALIDA_AHP;"

################### MANTENIMIENTO ########################################



VAR_s==${temp}"*.ed" 

rm $VAR_s

exit 0
