#!/bin/bash
#
# Script para el calculo automatizado de AHP (Saaty)
#

############## DECLARACIONES ###########################

declare -r SCI_SCRIPT=""${temp}"/"${RANDOM}".sci"

declare -r SCI_SALIDA=""${RANDOM}"-SALIDA.sci"

################# FUNCIONES ############################


function menu_seleccion {

    declare VAR
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    cat "./"${temp}"/tmp2.ed" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ed"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "PROCESO ANALITICO JERARQUICO AHP" \
			--title "RESULTADOS DEL CALCULO" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "DESPLAZARSE CON LA FECHA" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;
	esac

	
	break
	
    done

    

}


###############  SCRIPT ###########################

## Armado de script de SCILAB
# Se define la matriz principal de relaciones entre Tipos de dato

echo 'function j=criterioAlonso(x);j=x+0.1*(1.7699*x-4.3513);endfunction' >${SCI_SCRIPT}

echo "PPAL=([])" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('PPAL(',t1.TIPO_DATO_ESTUDIO,',',t1.RELATIVO,')=',t1.MAGNITUD) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) JOIN (JERARQUIA) ON(JERARQUIA.TIPO_DATO_ESTUDIO=t1.TIPO_DATO_ESTUDIO) WHERE t2.REGISTRO IS NULL AND JERARCA=JERARQUIA.TIPO_DATO_ESTUDIO;" | tail -n +2 >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('PPAL(',t1.RELATIVO,',',t1.TIPO_DATO_ESTUDIO,')=',1 / t1.MAGNITUD) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) JOIN (JERARQUIA) ON(JERARQUIA.TIPO_DATO_ESTUDIO=t1.TIPO_DATO_ESTUDIO) WHERE t2.REGISTRO IS NULL AND JERARCA=JERARQUIA.TIPO_DATO_ESTUDIO;" | tail -n +2  >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente

echo "f=size(PPAL,1);c=size(PPAL,1);UNOS=eye(ones(f,c));PPAL=UNOS+PPAL;[row, column] = find(sum(PPAL,1) == 1);PPAL(:, column) = [];[row, column] = find(sum(PPAL,2) == 0);PPAL(row,:) = []" >>${SCI_SCRIPT}

## Saco Autovalores y Autovectores

echo "[R,data]=spec(PPAL)" >>${SCI_SCRIPT}

echo "[landaPpal,j]=max(real(data))" >>${SCI_SCRIPT}

echo "autoVectorPpal=(R(:,j(2)).^2)/sum(R(:,j(2)).^2)" >>${SCI_SCRIPT}

echo "n=size(PPAL,1)" >>${SCI_SCRIPT}

echo 'if criterioAlonso(n) > landaPpal then disp("Verifica consistencia"); else disp("La Matriz Principal NO VERIFICA consistencia"); end' >>${SCI_SCRIPT}


