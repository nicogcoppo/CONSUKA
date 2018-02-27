#!/bin/bash
#
# Script para el agregado de un nuevo cliente
#

############## DECLARACIONES ###########################

declare -a foraneos

declare -a flag_f

declare CONTADOR

declare VAR

declare -a INDISPENSABLE=()

declare -r FONDO=${2}

declare -r TITULO=${3}

declare -r SUBT=${4}

declare -r TABLA=$5

################# FUNCIONES ############################

function control_estados {
    
    CONTADOR=0
    while read line ; do

	if [ "$line" = ".." ] ; then
	    line="INCOMPLETO"
	fi
    	
	flag_f[${CONTADOR}]="${line}"
	let CONTADOR+=1
	
    done < "./"${temp}"/tmp_num_v.ed"


    CONTADOR=0
    foraneos=()
    while read line ; do


	foraneos+=("${line}" "${flag_f[${CONTADOR}]}")
	let CONTADOR+=1
	
    done < "./"${temp}"/tmp.ed"
}


# La funcion ubicar , escribe en la linea de texto correlativa a la ubicacion en el archivo tmp.ed

function ubicar { # $selection
    
    CONTADOR=$(grep -nr "${1}" "./"${temp}"/tmp.ed" | head -1 |tr ':' '\t' | awk '{print $1}')

    
    cat ""${temp}"/selection.ed" | tail -n +2 | awk '{print $1}' >""${temp}"/a.ed"

    
    cat ""${temp}"/selection.ed" | tail -n +2 | awk 'BEGIN{FS=OFS="\t"}{$1="";}1' >""${temp}"/b.ed"    

    
    VAR="$(cat ""${temp}"/a.ed")"
    
    awk 'NR=='"${CONTADOR}"'{print "'"${VAR}"'"}1' ""${temp}"/tmp_num.ed" > ""${temp}"/tmp3.ed"
   
    
    mv ""${temp}"/tmp3.ed" ""${temp}"/tmp_num.ed" 

    awk 'NR=='"${CONTADOR}"'{print "'"$(cat ""${temp}"/b.ed")"'"}1' ""${temp}"/tmp_num_v.ed" > ""${temp}"/tmp3.ed"


    mv ""${temp}"/tmp3.ed" ""${temp}"/tmp_num_v.ed"

    let CONTADOR+=1
    
    sed -i -e ''"${CONTADOR}"'d' ""${temp}"/tmp_num.ed" ""${temp}"/tmp_num_v.ed"

    
}

# Controla que se haya ubicado informacion en el archivo de texto, en las lineas
# especificadas en el array

function control_indispensables {  # ARRAY ARCHIVO>archivo.ed

    declare -a array=("$@")
    declare -r archivo=$(cat ""${temp}"archivo.ed")
    declare VAR_A

    echo "NO UTIL"> ""${temp}"/selection.ed"
    
    CONTADOR=0
    for i in ${array[@]};do
	VAR_A=$(sed ''${i}'q;d' ""${temp}""${archivo}"")
	if test -z ${VAR_A} ;then
	    echo -e "1" '\t' "INCOMPLETO" >> ""${temp}"/selection.ed"
	    ubicar "DATOS"
	    return
	fi
	
    done
    echo -e "1" '\t' "COMPLETO" >> ""${temp}"/selection.ed"
    ubicar "DATOS"
}

function grabacion { # SE CONTROLA QUE ESTEN TODOS LOS DATOS COMPLETOS Y SE PROCEDE A CREAR UNA FILA EN MARIADB CON DICHOS DATOS
 
    declare -r ARCHIVO_CONTROL=$1
    
    declare -r DENOMINACION_UNO=$2
    
    declare -r DENOMINACION_DOS=$3

    declare -r DATA_UNO=$4

    declare -r DATA_DOS=$5

    declare DENOMINACION

    declare DATA

    declare VAR
    
    while read line; do
	if [ "$line" = ".." ] ; then
	    return 1
	fi
    done<${temp}${ARCHIVO_CONTROL}
    
    pre_grabar "${DENOMINACION_UNO}" "${DENOMINACION_DOS}" "${DATA_UNO}" "${DATA_DOS}"

    DENOMINACION=$(cat ${temp}"denominaciones_grabado.ed")    

    testeo_coma """$DENOMINACION"""; DENOMINACION=$PRUEBA_TESTEO
    
    DATA=$(cat ${temp}"data_grabado.ed")

    testeo_coma """$DATA"""; DATA=$PRUEBA_TESTEO
   
    rm ${temp}"log_grabado.ed"

    VAR="INSERT INTO "${DB}"."${TABLA}" ("${DENOMINACION}") VALUES ("${DATA}");"

    mysql -u "${user}" --password="${pass}" --execute="${VAR}"  2>${temp}"log_grabado.ed"
    
    if test -s ${temp}"log_grabado.ed"; then
	DATA=$(cat ${temp}"log_grabado.ed")
        dialog --msgbox "${DATA}" 0 0
        return 2
    else
	dialog --msgbox "Grabacion de Nuevo Cliente Exitosa" 0 0
	return 0
    fi
    

    
}


function testeo_coma {

    PRUEBA_TESTEO=$1
    
    if [ "${PRUEBA_TESTEO:0:1}" = "," ]; then

	PRUEBA_TESTEO=$(echo $PRUEBA_TESTEO | sed 's/^.//')
	
    fi

     
    if [ "${PRUEBA_TESTEO:0:1}" = "[:alnum:]" ]; then

	PRUEBA_TESTEO=$(echo $PRUEBA_TESTEO | sed 's/^/"/')
	
    fi

}


