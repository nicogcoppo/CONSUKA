#!/bin/bash
#
#
#
# script: Contiene al menu principal
# 
## $0 SCRIPT $1 FONDO $2 TITULO $3 SUB-TITULO $4 CANT. BREAKS
# 
#

#shopt -s -o unset

################### DECLARACIONES ########################


declare -r UBIN=$1

declare -r FONDO=${2}

declare -r TITULO=${3}

declare -r SUBT=${4}

declare -r SCRIPT=${0##*/}


# //////// ENTRADA

declare -r SELECT="mID,nombre_nm"

declare -r MENU_=""${DB}"."${MENU}""

declare -r LEFTJOIN=""${DB}"."${NOMBRE_MENU}","${DB}"."${UBICACIONES}""

declare -r ON=""${DB}"."${NOMBRE_MENU}".nmID="${DB}"."${MENU}".nombre_m AND "${DB}"."${UBICACIONES}".ubID="${DB}"."${MENU}".ubicacion_m"

declare -r WHERE=""${DB}"."${UBICACIONES}".ubicacion_ub='"${UBIN}"' AND para7_m >="${lv}""


#///////// SALIDA

#Para agregar un Parametro es necesario insertar tres datos
# PARAMETROS_TITULOS >> titulo que figura en la tabla menu
# DIRECCION_TITULOS >>Columna de la tabla  clave foranea
# DIRECCION_TABLA >> Nonbre de la tabla clave foranea

declare   CONTADOR="0"

declare -a ABECEDARIO=("a" "b" "c" "d" "e" "f" "g" "h" "y" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z")

declare    SELECT_S="tipo_sc"

declare -r MENU_S=""${DB}"."${MENU}""

declare -r JOIN_S=""${DB}"."${SCRIPTS}""

declare -r ON_S=""${DB}"."${SCRIPTS}".scID="${DB}"."${MENU}".cont_m"  

declare -a PARAMETROS_TITULOS=("proxubi_m" "para1_m" "para2_m" "para3_m")

declare -a DIRECCION_TITULOS=("ubicacion_ub" "nombre_nm" "nombre_nm" "nombre_nm")

declare -a DIRECCION_TABLAS=("UBICACIONES" "NOMBRE_MENU" "NOMBRE_MENU" "NOMBRE_MENU")

declare -a DIRECCION_ID=("ubID" "nmID" "nmID" "nmID" )

declare -a JOINS

declare -a ONS

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	



VAR="SELECT "${SELECT}" FROM "${MENU_}" LEFT JOIN ("${LEFTJOIN}") ON ("${ON}") WHERE ("${WHERE}");" 


mysql -u "${user}" --password="${pass}" --execute="${VAR}" > "./"${temp}"tmp.s"


sed 's/\x09/\t/g' <"./"${temp}"tmp.s" | tail -n +2 | column -t -s $'\t' >"./"${temp}"tmp2.s"


ar=()
while read n s ; do
    ar+=($n "$s")
done < "./"${temp}"tmp2.s"

##############
## Muestro menu segun parametros argumentados y array previamente adecuado
##############

while true; do
  exec 3>&1
  selection="$(dialog --column-separator '\t' --backtitle "${FONDO}" --title "${TITULO}" --menu "${SUBT}" 0 0 0 "${ar[@]}" 2>&1 1>&3)"
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL) 
      clear
      echo "SE CANCELO LA OPERACION "
      exit 192
      ;;
    $DIALOG_ESC)
      clear
      echo "SE ABORTO LA OPERACION" >&2
      exit 204
      ;;
  esac
 
  if ! [[ $selection =~ $re ]] ; then
      dialog --msgbox "${SCRIPT} no puede reconocer el comando ingresado, presione ENTER para seleccionar"
  else
      
      break
      
  fi

  
done

####################
# ADECUO EL COMANDO DE SALIDA EN FUNCION DE LOS PARAMETROS QUE SE DESEAN OBTENER
####################



CONTADOR=0

for i in ${PARAMETROS_TITULOS[@]};do
    JOINS[$CONTADOR]=""${DB}"."${DIRECCION_TABLAS[$CONTADOR]}" "${ABECEDARIO[$CONTADOR]}""
    ONS[$CONTADOR]=""${ABECEDARIO[$CONTADOR]}"."${DIRECCION_ID[$CONTADOR]}"="${DB}"."${MENU}"."${PARAMETROS_TITULOS[$CONTADOR]}""
    SELECT_S+=","${ABECEDARIO[$CONTADOR]}"."${DIRECCION_TITULOS[$CONTADOR]}""
    let CONTADOR+=1
done


SELECT_S+=",para4_m,para5_m"

VAR="SELECT "${SELECT_S}" FROM "${MENU_S}" JOIN ("${JOIN_S}") ON ("${ON_S}")" 

CONTADOR=0


for i in ${PARAMETROS_TITULOS[@]};do
    VAR+=" JOIN ("${JOINS[$CONTADOR]}") ON ("${ONS[$CONTADOR]}")"
    let CONTADOR+=1
done



VAR+=" WHERE ("${MENU_S}".mID="${selection}");"


mysql -u "${user}" --password="${pass}" --execute="${VAR}" | tail -n +2 > "./"${temp}"tmp.m"



################## MANTENIMIENTO ###################

VAR_s=${temp}"*.s" 

rm $VAR_s

exit 0

