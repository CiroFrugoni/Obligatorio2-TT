#!/bin/bash
# Taller de Tecnologias 1
# 1er semestre 2024
# Obligatorio n1
# Massimo Cantu  -  237773
# Jahir Mena     -  322735
# Ciro Frugoni   -  326909

USERSFILE="${0%/*}/users.txt"
DICTIONARYFILE="${0%/*}/diccionario.txt"

#
# LOG-IN LOGIC
#
LOGIN=0
CURRUSR=""
#Este while cumple la funcion de repetir las preguntas cuando los datos ingresados son incorrectos.
#Seguira repitiendo hasta que se consiga hacer log-in
#Se podria haber hecho mas facil con grep? Si, pero este codigo lo escribi antes de lo que dieramos en clase.
while [ $LOGIN -eq 0 ]
do
    # Primero se pide el usuario y la contrasena
    echo "Ingrese usuario"
    read user
    echo "Ingrese contraseña"
    read -s password
    #Este for itera por todas las lineas del archivo users.txt
    for i in `cat $USERSFILE`
    do
        USR="null"
        PWD="null"
        #Se separa la contrasena y el usuario en dos variables. el comando tr (trim) corta el string en el char ':'
        for j in $(echo $i | tr ":" "\n")
        do 
            if [ $USR = "null" ]
            then
                USR=$j
            elif [ $PWD = "null" ]
            then
                PWD=$j
            fi
        done

        #Se comparan el usuario y la contrasena ingresadas con los obtenidos de esta linea del archivo. Si ambas coinciden se realiza el log-in
        if [ $user = $USR ] && [ $password = $PWD ]
        then
            LOGIN=1
            CURRUSR=$USR
            break
        fi

    done

    #Si el log-in fallo se imprime un error y el while vuelve al principio.
    if [ $LOGIN -eq 0 ]
    then
        echo "Usuario o contraseña incorrectos. Intente de nuevo."
    fi
done

#
# HELP COMMAND
# Este es un simple comando que imprime una lista de todos los comandos disponibles en la consola y una breve descripcion de su funcionamiento
#
function command_help(){
    echo "- help : Imprime un listado de todos los comandos disponibles."
    echo "- exit : Cierra de la interfaz."
    echo "- users : Lista los usuarios registrados."
    echo "- newuser : Permite crear un usuario nuevo."
    echo "- inicial : cepta una letra que define la variable INITIAL que utiliza el comando findreg."
    echo "- contiene : cepta una letra que define la variable CONTAINED que utiliza el comando findreg."
    echo "- final : Acepta una letra que define la variable FINAL que utiliza el comando findreg."
    echo "- findreg : Una simple busqueda en el diccionario español a partir de parametros configurables. Busca todas las palabras que empiecen con INITIAL, contengan CONTAINED y terminen con FINAL. Si alguna de estas queda sin definir, aceptara cualquier letra."
    echo "- vocal : cepta una letra que define la variable VOCAL que utiliza el comando findvocal."
    echo "- findvocal : Una simple busqueda en el diccionario español a partir de parametros configurables. Busca todas las palabras que contengan la vocal VOCAL y ninguna otra."
    echo "- promedio : Calcula el promedio entre una cantidad arbitraria de numeros. Tambien indica cual fue el mayor y el menor de ellos"
    echo "- capicua : Determina si una palabra ingresada es capicua o no."
}
#
# USERS COMMAND
# Imprime los usuarios que hay. El for itera por cada linea del archivo users.txt
# El cut lo que hace es cortar la linea en el ":" para que no imprima la contrasena.
#
function command_users(){
    for i in `cat $USERSFILE`
    do
        echo $i | cut -d ":" -f 1
    done
}
#
# NEW USER COMMAND
# Un comando que anade un usuario nuevo.
#
function command_newuser(){
    echo "Ingrese el nombre para el nuevo usuario:"
    LOOP3=1
    NEWUSR=""
    NEWPWD=""
    #La funcion de este while es poder volver a preguntar cuando algun dato es incorrecto
    while [ $LOOP3 -eq 1 ]
    do
        read user
        USERTAKEN=0
        #Se chequea en la lista de todos los usuarios para comparar si el usuario ingresado ya existe.
        #Si es asi, se es asi el flag USERTAKEN sera 1 y por lo tanto se volvera a preguntar.
        #Esto continua hasta que el usuario ingreso un nombre de usuario valido.
        for u in $(command_users)
        do
            if [ $user = $u ]
            then
                echo "Ese usuario ya existe, por favor ingrese otro nombre de usuario."
                USERTAKEN=1
                break
            fi
        done
        if [ $USERTAKEN -eq 0 ]
        then
            NEWUSR=$user
            LOOP3=0
        fi
    done

    #Al igual que con user, se usa un for para que se siga preguntando hasta obtener una respuesta valida
    LOOP4=1
    while [ $LOOP4 -eq 1 ]
    do
        echo "Ingrese la contraseña para el nuevo usuario"
        read -s password
        echo "Confirme la contraseña"
        read -s password2
        #Se verifica la contrasena con un doble ingreso, si son distintas se volvera a preguntar.
        if [ $password = $password2 ]
        then
            NEWPWD=$password
            LOOP4=0
        else
            echo "Las contraseñas no coinciden. Intentelo de nuevo"
        fi
    done
    
    echo "$NEWUSR:$NEWPWD" >> $USERSFILE
}

