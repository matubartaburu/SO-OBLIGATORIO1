with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

procedure Tambo is

  task en_Ordene is
    entry entrar;
    entry salir;  -- Recursos compartidos.
  end en_Ordene;

  task body en_Ordene is
    En_Sala : Integer := 0;
  begin
   loop 
     select  
      when en_Sala < 15  =>
       accept entrar do
        en_Sala := en_Sala + 1; 
        end entrar; 
      or 
        accept salir do
          En_Sala := En_Sala - 1; 
        end salir; 
      end select; 
    end loop; 
  end en_Ordene;

  task en_Vacunacion is
    entry entrar;
    entry salir;
  end en_Vacunacion;

  task body en_Vacunacion is
    Vacunandose : Integer := 0;
  begin
    loop
      select
        when Vacunandose < 5
        =>accept entrar do
          Vacunandose := Vacunandose + 1;
        end entrar;
      or
        accept salir do
        Vacunandose := Vacunandose - 1; 
        end salir;
      end select;
    end loop;
  end en_Vacunacion;

  task Camion is
    entry ingresar;
  end Camion;

  Camion1, Camion2 : Camion;

  task body Camion is
    En_Camion : Integer := 0;
  begin
    loop
      select
        when En_Camion < 50
        =>accept ingresar do
          en_Camion := en_Camion + 1;
        end ingresar;
      or
        terminate;
      end select;
    end loop;
  end Camion;

  procedure Vacunacion (id : Integer) is
  Gen: Ada.Numerics.Float_Random.Generator;
begin
    en_Vacunacion.entrar; --pide acceder. 
     Put_Line("La vaca" & Integer'Image(ID) & " está entrando al área de vacunación");

    delay Duration(Ada.Numerics.Float_Random.Random(Gen) * 2.0); --tiempo random en ser vacunada.

    Put_Line("La vaca" & Integer'Image(ID) & " está saliendo del área de vacunación");

   en_Vacunacion.Salir;
end Vacunacion;


  procedure Ordenar (id : Integer) is
  Gen : Ada.Numerics.Float_Random.Generator; --la tengo que declarar cada vez que la uso. 
  begin
    en_Ordene.entrar; 
    Put_Line("La vaca" & Integer'Image(ID) & " está entrando al área de ordeñe");
    delay Duration(Ada.Numerics.Float_Random.Random(Gen) * 3.0);

    Put_Line("La vaca" & Integer'Image(ID) & " está saliendo del área de ordeñe");
    en_Ordene.salir; 
  end Ordenar;

  procedure subirCamion (id : Integer) is
  begin
   if id mod 2 = 0 then  --puede hacerse así ? o usamos gen? 
    Camion1.ingresar;
    Put_Line("La vaca" & Integer'Image(ID) & " está entrandó al camión 1");
   else 
    Camion2.ingresar; 
    Put_Line("La vaca" & Integer'Image(ID) & " está entrandó al camión 2"); 
   end if; 
end subirCamion;
     
  task type Vaca (id : Integer);
  task body Vaca is
   Gen : Ada.Numerics.Float_Random.Generator;
   R   : Float;
  begin
   Ada.Numerics.Float_Random.Reset(Gen);
   R := Ada.Numerics.Float_Random.Random(Gen);
   if R < 0.5 then  -- hacemos que varíen algunas el orden entre vacunarse y ordeñarse. 
   Ordenar (id); 
   Vacunacion (id); 
   else
    Vacunacion (id);
    Ordenar(id);
   
   end if; 

    SubirCamion (id); -- como viene despues del if me aseguro que sea despues de ambos. (letra)
  end Vaca;

  Vacas : array (1 .. 100) of Vaca := (others => <>);
begin

end Tambo;
