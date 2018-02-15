#!/bin/bash
#
#
#
#Configuracion automatica MIDOKA 3.0



################## DECLARACIONES #############################

declare -r user=$USER

declare -rx SCRIPT=${0##*/}

# /////// ARRAY DE COMANDOS NECESARIOS ///////

declare -rx MYSQL="/usr/bin/mysql"

declare -rx DIALOG="/usr/bin/dialog"

declare -rx SED="/bin/sed"

declare -rx AWK="/usr/bin/awk"

declare -rx MAXIMA="/usr/bin/maxima"

declare -rx BASE64="/usr/bin/base64"

declare -a COMANDOS=($MYSQL $DIALOG $SED $AWK $ENSCRIPT $MAXIMA $BASE64)

declare -a DETALLES=("mysql (base de datos)" "dialog (menu grafico)" "sed" "awk" "MAXIMA" "BASE64 DECODER")

# ////////////////////////////////////////////


declare -r DIR="/var/lib/mysql/"  # Directorio de trabajo de la BASE DE DATOS

declare -r scr="scripts/"

declare -r arc="archivos/"

declare -r temp="temporales/"

declare -r act="actualizaciones/"

declare -i CONTADOR=0

declare -r pipe='"|"'

################## SANIDADES #################################

clear

cat ${arc}"LEEME" | head -8

echo -e "\nINGRESE EL NOMBRE DE LA EMPRESA : " 

read DATABASE

declare -r DB=${DATABASE}


#### Reemplazamientos segun database #######################

sed -i "s/.*DB=.*/declare -rx DB="${DB}"/" CONSUKA.sh

sed -i  "s/.*USE.*/USE "${DB}";/" ${act}CONSULTORA-1.0.sql

sed -i  "s/.*DROP.*/DROP DATABASE IF EXISTS "${DB}";/" ${act}CONSULTORA-1.0.sql

sed -i  "s/.*CREATE DATABASE.*/CREATE DATABASE "${DB}";/" ${act}CONSULTORA-1.0.sql

sed -i "s/.*USE.*/USE "${DB}";/" ${arc}transaccion_a

############################################################


for i in ${COMANDOS[@]};do
   
    if test ! -x "$i" ;then
	printf "\n$SCRIPT:$LINENO: El comando necesario ${DETALLES[$CONTADOR]} no se encuentra disponible--> ABORTANDO\n\n" >&2
	exit 192
    fi
    let CONTADOR=CONTADOR+1

done

CONTADOR=0
    

################## FUNCIONES ##################################

function creo_usuarios {

    while true; do

    clear

    echo -e "'\n INGRESE NOMBRE COMPLETO"

    read NOMBRE

    echo -e "'\n INGRESE CODIGO CORRESPONDIENTE...\n"
    
    mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT rhID as CODIGO, rh_rh AS TIPO FROM RECURSOS_HUMANOS;" 
        
    read CODIGO

    NIVEL=$CODIGO
    
    echo -e "'\n INGRESE NOMBRE DE USUARIO"

    read USUARIO

    echo -e "'\n INGRESE PALABRA CLAVE"

    read CLAVE
    
    CLAVE_ascii="no_util"

    mysql -u "${user}" --password="${pass}"  --execute="CREATE USER IF NOT EXISTS '${USUARIO}'@'localhost';GRANT ALL PRIVILEGES ON  "${DB}".* to '${USUARIO}'@'localhost' WITH GRANT OPTION;SET PASSWORD FOR '${USUARIO}'@'localhost' = PASSWORD('${CLAVE}');"

    mysql -u "${user}" --password="${pass}"  --execute="USE "${DB}";INSERT INTO RECURSOS_HUMANOS_DISPONIBLES (nombre_rhd,tipo_rhd,USUARIO,ACCESO,NIVEL) VALUES ('${NOMBRE}',"${CODIGO}",'${USUARIO}','${CLAVE_ascii}',"${NIVEL}");" 

    clear

    echo "ok. ENTER para seguir creando" && read resp

    test !-z $resp && break 
    
    
done

}


################## SCRIPT PRINCIPAL #############################

#### ///// 

echo -e "\n Ingrese pass. SuperUsuario: "

read pass

mysql -u "${user}" <./${act}/CONSULTORA-1.0.sql

creo_usuarios

############## MANTENIMIENTO #######################################################


rm -rf "./"${temp}"/*"

exit 192

