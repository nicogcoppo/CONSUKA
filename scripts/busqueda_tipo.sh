#!/bin/bash
#
# Script para generear menu de busqueda en funcion del objetivo
#

############## DECLARACIONES ###########################

declare INDICE

declare -r OBJETIVO=$1

declare COLUMNA_REFERENCIA

declare VALOR

declare -a BUSQUEDAS

declare CONTADOR

declare VAR

declare VAR_a

declare ACTOR=""${OBJETIVO}""

################# FUNCIONES ############################

function menu {

    cat "./"${temp}"/tmp.bs" | awk -F "\t" '{print $1}' >"./"${temp}"/tmp2.bs"
    
    cat "./"${temp}"/tmp.bs" | awk -F "\t" '{print $2}' >"./"${temp}"/tmp3.bs"
    
    
    CONTADOR=0
    while read line ; do

 	BUSQUEDAS[${CONTADOR}]="${line}"
	let CONTADOR+=1
    done <"./"${temp}"/tmp3.bs"

    echo ${BUSQUEDAS[@]}
    
     CONTADOR=0
     foraneos=()
     while read line ; do

	foraneos+=("${line}" "${BUSQUEDAS[${CONTADOR}]}") 
 	
	let CONTADOR+=1
	
     done <"./"${temp}"/tmp2.bs"



    exec 3>&1
    selection=$(dialog \
		    --backtitle "ADMINISTRACION" \
		    --title "ELEGIR PARAMETRO DE BUSQUEDA" \
		    --clear \
		    --cancel-label "SALIR" \
		    --help-button \
		    --menu "SELECCIONAR CON ENTER:" 0 0 0 "${foraneos[@]}" \
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

    exec 3>&1

}    







###############  SCRIPT ###########################


rm ${temp}"busqueda"

while true;do
    

    INDICE=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${OBJETIVO}";" | awk '{print $1}'| head -2 | tail -n +2)

    COLUMNA_REFERENCIA=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${OBJETIVO}";" | awk '{print $1}'| head -3 | tail -n +3)

    test "${INDICE}" = "pooID" && COLUMNA_REFERENCIA="pooID"
    
    mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${OBJETIVO}";" | awk '{print $1}'| tail -n +3 > "./"${temp}"/tmp.bs"

    menu

    while true; do
	
	BUSCADO="${selection}"
	
	VALOR="$(dialog --inputbox "Ingrese el dato de: "${selection}"" 0 0 2>&1 1>&3)"

	case $? in
	    $DIALOG_CANCEL)
		clear
		
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;

	esac


	

	VAR_A=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | grep -E ''"""${selection}"""'.*int')

	if test ! -z """${VAR_A}""";then

	    
	    INDICE_F=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | grep -E 'varchar.*(([0-9]{2})|[0-9]{3})' | awk '{print $1}' | head -1)

	    #VAR_select=""${COLUMNA_REFERENCIA}","${INDICE_F}""

	    VAR_select=""${INDICE}","${INDICE_F}""

	    #VAR_join=""${DB}"."${selection}

	    #VAR_on=""${DB}"."${ACTOR}"."${selection}"="${DB}"."${selection}"."$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | awk '{print $1}'| head -2 | tail -n +2)

	    #VAR_A="SELECT "${VAR_select}" FROM "${DB}"."${ACTOR}" JOIN (""${VAR_join}"") ON (""${VAR_on}"") WHERE "${INDICE_F}" LIKE '%""${VALOR}""%';"

	    VAR_A="SELECT "${VAR_select}" FROM "${DB}"."${ACTOR}"  WHERE "${INDICE_F}" LIKE '%""${VALOR}""%';"
    
	    mysql -u "${user}" --password="${pass}" --execute="${VAR_A}" | tail -n +2 > "./"${temp}"/tmp.bs"

	else
	    mysql -u "${user}" --password="${pass}" --execute="SELECT "${INDICE}","${selection}" FROM "${DB}"."${OBJETIVO}" WHERE "${selection}" LIKE '%""${VALOR}""%';" | tail -n +2 >"./"${temp}"/tmp.bs"
	    

	fi
        

	if test -s "./"${temp}"/tmp.bs"; then
	    break 2
	else
	    dialog --msgbox "No existe cliente que responda al criterio de busqueda" 0 0
	fi
    done

done

    
menu




#VAR='SELECT '${INDICE}' FROM '${DB}'.'${OBJETIVO}' WHERE '${COLUMNA_REFERENCIA}'="'"${selection}"'";'

#test "${INDICE}" = "pooID" && VAR='SELECT '${INDICE}' FROM '${DB}'.'${OBJETIVO}' WHERE pooID="'"${selection}"'";'
 
#mysql -u "${user}" --password="${pass}" --execute="${VAR}" | tail -n +2 > "./"${temp}"/busqueda"

## BUSCO PRIMER VARCHAR PARA MOSTRADO DE LA SELECCION

SELEC_STD="$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";DESCRIBE "${OBJETIVO}";" | grep varchar | head -1 | awk '{print $1}')"

#mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT "${INDICE}","${SELEC_STD}" FROM "${OBJETIVO}" WHERE "${SELEC_STD}" LIKE '%""${selection}""%';" >""${temp}"/selection.ed"

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT "${INDICE}","${SELEC_STD}" FROM "${OBJETIVO}" WHERE "${INDICE}"="${selection}";" >""${temp}"/selection.ed"


################### MANTENIMIENTO ########################################

VAR_s=${temp}"*.bs" 

rm $VAR_s

exit 0
