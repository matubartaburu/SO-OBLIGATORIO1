#!/bin/bash

#=======================
# INVENTARIO-CITADEL - SO
#=======================

SESION_INICIADA=false
usuario_actual=""

if [ ! -f "usuarios.txt" ]; then 
  touch "usuarios.txt"   
fi

if ! grep -q "^admin:admin" "usuarios.txt"; then 
  echo "admin:admin" >> "usuarios.txt"; 
fi

crear_usuario() {
    echo "===CREAR USUARIO==="
    read -p "Ingrese usuario: " user 

    if  grep -q "^$user:" "usuarios.txt"; then
        echo " Usuario ya registrado" 
        return 
    fi

    while true; do 
        read -s -p "Ingrese contrasena: " contrasena
        if [ -z "$contrasena" ]; then
            echo "La contrasena no puede estar vacia!" 
        else 
          break
        fi 
    done  

    echo "$user:$contrasena" >> usuarios.txt
    echo ""
    echo "Usuario agregado correctamente."
}

cambiar_contrasena() {
    if  ! $SESION_INICIADA; then
        read -p "Ingrese su usuario:  " user
    else
        user=$usuario_actual
    fi
    read -s -p "Ingrese su contrasena actual: " password

    if grep -q "^$user:$password$" usuarios.txt; then
        echo ""
        while true; do 
            read -s -p "Ingrese su nueva contrasena: " contrasena
            if [ -z "$contrasena" ]; then
                echo "La contrasena no puede estar vacia!" 
            else 
                break
            fi 
        done
        sed -i "s/^$user:$password$/$user:$contrasena/" usuarios.txt
        echo "Contraseña actualizada con éxito."
    else 
        echo "Nombre y/o contraseña no coinciden!" 
    fi 
}

login(){
    if $SESION_INICIADA; then
        echo "Ya hay una sesión iniciada. ($usuario_actual)"
        return
    fi
    echo "Ingrese sus datos" 
    read -p "Usuario:  " user
    read -s -p "Contrasena: " password

    if grep -q "^$user:$password$" usuarios.txt; then
        echo ""
        echo "Bienvenido $user"
        SESION_INICIADA=true
        usuario_actual=$user
    else 
        echo "Nombre y/o contraseña no coinciden!" 
    fi 
}

logout(){
    SESION_INICIADA=false
    usuario_actual=""
    echo "Sesión cerrada."
}

ingresar_producto(){
    if ! $SESION_INICIADA; then
        echo "Debe iniciar sesión para ingresar productos."
        return
    fi

    read -p "Ingrese el tipo del producto: " tipo
    read -p "Ingrese el modelo: " modelo
    read -p "Ingrese la descripcion: " descripcion
    while true; do
        read -p "Ingrese la cantidad: " cantidad
        [[ "$cantidad" =~ ^[0-9]+$ ]] && break
        echo "Cantidad inválida."
    done
    while true; do
        read -p "Ingrese el precio: " precio
        [[ "$precio" =~ ^[0-9]+$ ]] && break
        echo "Precio inválido."
    done

    codigo=$(echo "$tipo" | cut -c1-3 | tr '[:lower:]' '[:upper:]')

    echo "$codigo - $tipo - $modelo - $descripcion - $cantidad - $precio" >> productos.txt
    echo "Producto ingresado correctamente."
}

vender_producto(){
    if ! $SESION_INICIADA; then
        echo "Debe iniciar sesión para vender productos."
        return
    fi
    [ -s "productos.txt" ] || { echo "No hay productos cargados."; return; }

    while true; do
        echo "=== LISTA DE PRODUCTOS ==="
        echo "0 - Salir"
        cont=1
        while IFS=' - ' read -r codigo tipo modelo descripcion stock precio; do
            [ -z "$codigo" ] && continue
            stock=$(echo "$stock" | xargs)
            precio=$(echo "$precio" | xargs)
            echo "$cont - $tipo - $modelo - $precio"
            cont=$((cont + 1))
        done < "productos.txt"

        read -p "Seleccione el producto: " prod
        [[ "$prod" =~ ^[0-9]+$ ]] || { echo "Número inválido."; continue; }
        if (( prod == 0 )); then
            echo "Saliendo..."
            return
        fi

        # Verificar que exista esa línea
        linea=$(sed -n "${prod}p" "productos.txt")
        if [ -z "$linea" ]; then
            echo "Producto no encontrado."
            continue
        fi
        IFS=' - ' read -r codigo tipo modelo descripcion stock precio <<< "$linea"
        stock=$(echo "$stock" | xargs)
        precio=$(echo "$precio" | xargs)

        read -p "Ingrese la cantidad: " cantidad
        [[ "$cantidad" =~ ^[0-9]+$ ]] || { echo "Cantidad inválida."; continue; }
        if (( cantidad <= 0 )); then
            echo "La cantidad debe ser mayor que 0."
            continue
        fi
        if (( cantidad > stock )); then
            echo "No hay suficiente stock (disponible: $stock)."
            continue
        fi

        nuevo_stock=$((stock - cantidad))

        sed -i "${prod}d" "productos.txt"
        if (( nuevo_stock > 0 )); then
            echo "$codigo - $tipo - $modelo - $descripcion - $nuevo_stock - $precio" >> "productos.txt"
        else
            echo "Producto agotado."
        fi

        total=$((precio * cantidad))
        echo "$tipo - $modelo - $cantidad unidades - Total: \$ $total"
        echo
    done
}

filtrar_productos(){
    if ! $SESION_INICIADA; then
        echo "Debe iniciar sesión para filtrar productos."
        return
    fi
    read -p "Ingrese tipo a filtrar: " filtro
    echo "=== RESULTADO ==="
    if [ -z "$filtro" ]; then
        cat "productos.txt"
    else
        awk -v IGNORECASE=1 -v f="$filtro" -F ' - ' '
            NF>=6 && $2 ~ f { print $0 }
        ' "productos.txt" | sed '/^$/d' || true
    fi
}


crear_reporte(){
    if ! $SESION_INICIADA; then
        echo "Debe iniciar sesión para crear un reporte."
        return
    fi
    mkdir -p Datos
    out="Datos/datos.CSV"
    {
      echo "Codigo,Tipo,Modelo,Descripcion,Cantidad,Precio"
      sed 's/ - /,/g' "productos.txt"
    } > "$out"
    echo "Reporte generado en $out"
}


while true; do

 echo "===MENÚ INVENTARIO===" 
 echo "1. Crear Usuario" 
 echo "2. Cambiar Contraseña" 
 echo "3. Login"
 echo "4. Logout" 
 echo "5. Ingresar Producto" 
 echo "6. Vender Producto" 
 echo "7. Filtrar Producto" 
 echo "8. Crear Reporte" 
 echo "9. Salir" 

 echo -n "Seleccione una Opción : " 
 read opcion


case $opcion in
   1) crear_usuario;; 
   2) cambiar_contrasena;;
   3) login;; 
   4) logout;; 
   5) ingresar_producto;;
   6) vender_producto;; 
   7) filtrar_productos;;
   8) crear_reporte;; 
   9) echo "saliendo..."; exit;;
   *) echo "opción incorrecta" ;;  
  esac 

done