#Los siguientes 3 comandos sirven para ingresar la letra inicial, letra contenida y letra final respectivamente.
#El -n1 en el read cumple la funcion de aceptar una sola letra.

#
# INITIAL LETTER COMMAND
#
INITIAL_LETTER=''
#
# CONTAINED LETTER COMMAND
#
CONTAINED_LETTER=''
function command_contained(){
    echo "ingrese letra contenida"
    read -n1 contained_letter
    echo ""
    CONTAINED_LETTER=$contained_letter
}
#
# FINAL LETTER COMMAND
#
function command_final(){
    echo "ingrese letra final"
    read -n1 final_letter
    echo ""
    FINAL_LETTER=$final_letter
}
#
# FIND COMMAND
# Utilizando las letras configuradas en los comandos anteriores, se realiza una busqueda en el diccionario que cumpla con
# Las condiciones preestablecidas.
# El regex utilizado es "^I.*C.*F$" Donde I es la letra inicial, C es la letra contenida y F es la letra final.
# El resultado de hacerlo de esta forma es que si alguna de estas letras no fue definida (la variable esta vacia)
# La busqueda seguira funcionando, aceptando cualquier letra en la respectiva ubicacion.
#
DICTIONARY_FILE="${0%/*}/diccionario.txt"
FIND_RESULT_FILE="${0%/*}/find_result.txt"
function command_find_regex(){
    REGEX="^$INITIAL_LETTER.*$CONTAINED_LETTER.*$FINAL_LETTER$"

    echo "initial: $INITIAL_LETTER"
    echo "contained: $CONTAINED_LETTER"
    echo "final: $FINAL_LETTER"
    echo "-=-=-=-=-=-=-=- Analizando..."
    # Grep analiza cada linea del archivo diccionario.txt comparandola con la expresion regular que definimos arriba.
    FIND_RESULT=`grep $REGEX $DICTIONARY_FILE`
    
    # El comando wc cuenta cuantas lineas hay en el input. Lo utilizamos para calcular cuantos resultados hay y 
    # cuantas palabras habian en el diccionario. Luego con estos valores obtenemos el porcentaje.
    # El grep sirve para ignorar las lineas vacias, basicamente excluye cualquier linea que cumpla com "^$" (inicia y termina, o sea vacia)
    RESULT_COUNT=`echo "$FIND_RESULT" | grep -v ^$ | wc -l`
    TOTAL_COUNT=`cat $DICTIONARY_FILE | grep -v ^$ | wc -l`
    # Para manejar floats usamos printf (respuesta obtenida de stack overflow)
    # El %.4f formatea el numero en un float con 4 digitos despues de la coma. 
    # Multiplicamos por un numero muy grande para obtener mayor presicion, que luego se normaliza con el e-2
    printf -v PERCENT '%.2f' "$((10000 * $RESULT_COUNT / $TOTAL_COUNT))e-2"
    # Se inserta la infomacion en el archivo find_result.txt usando >>. El primero es > para que sobreescriba el archivo.
    date > $FIND_RESULT_FILE
    echo "Palabras encontradas: $RESULT_COUNT" >> $FIND_RESULT_FILE
    echo "$PERCENT% del total $TOTAL_COUNT" >> $FIND_RESULT_FILE
    echo "Busqueda realizada por usuario $CURRUSR" >> $FIND_RESULT_FILE
    echo "Resultado:"
    echo "$FIND_RESULT" >> $FIND_RESULT_FILE  #guarda el resultado de grep en find_result
    echo "$FIND_RESULT"                        #imprime find_result en la consola
    echo "Resultado guardado en $FIND_RESULT_FILE"
    echo "Expresion regular usada: \"$REGEX\""

}

#Funcion auxiliar para guardar la forma con tilde de las vocales. Esto es necesario ya que el diccionario incluye letras con tildes
#Y los caracteres tecnicamente son simbolos distintos.
VOWEL=''
TILDEVOWEL=''
function set_tilde_variant(){
    if [ "$VOWEL" == "a" ]
    then
        TILDEVOWEL="á"
    elif [ "$VOWEL" == "e" ]
    then
        TILDEVOWEL="é"
    elif [ "$VOWEL" == "i" ]
    then
        TILDEVOWEL="í"
    elif [ "$VOWEL" == "o" ]
    then
        TILDEVOWEL="ó"
    elif [ "$VOWEL" == "u" ]
    then
        TILDEVOWEL="ú"
    fi
}

