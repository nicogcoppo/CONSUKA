#!/bin/bash
#
# Script para el estudio de los datos cargados AHP
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
			--title "DATOS REGISTRADOS" \
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

#mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT ESTUDIO.TIPO AS ESTUDIO, MODELO.MODELO AS AERONAVE, TIPO_DATO_ESTUDIO.TIPO AS DATO, IF(MAGNITUD<.01,CONCAT(1 / MAGNITUD,' ',UNIDADES.UNIDAD,' INVERTIDO'),CONCAT(MAGNITUD,' ',UNIDADES.UNIDAD)) AS MAGNITUD FROM DATO_ESTUDIO JOIN(UNIDADES,ESTUDIO,TIPO_DATO_ESTUDIO,MODELO) ON(DATO_ESTUDIO.MODELO=MODELO.moID AND DATO_ESTUDIO.UNIDADES=UNIDADES.unidID AND DATO_ESTUDIO.ESTUDIO=ESTUDIO.testID AND DATO_ESTUDIO.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID) ORDER BY MODELO.MODELO,TIPO_DATO_ESTUDIO.TIPO;"

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT ESTUDIO.TIPO AS ESTUDIO, MODELO.MODELO AS AERONAVE, TIPO_DATO_ESTUDIO.TIPO AS DATO, IF(t1.MAGNITUD<.01,CONCAT(1 / t1.MAGNITUD,' ',UNIDADES.UNIDAD,' INVERTIDO'),CONCAT(t1.MAGNITUD,' ',UNIDADES.UNIDAD)) AS MAGNITUD, t1.REGISTRO FROM DATO_ESTUDIO t1 JOIN(UNIDADES,ESTUDIO,TIPO_DATO_ESTUDIO,MODELO) ON(t1.MODELO=MODELO.moID AND t1.UNIDADES=UNIDADES.unidID AND t1.ESTUDIO=ESTUDIO.testID AND t1.TIPO_DATO_ESTUDIO=TIPO_DATO_ESTUDIO.tdID) LEFT JOIN DATO_ESTUDIO t2 ON(t1.TIPO_DATO_ESTUDIO=t2.TIPO_DATO_ESTUDIO AND t1.MODELO=t2.MODELO AND t1.REGISTRO<t2.REGISTRO) WHERE t2.REGISTRO IS NULL ORDER BY MODELO.MODELO,TIPO_DATO_ESTUDIO.TIPO;"  | column -t -s $'\t' >${temp}"tmp2.ed"
    
menu_seleccion

################### matrizPrioridadFinalANTENImatrizPrioridadFinalIENTO ########################################



exit 192