## Se define las relaciones entre las variables devenidas de las principales

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};(SELECT TIPO,RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO FROM RELEVANCIA_DATOS JOIN (TIPO_DATO_ESTUDIO,JERARQUIA) ON (TIPO_DATO_ESTUDIO.tdID=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO AND JERARQUIA.TIPO_DATO_ESTUDIO=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO) WHERE JERARCA=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO GROUP BY TIPO) UNION (SELECT TIPO,RELEVANCIA_DATOS.RELATIVO AS TIPO_DATO_ESTUDIO FROM RELEVANCIA_DATOS JOIN (TIPO_DATO_ESTUDIO,JERARQUIA) ON (TIPO_DATO_ESTUDIO.tdID=RELEVANCIA_DATOS.RELATIVO AND JERARQUIA.TIPO_DATO_ESTUDIO=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO) WHERE RELATIVO NOT IN (SELECT RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO FROM RELEVANCIA_DATOS JOIN (TIPO_DATO_ESTUDIO,JERARQUIA) ON (TIPO_DATO_ESTUDIO.tdID=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO AND JERARQUIA.TIPO_DATO_ESTUDIO=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO) WHERE JERARCA=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO) AND JERARCA=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO GROUP BY TIPO) ORDER BY TIPO_DATO_ESTUDIO;" | tail -n +2 | awk '{print $1}' | sed 's/$/=([])/' >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(t3.TIPO,'(',t1.TIPO_DATO_ESTUDIO,',',t1.RELATIVO,')=',t1.MAGNITUD) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) JOIN (TIPO_DATO_ESTUDIO,JERARQUIA) ON(t1.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID AND JERARQUIA.TIPO_DATO_ESTUDIO=t1.TIPO_DATO_ESTUDIO) LEFT JOIN TIPO_DATO_ESTUDIO t3 ON(t3.tdID=JERARQUIA.JERARCA) WHERE t2.REGISTRO IS NULL AND JERARCA<>JERARQUIA.TIPO_DATO_ESTUDIO;" | tail -n +2 >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(t3.TIPO,'(',t1.RELATIVO,',',t1.TIPO_DATO_ESTUDIO,')=',1 / t1.MAGNITUD) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) JOIN (TIPO_DATO_ESTUDIO,JERARQUIA) ON(t1.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID AND JERARQUIA.TIPO_DATO_ESTUDIO=t1.TIPO_DATO_ESTUDIO) LEFT JOIN TIPO_DATO_ESTUDIO t3 ON(t3.tdID=JERARQUIA.JERARCA) WHERE t2.REGISTRO IS NULL AND JERARCA<>JERARQUIA.TIPO_DATO_ESTUDIO;" | tail -n +2 >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT 'f=size(',t1.TIPO,',1);c=size(',t1.TIPO,',1);UNOS=eye(ones(f,c));',t1.TIPO,'=UNOS+',t1.TIPO,';[row, column] = find(sum(',t1.TIPO,',1) == 1);',t1.TIPO,'(:, column) = [];[row, column] = find(sum(',t1.TIPO,',2) == 0);',t1.TIPO,'(row,:) = [];','[R,data]=spec(',t1.TIPO,');','[landa',t1.TIPO,',j]=max(real(data));','autoVector',t1.TIPO,'=(R(:,j(2)).^2)/sum(R(:,j(2)).^2);n=size(',t1.TIPO,',1);if!criterioAlonso(n)!>!landa',t1.TIPO,'!then!disp(''Verifica!consistencia'');!else!disp(&',t1.TIPO,'&);disp(''NO!VERIFICA'');!end' FROM RELEVANCIA_DATOS JOIN (TIPO_DATO_ESTUDIO,JERARQUIA) ON (TIPO_DATO_ESTUDIO.tdID=RELEVANCIA_DATOS.TIPO_DATO_ESTUDIO AND JERARQUIA.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID) LEFT JOIN TIPO_DATO_ESTUDIO t1 ON(JERARQUIA.JERARCA=t1.tdID ) WHERE JERARCA<>JERARQUIA.TIPO_DATO_ESTUDIO GROUP BY t1.TIPO;" | tail -n +2 | tr '\t' ' ' | sed 's/ //g' | sed "s/&/'/g" | tr '!' ' '>>${SCI_SCRIPT}

## Genero el vector prioridad final

#mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('autoVectorPpal(',ROW_NUMBER() OVER (ORDER BY t1.TIPO_DATO_ESTUDIO),')*autoVector',TIPO) FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) JOIN (JERARQUIA,TIPO_DATO_ESTUDIO) ON(JERARQUIA.TIPO_DATO_ESTUDIO=t1.TIPO_DATO_ESTUDIO AND t1.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID) WHERE t2.REGISTRO IS NULL AND JERARCA=JERARQUIA.TIPO_DATO_ESTUDIO GROUP BY t1.TIPO_DATO_ESTUDIO;" | tail -n +2 | tr '\n' ',' | sed 's/^/autoVectorPrioridadFinal=cat(1,/' | sed 's/.$/)/' >>${SCI_SCRIPT} # Sacas la variacion entre dos columnas con la fecha mas reciente


mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('autoVectorPpal(',ROW_NUMBER() OVER (ORDER BY TIPO_DATO_ESTUDIO.tdID),')*autoVector',TIPO) FROM JERARQUIA JOIN(TIPO_DATO_ESTUDIO) ON(JERARQUIA.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID) WHERE JERARCA=JERARQUIA.TIPO_DATO_ESTUDIO GROUP BY TIPO ORDER BY TIPO_DATO_ESTUDIO.tdID;" | tail -n +2  | tr '\n' ',' | sed 's/^/autoVectorPrioridadFinal=cat(1,/' | sed 's/.$/);/' >>${SCI_SCRIPT}


#Se definen las matrices para cada uno de los elementos de interes

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DISTINCT(TIPO) FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO);" | tail -n +2 | sed 's/$/=([])/' >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(TIPO,'(',t1.MODELO,',',t3.MODELO,')=',t1.MAGNITUD / t3.MAGNITUD) FROM DATO_ESTUDIO t1 LEFT JOIN DATO_ESTUDIO t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.MODELO = t2.MODELO AND t1.REGISTRO < t2.REGISTRO) LEFT JOIN DATO_ESTUDIO t3 ON (t1.TIPO_DATO_ESTUDIO = t3.TIPO_DATO_ESTUDIO AND t1.MODELO < t3.MODELO) JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=t1.TIPO_DATO_ESTUDIO) LEFT JOIN DATO_ESTUDIO t4 ON (t3.TIPO_DATO_ESTUDIO = t4.TIPO_DATO_ESTUDIO AND t3.MODELO = t4.MODELO AND t3.REGISTRO < t4.REGISTRO) WHERE t2.REGISTRO IS NULL AND t4.REGISTRO IS NULL AND t1.ESTUDIO=1 ORDER BY t1.TIPO_DATO_ESTUDIO,t1.MODELO;" | tail -n +2 | grep -v "NULL" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(TIPO,'(',t3.MODELO,',',t1.MODELO,')=',t3.MAGNITUD / t1.MAGNITUD) FROM DATO_ESTUDIO t1 LEFT JOIN DATO_ESTUDIO t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.MODELO = t2.MODELO AND t1.REGISTRO < t2.REGISTRO) LEFT JOIN DATO_ESTUDIO t3 ON (t1.TIPO_DATO_ESTUDIO = t3.TIPO_DATO_ESTUDIO AND t1.MODELO < t3.MODELO) JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=t1.TIPO_DATO_ESTUDIO) LEFT JOIN DATO_ESTUDIO t4 ON (t3.TIPO_DATO_ESTUDIO = t4.TIPO_DATO_ESTUDIO AND t3.MODELO = t4.MODELO AND t3.REGISTRO < t4.REGISTRO) WHERE t2.REGISTRO IS NULL AND t4.REGISTRO IS NULL AND t1.ESTUDIO=1 ORDER BY t1.TIPO_DATO_ESTUDIO,t1.MODELO;" | tail -n +2 | grep -v "NULL" >>${SCI_SCRIPT}

#mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT(TIPO,'(',TIPO,'==0)=1') FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 >>${SCI_SCRIPT}

#mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT '[R,data]=spec(',TIPO,');','[landa',TIPO,',j]=max(real(data));','autoVector',TIPO,'=(R(:,j(2)).^2)/sum(R(:,j(2)).^2);n=size(',TIPO,',1);if!criterioAlonso(n)!>!landa',TIPO,'!then!disp(''Verifica!consistencia'');!else!disp(&',TIPO,'&);disp(''NO!VERIFICA'');!end' FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 | tr '\t' ' ' | sed 's/ //g' | sed "s/&/'/g" | tr '!' ' '>>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT 'f=size(',TIPO,',1);c=size(',TIPO,',1);UNOS=eye(ones(f,c));',TIPO,'=UNOS+',TIPO,';[row, column] = find(sum(',TIPO,',1) == 1);',TIPO,'(:, column) = [];[row, column] = find(sum(',TIPO,',2) == 0);',TIPO,'(row,:) = [];','[R,data]=spec(',TIPO,');','[landa',TIPO,',j]=max(real(data));','autoVector',TIPO,'=(R(:,j(2)).^2)/sum(R(:,j(2)).^2);n=size(',TIPO,',1);if!criterioAlonso(n)!>!landa',TIPO,'!then!disp(''Verifica!consistencia'');!else!disp(&',TIPO,'&);disp(''NO!VERIFICA'');!end' FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 | tr '\t' ' ' | sed 's/ //g' | sed "s/&/'/g" | tr '!' ' '>>${SCI_SCRIPT}

