#!/bin/bash
#
# Script para la visualizacion de las aeronaves vigentes
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
			--backtitle "VISUALIZACION" \
			--title "MODELOS DE AERONAVES VIGENTES" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--visit-items \
			--menu "DESPLAZAR USANDO LA FLECHAS" 0 0 0 "${foraneos[@]}" \
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

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT moID AS ID,CONCAT(FABRICANTE.NOMBRE_COMERCIAL,' ',MODELO.MODELO) AS AERONAVE, CONCAT(FABRICANTE_MOTOR.NOMBRE_COMERCIAL,' ',MODELO_MOTOR.MODELO) AS 'PLANTA DE PODER' FROM MODELO JOIN(FABRICANTE,FABRICANTE_MOTOR,MODELO_MOTOR) ON(FABRICANTE.fbID=MODELO.FABRICANTE AND FABRICANTE_MOTOR.fbmID=MODELO_MOTOR.FABRICANTE_MOTOR AND MODELO.MODELO_MOTOR=MODELO_MOTOR.momid) ORDER BY FABRICANTE.NOMBRE_COMERCIAL,MODELO.MODELO;" | column -t -s $'\t' >${temp}"tmp2.ed"

menu_seleccion

################### matrizPrioridadFinalANTENImatrizPrioridadFinalIENTO ########################################

exit 192