function pre_grabar { # PREPARA LOS INDICADORES Y LOS DATOS A GRABAR. JUNTA LOS ARCHIVOS QUE SEAN NECESARIOS

    declare -r DENOMINACION_UNO=${temp}$1

    declare -r DENOMINACION_DOS=${temp}$2

    declare -r DATA_UNO=${temp}$3

    declare -r DATA_DOS=${temp}$4


    
    
    sed '$d' ${DENOMINACION_UNO} | tr '\n' ','| sed 's/.$//' >${temp}"tmp_denominaciones_grabado.ed"

    cat ${temp}"tmp_denominaciones_grabado.ed"

    cat ${DENOMINACION_DOS} | tr '\n' ',' | sed 's/.$//' >${temp}"tmp_denominaciones_grabado2.ed"

    paste ${temp}"tmp_denominaciones_grabado.ed" ${temp}"tmp_denominaciones_grabado2.ed" | tr '\t' ',' >${temp}"denominaciones_grabado.ed"
    
  
    sed 's/^\|$/"/g' ${DATA_UNO} | sed '$d' | paste -d, -s >${temp}"tmp_data_grabado.ed"

    sed 's/^\x24/-&/' ${DATA_DOS} | sed 's/^\|$/"/g' | paste -d, -s >${temp}"tmp_data_grabado2.ed"
    
    paste ${temp}"tmp_data_grabado.ed" ${temp}"tmp_data_grabado2.ed" | tr '\t' ',' >${temp}"data_grabado.ed"
    
}


function buscar_dia {
    declare TITULO_=$1
    exec 3>&1
	DIA_ASIGNA=$(dialog \
			--backtitle "CALENDARIO" \
			--title """${TITULO_}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--calendar "SELECCION UTILIZANDO ENTER" 0 0 0\
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
	reconstruir_fecha "${DIA_ASIGNA}"
}

function reconstruir_fecha {
    declare fecha=$1
    declare -a data_fecha
    CONTADOR=0
    echo ${fecha} | tr '/' '\n' >${temp}"fecha.ed"
    while read line;do
	data_fecha[${CONTADOR}]="${line}"
	let CONTADOR+=1
    done<${temp}"fecha.ed"
    DIA_ASIGNA=""${data_fecha[2]}"-"${data_fecha[1]}"-"${data_fecha[0]}""
}



    
function limpiado {

    
    VAR_s=${temp}"*.ed" 

    rm $VAR_s

}

###############  SCRIPT ###########################

## Se agrupan los campos de las tablas clientes por 1) CLAVES FORANEAS 2) VARCHAR

#mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${TABLA}";" | grep int | awk '{print $1}'| tail -n +2 > "./"${temp}"/tmp.ed"

mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${TABLA}";" | grep int | grep -v ANO | awk '{print $1}'| tail -n +2 > "./"${temp}"/tmp.ed"



mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${TABLA}";" | grep date | awk '{print $1}' >> "./"${temp}"/tmp.ed"

#mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${TABLA}";" | grep -v int | awk '{print $1}' | tail -n +2  > "./"${temp}"/tmp2.ed"

mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${TABLA}";" | grep -v int | grep -v date | awk '{print $1}' | tail -n +2  > "./"${temp}"/tmp2.ed"


mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${TABLA}";" | grep ANO | awk '{print $1}' >> "./"${temp}"/tmp2.ed"



echo "DATOS" >>"./"${temp}"/tmp.ed"

rm ""${temp}"/tmp_num.ed" ""${temp}"/tmp_num_v.ed"

touch ""${temp}"/tmp_num.ed" ""${temp}"/tmp_num_v.ed"

while read line;do

    echo ".." >>""${temp}"/tmp_num.ed"

    echo ".." >>""${temp}"/tmp_num_v.ed"

done < "./"${temp}"/tmp.ed"



while true; do
  control_estados  
  exec 3>&1
  selection=$(dialog \
    --backtitle """${FONDO}""" \
    --title """${TITULO}""" \
    --clear \
    --cancel-label "SALIR" \
    --help-button \
    --help-label "FINALIZAR" \
    --menu """${SUBT}""" 0 0 0 "${foraneos[@]}" \
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
	
      grabacion "tmp_num_v.ed" "tmp.ed" "tmp2.ed" "tmp_num.ed" "tmp_radio.ed"
	
      case $? in
	  1) selection="ERROR";;
	  2) selection="ERROR_mdb";;
	  *) limpiado
	     exit 192;;
      esac
      
      
      ;;
  esac
  case $selection in


     "ERROR")
        dialog --msgbox "ERROR DE GUARDADO : No todos los campos necesarios han sido completados" 0 0;;

     "ERROR_mdb")
        dialog --msgbox "Se acaba de producir un error de guardado en la base de datos" 0 0;;
      
     
    "DATOS" )
	
		
 	bash ""${scr}"/radio_std.sh" """${TITULO}""" """${SUBT}""" """${TABLA}""" "tmp2.ed" "tmp_radio.ed"

	echo "tmp_radio.ed" > ""${temp}"archivo.ed"

	control_indispensables "${INDISPENSABLE[@]}" 

	;;

    "FECHA" )
	
    	buscar_dia "${TABLA}"

    	echo -e "${DIA_ASIGNA}\t${DIA_ASIGNA}" > ""${temp}"/selection.ed"

	echo -e "${DIA_ASIGNA}\t${DIA_ASIGNA}" >> ""${temp}"/selection.ed"
	
    	ubicar "FECHA"
	
      ;;
    *)
	SELECCIONADO=$selection
	
	bash -o xtrace ${scr}"busqueda_tipo.sh" "${SELECCIONADO}"

	VAR=$(cat ${temp}"busqueda")

	ubicar "$SELECCIONADO"
	
     ;;
  esac
done




################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 0
