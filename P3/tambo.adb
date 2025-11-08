with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Tambo is

task en_Ordeñe is 
entry Entrar; 
entry Salir;  -- Recursos compartidos.
end en_Ordeñe;

task body en_Ordeñe is 
En_Sala : Integer := 0; 
begin

end en_Ordeñe; 

 

task en_Vacunacion is 
entry entrar; 
entry salir; 
end en_Vacunacion; 

task body en_Vacunacion is 
Vacunandose : Integer := 0; 
begin
   loop 
    select  
    when Vacunandose < 15 => accept entrar do 
    Vacunandose := Vacunandose + 1; 
end en_Vacunacion; 



task Camion is
 entry Entrar;  
 entry Salir; 
end Camion;
Camion1, Camion2: Camion


task body Camion is
 en_Camion : Integer:= 0
begin 
   loop 
     select
      when En_Camion < 50 => accept ingresar do 
    en_Camion := en_Camion + 1; 
  for I in 1.. 5 loop 
Camion.ingresar; 
    Put_Line("La vaca _id está entrando al camión");
  end Ingresar; 
    end select ; 
 end loop
end Camion


procedure Vacunacion(id: Integer) is 
begin 
  Area_Vacunacion.Entrar; 

end Vacunacion; 

procedure Ordeñar (id:Integer) is 
begin 
   en_Ordeñe.Entrar; 
for I in 1 .. 5 loop 
Put_Line("La vaca &id está entrando al area de ordeñe");
 end loop
end Ordeñar; 

procedure subirCamion(id: Integer) is
begin  
Camion.Entrar; 

end subirCamion; 

task type Vaca (id: Integer);
task body Vaca is 
begin 
   Ordeñar(id);
   Vacunacion(id);
   --CAMION? 
   SubirCamion(id); 


end Vaca; 

type Estado_Vaca is (En_Campo, En_Ordeñe, En_Vacunacion, En_Camion);
Vaca_Estado : array (1 .. 100) of Estado_Vaca;
Vacas : array (1..100) of Vaca := (others => <>); 

end Tambo; 