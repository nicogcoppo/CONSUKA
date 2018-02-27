#!/bin/bash
#
#
#
# SCRIPT PRINCIPAL
# 

################### MANTENIMIENTO INICIAL #####################

rm log_errores


##########################################################

export NCURSES_NO_UTF8_ACS=1

#shopt -s -o unset

################### DECLARACIONES ########################

# ////////////////////////////////////////////


declare -rx SCRIPT=${0##*/}

declare -rx DIALOG_CANCEL=1

declare -rx DIALOG_ESC=255

declare -rx DIALOG_ITEM_HELP=2

declare -rx GLOBAL_ERROR=145

declare -rx F1=59

declare -rx DIR=$pwd  # DIRECTORIO PRINCIPAL SCRIPT

declare -rx SESION_ID="${RANDOM}"

declare -rx scr=${DIR}"scripts/"

declare -rx arc=${DIR}"archivos/"

declare -rx temp=${DIR}"temporales/"${SESION_ID}"/" || exit 1 ; cd ${temp} && exit 1 ; mkdir ${temp} || exit 1

declare -rx sql=${DIR}"transacciones/"

declare -rx glp=${DIR}"ThirdParty/glpk-4.61/examples/glpsol"

declare -rx MENU="MENU"

declare -rx NOMBRE_MENU="NOMBRE_MENU"

declare -rx UBICACIONES="UBICACIONES"

declare -rx SCRIPTS="SCRIPTS"

declare -rx DB=consuka1

declare -rx DIA=$(date +%F)

declare -rx MAXIMA_DIR=""${HOME}"/.maxima/"

declare -x POSICION="0"

# ////////////////////////////////////////////

declare -a DIRECTIVA_A

declare -a DIRECTIVA_b

declare -a DIRECTIVA_c

declare -a DIRECTIVA_d

declare -a DIRECTIVA_e

declare -a DIRECTIVA_f

declare -a DIRECTIVA_g

declare -a ABECEDARIO=("a" "b" "c" "d" "e" "f" "g" "h" "y" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z")

declare USUARIO

declare CLAVE

declare data

################### FUNCIONES ###############################

function lectura_seleccion {

    declare -r DESTINO=$1

    cat ${DESTINO} | tr '\t' '\n' > ${temp}tmp.mid

    let POSICION+=1

    DIRECTIVA_a[$POSICION]=$(sed '1q;d' ${temp}tmp.mid)
    DIRECTIVA_b[$POSICION]=$(sed '2q;d' ${temp}tmp.mid)
    DIRECTIVA_c[$POSICION]=$(sed '3q;d' ${temp}tmp.mid)
    DIRECTIVA_d[$POSICION]=$(sed '4q;d' ${temp}tmp.mid)
    DIRECTIVA_e[$POSICION]=$(sed '5q;d' ${temp}tmp.mid)
    DIRECTIVA_f[$POSICION]=$(sed '6q;d' ${temp}tmp.mid)
    DIRECTIVA_g[$POSICION]=$(sed '7q;d' ${temp}tmp.mid)
    
}    
	

function limpieza_formularios {

    rm ${temp}tmp2.ed ${temp}tmp_radio.ed

}



#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


#rm -rf ${temp}*

find temporales/* -type d -ctime +200  -exec rm -rf {} \; 

# IDENTIFICACION DEL USUARIO

data=${RANDOM}

while true; do
    

    exec 3>&1


    USUARIO=$(dialog \
		   --clear \
		   --cancel-label "SALIR" \
		   --help-button \
		   --help-label "AYUDA" \
		   --inputbox "INGRESE SU NOMBRE DE USUARIO" 0 0 2>&1 1>&3)

    exit_status=$?
    exec 3>&-

        exec 3>&1


    CLAVE=$(dialog \
		   --clear \
		   --cancel-label "SALIR" \
		   --help-button \
		   --help-label "AYUDA" \
		   --passwordbox "INGRESE SU CLAVE " 0 0 2>&1 1>&3)

    exit_status=$?
    exec 3>&-
 

    mysql -u ${USUARIO} --password="${CLAVE}" --execute="SELECT NIVEL FROM "${DB}".RECURSOS_HUMANOS_DISPONIBLES WHERE USUARIO='${USUARIO}';" | tail -n +2 >${temp}"${data}"

    if test -s ${temp}"${data}"; then
	break

    else
	dialog --msgbox "NOMBRE DE USUARIO O CLAVE INCORRECTO" 0 0
    fi
       
    
done

declare -rx user=${USUARIO}

declare -rx pass=${CLAVE}

declare -rx lv="$(cat ${temp}"${data}")"

rm ${temp}"${data}"

while true;do

    POSICION=0
    
    DIRECTIVA_a[$POSICION]="clasico.sh"
    DIRECTIVA_b[$POSICION]="PPAL"
    DIRECTIVA_c[$POSICION]="CONSUKA v1.0                                                                                               Consultoria Aeronautica"
    DIRECTIVA_d[$POSICION]="MENU PRINCIPAL"
    DIRECTIVA_e[$POSICION]="SELECCION UNA OPCION"
    
      
    while true;do   # $0 SCRIPT $1 FONDO $2 TITULO $3 SUB-TITULO 

	bash -o xtrace "./"${scr}${DIRECTIVA_a[$POSICION]} "${DIRECTIVA_b[$POSICION]}" "${DIRECTIVA_c[$POSICION]}" "${DIRECTIVA_d[$POSICION]}" "${DIRECTIVA_e[$POSICION]}" "${DIRECTIVA_f[$POSICION]}" "${DIRECTIVA_g[$POSICION]}" 
	case $? in
	    192)let POSICION+=-1;;
	    204)break;;
	    0)lectura_seleccion ${temp}"tmp.m"
	esac
	
	limpieza_formularios
	
    done
done



################## MANTENIMIENTO FINAL ###################


#exit 0