#
# VOWEL COMMAND
# Este comando funciona igual que initial, contained y final, pero guarda la vocal para el comando findvocal
# El -n1 en el read cumple la funcion de aceptar una sola letra.
#
function command_vowel(){
    LOOP5=1
    while [ $LOOP5 -eq 1 ]
    do
        echo "ingrese vocal"
        read -n1 vowel
        echo ""
        #Se verifica la letra ingresada sea una vocal
        if echo "$vowel" | grep -q "^[aeiou]$"
        then
            VOWEL=$vowel
            set_tilde_variant
            LOOP5=0
        else
            echo "La letra ingresada no es una vocal. Intentelo de nuevo"
        fi
    done
    
}

#
# FIND VOWEL COMMAND
# Este comando lista solo las palabras que contienen la vocal seleccionada y ningun otra vocal
#
DICTIONARY_FILE="${0%/*}/diccionario.txt"
FIND_RESULT_FILE="${0%/*}/find_result.txt"
function command_find_regex2(){
    if [ ! $VOWEL == "" ]
    then
        ALLVOWELS="aeiouáéíóú"
        RMTILDE="${ALLVOWELS//$TILDEVOWEL}"
        NOTVOWELS="${RMTILDE//$VOWEL}"
        REGEX2="^[^$NOTVOWELS]*[$VOWEL$TILDEVOWEL][^$NOTVOWELS]*$"
        echo "vocal: $VOWEL"
        echo $REGEX2
        echo "-=-=-=-=-=-=-=- Analizando..."
        echo `grep $REGEX2 $DICTIONARY_FILE`
    else
        echo "Por favor primero ingrese una vocal usando el comando 'vocal'."
    fi
    
}

# Función auxiliar para invertir una palabra utilizada por el comando capicua
function invertir() {
    palabra="$1"
    nueva=""
    for (( i=${#palabra}-1; i>=0; i-- )); do
        nueva="${nueva}${palabra:$i:1}"
    done
    echo "$nueva"
}
#
# CAPICUA COMMAND
# Determina si una letra es capicua o no
#
function command_capicua() {
    echo "ingrese una palabra cualquiera"
    read palabra
    palabra_invertida=$(invertir "$palabra")
    if [ "$palabra" == "$palabra_invertida" ]; then
        echo "La palabra $palabra es capicua!"
    else
        echo "La palabra $palabra no es capicua"
    fi
}

#
# AVERAGE COMMAND
# Calcula el promedio entre varios numeros y ademas guarda el maximo y el minimo de ellos.
#
function command_average() {
    echo "cuantos numeros desea ingresar?"
    read count
    if [ $count -eq 0 ]; then
        echo "Debe ingresar un numero mayor a 0"
    else
        sum=0
        mayor=""
        menor=""
        for (( i=0; i<${count}; i++ )); do
            echo "Ingrese un numero. $(($count-$i)) faltantes"
            read num
            #Comparamos para ver si el numero es mas grande o mas chico que el que tenemos guardado, asi obtenemos el menor y mayor
            if [ "$mayor" == "" ] || [ $num -gt $mayor ]; then
                mayor=$num
            fi
            if [ "$menor" == "" ] || [ $num -lt $menor ]; then
                menor=$num
            fi
            sum=$(($sum + $num))
        done
        #Utilizamos printf en lugar de echo porque puede lidiar con imprimir numeros con coma
        printf 'Promedio: %.2f\n' "$((100 * $sum / $count))e-2"
        echo "Mayor: $mayor"
        echo "Menor: $menor"
    fi
}

#
# COMMAND INTERFACE LOGIC
#
echo "Bienvenido $CURRUSR a la interfaz de CCALM (Con CCALM Aprobamos La Materia)"
echo "Escriba 'help' para obtener una lista de comandos."
LOOP2=1
while [ $LOOP2 -eq 1 ]
do
    echo -n "~>"
    read comando

    if [ "$comando" = "help" ]
    then
        command_help
    elif [ "$comando" = "users" ]
    then
        command_users
    elif [ "$comando" = "newuser" ]
    then
        command_newuser
    elif [ "$comando" = "inicial" ]
    then
        command_initial
    elif [ "$comando" = "final" ]
    then
        command_final
    elif [ "$comando" = "contiene" ]
    then
        command_contained
    elif [ "$comando" = "findreg" ]
    then
        command_find_regex
    elif [ "$comando" = "vocal" ]
    then
        command_vowel
    elif [ "$comando" = "findvocal" ]
    then
        command_find_regex2
    elif [ "$comando" = "promedio" ]
    then
        command_average
    elif [ "$comando" = "capicua" ]
    then
        command_capicua
    elif [ "$comando" = "exit" ]
    then
        LOOP2=0
        echo "Que tenga un buen dia :)"
    else
        echo "Comando no reconocido, escriba 'help' para obtener una lista de comandos."
    fi

done
