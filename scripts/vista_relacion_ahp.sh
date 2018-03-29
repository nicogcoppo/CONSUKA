#!/bin/bash
#
# Script para la relacion entre variables AHP (Saaty)
#


############## DECLARACIONES ###########################

declare -r SCI_SCRIPT=""${temp}"/"${RANDOM}".sci"

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
			--title "RELACION ENTRE VARIABLES" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "EXPORTAR CSV" \
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
	    $DIALOG_ITEM_HELP)

		DATA_COMPOSC=""${RANDOM}"-"${DIA}".csv"
		
		cat "./"${temp}"/export.ed" >""${HOME}"/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
		;;

	esac

	
	break
	
    done

    

}


###############  SCRIPT ###########################

#mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT ESTUDIO.TIPO AS ESTUDIO, MODELO.MODELO AS AERONAVE, TIPO_DATO_ESTUDIO.TIPO AS DATO, IF(MAGNITUD<.01,CONCAT(1 / MAGNITUD,' ',UNIDADES.UNIDAD,' INVERTIDO'),CONCAT(MAGNITUD,' ',UNIDADES.UNIDAD)) AS MAGNITUD FROM DATO_ESTUDIO JOIN(UNIDADES,ESTUDIO,TIPO_DATO_ESTUDIO,MODELO) ON(DATO_ESTUDIO.MODELO=MODELO.moID AND DATO_ESTUDIO.UNIDADES=UNIDADES.unidID AND DATO_ESTUDIO.ESTUDIO=ESTUDIO.testID AND DATO_ESTUDIO.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID) ORDER BY MODELO.MODELO,TIPO_DATO_ESTUDIO.TIPO;"

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT ESTUDIO.TIPO AS ESTUDIO, t3.TIPO AS DATO, CONCAT('= ',t1.MAGNITUD,' veces ',t4.TIPO) AS 'RELATIVO', t1.REGISTRO FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) LEFT JOIN TIPO_DATO_ESTUDIO t3 ON(t3.tdID=t1.TIPO_DATO_ESTUDIO AND t3.tdID!=t1.RELATIVO) LEFT JOIN TIPO_DATO_ESTUDIO t4 ON(t4.tdID!=t1.TIPO_DATO_ESTUDIO AND t4.tdID=t1.RELATIVO) JOIN (ESTUDIO) ON(ESTUDIO.testID=t1.ESTUDIO) WHERE t2.REGISTRO IS NULL ORDER BY t3.TIPO,t1.MAGNITUD DESC;"  | column -t -s $'\t' >${temp}"tmp2.ed"

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT ESTUDIO.TIPO AS ESTUDIO, t3.TIPO AS DATO, CONCAT('= ',t1.MAGNITUD,' veces ',t4.TIPO) AS 'RELATIVO', t1.REGISTRO FROM RELEVANCIA_DATOS t1 LEFT JOIN RELEVANCIA_DATOS t2 ON (t1.TIPO_DATO_ESTUDIO = t2.TIPO_DATO_ESTUDIO AND t1.RELATIVO = t2.RELATIVO AND t1.REGISTRO < t2.REGISTRO) LEFT JOIN TIPO_DATO_ESTUDIO t3 ON(t3.tdID=t1.TIPO_DATO_ESTUDIO AND t3.tdID!=t1.RELATIVO) LEFT JOIN TIPO_DATO_ESTUDIO t4 ON(t4.tdID!=t1.TIPO_DATO_ESTUDIO AND t4.tdID=t1.RELATIVO) JOIN (ESTUDIO) ON(ESTUDIO.testID=t1.ESTUDIO) WHERE t2.REGISTRO IS NULL ORDER BY t3.TIPO,t1.MAGNITUD DESC;"  | tr '\t' ';' >${temp}"export.ed"

menu_seleccion

################### matrizPrioridadFinalANTENImatrizPrioridadFinalIENTO ########################################

exit 192
