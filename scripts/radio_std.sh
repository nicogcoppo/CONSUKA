#!/bin/bash
#
# Script para el desplegado del menu de tipo RADIO
#

############## DECLARACIONES ###########################

declare CONTADOR

declare -a foraneos

declare -a ESTADO

declare -r FONDO="$1"

declare -r TITULO="$2"

declare -r SUBTITULO="$3"

declare -r ENTRADA="$4"

declare -r SALIDA="$5"

declare VAR

################# FUNCIONES ############################

function control_estados { 

    CONTADOR=0
    while read line ; do

	ESTADO[${CONTADOR}]=""${line}""
	let CONTADOR+=1
	
    done < "./"${temp}"/"${SALIDA}""

    
    CONTADOR=0
    foraneos=()
    while read line ; do
	let VAR=${CONTADOR}+1 
	foraneos+=(""${line}"" ""${VAR}"" "3" """${ESTADO[${CONTADOR}]}""" ""${VAR}"" "30" "30" "100")
	let CONTADOR+=1
	echo "${foraneos[@]}"
    done < "./"${temp}"/"${ENTRADA}""
}



###############  SCRIPT ###########################



control_estados



dialog --backtitle "${FONDO}" --title "${TITULO}" \
       --form "\n${SUBTITULO}" 0 0 0 "${foraneos[@]}" \
       2>""${temp}"/"${SALIDA}""



################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.r " 

rm $VAR_s

exit 0