# Matriz Final prioridad

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT 'autoVector',TIPO FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO ORDER BY TIPO_DATO_ESTUDIO;" | tail -n +2 | tr '\n' ',' | sed 's/.$//' | tr '\t' ' ' | sed 's/ //g' | sed 's/^/matrizPrioridadFinal=[/'| sed 's/$/];/' >>${SCI_SCRIPT}

## Saco la ponderacion final

echo "vectorResultados=([])" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('vectorResultados(',ROW_NUMBER() OVER(ORDER BY MODELO),')=matrizPrioridadFinal(',ROW_NUMBER() OVER(ORDER BY MODELO),',:)*autoVectorPrioridadFinal;') FROM DATO_ESTUDIO GROUP BY MODELO;" | tail -n +2 >>${SCI_SCRIPT}

echo "escritura=fullfile('"${PWD}/${temp}"','"${SCI_SALIDA}"');csvWrite(vectorResultados,escritura);" >>${SCI_SCRIPT}

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT CONCAT('escritura=fullfile(!"${PWD}/${temp}"!,!',ROW_NUMBER() OVER(ORDER BY TIPO_DATO_ESTUDIO),'_.csv!);','csvWrite(autoVector',TIPO,',escritura,[],[],[],!',TIPO,'!);') FROM DATO_ESTUDIO JOIN (TIPO_DATO_ESTUDIO) ON (TIPO_DATO_ESTUDIO.tdID=DATO_ESTUDIO.TIPO_DATO_ESTUDIO) GROUP BY TIPO;" | tail -n +2 | sed "s/!/'/g"  >>${SCI_SCRIPT}

scilab -nwni <${SCI_SCRIPT} >${temp}regsScilab.sci && (test ! -z $(cat ${temp}regsScilab.sci | grep "NO VERIFICA" | head -c 2) && dialog --msgbox "Existe una incosistencia en una o mas matrices" 0 0)

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};DROP TABLE IF EXISTS SALIDA_AHP;CREATE TABLE SALIDA_AHP (ahpID INT NOT NULL, MODELO INT NOT NULL, MAGNITUD DOUBLE);SELECT MODELO FROM DATO_ESTUDIO GROUP BY MODELO ORDER BY MODELO;" | tail -n +2 >${temp}/resultado.ahp 

grep -v '^0$' ${temp}${SCI_SALIDA} >${temp}resultado_scilab.sci

paste -d ',' ${temp}/resultado.ahp ${temp}/resultado.ahp ${temp}resultado_scilab.sci | sed 's/^/INSERT INTO SALIDA_AHP VALUES(/' | sed 's/$/);/' >${temp}/resultado.sql   

mysql -u "${user}" --password="${pass}" -D${DB} <${temp}/resultado.sql   

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT MODELO.MODELO, CONCAT(ROUND(MAGNITUD * 100,2),' %') AS 'CONVENIENCIA' FROM SALIDA_AHP JOIN(MODELO) ON(SALIDA_AHP.MODELO=MODELO.moID) ORDER BY MAGNITUD DESC;"  | column -t -s $'\t' >${temp}"tmp2.ed"

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT MODELO.MODELO, CONCAT(ROUND(MAGNITUD * 100,2),' %') AS 'CONVENIENCIA' FROM SALIDA_AHP JOIN(MODELO) ON(SALIDA_AHP.MODELO=MODELO.moID) ORDER BY SALIDA_AHP.MODELO;"

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT MODELO.MODELO, CONCAT(ROUND(MAGNITUD * 100,2),' %') AS 'CONVENENCIA' FROM SALIDA_AHP JOIN(MODELO) ON(SALIDA_AHP.MODELO=MODELO.moID) ORDER BY SALIDA_AHP.MODELO;"  | tr '\t' ';' >${temp}"visualResul"

menu_seleccion

paste -d ';' ${temp}"visualResul" ${temp}*_.csv | tr '.' ',' >${inf}informe_${RANDOM}.csv


################### MANTENIMIENTO ########################################




exit 192
