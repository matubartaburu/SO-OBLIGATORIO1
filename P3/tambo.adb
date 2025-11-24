with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

procedure Tambo is

   -- números random
   package Rand_Bool is new Ada.Numerics.Discrete_Random (Boolean); -- si se ordeña o se vacuna primero
   Gen_Bool  : Rand_Bool.Generator;
   Gen_Float : Generator;

   function Random_Up_To (Max_Sec : Integer) return Duration is
   begin
      return Duration (Random (Gen_Float)) * Duration (Max_Sec);
   end Random_Up_To;


   -- semáforo mutex (binario)
   task Pasillo is
      entry entrar;
      entry salir;
   end Pasillo;

   task body Pasillo is
      ocupado : Boolean := False;
   begin
      loop
         select
            when not ocupado =>
               accept entrar do
                  ocupado := True;
               end entrar;
         or
               accept salir do
                  ocupado := False;
               end salir;
         end select;
      end loop;
   end Pasillo;

   -- semáforo capacidad 0...5
   task Capacidad_Vac is
      entry entrar;
      entry salir;
      entry cantV (C : out Integer);
   end Capacidad_Vac;

   task body Capacidad_Vac is
      cant : Integer := 0;
   begin
      loop
         select
            when cant < 5 =>
               accept entrar do
                  cant := cant + 1;
               end entrar;
         or
               accept salir do
                  cant := cant - 1;
               end salir;
         or
               accept cantV (C : out Integer) do
                  C := cant;
               end cantV;
         end select;
      end loop;
   end Capacidad_Vac;

   
   task en_Vacunacion is
      entry entrar (Id : Integer);
      entry salir  (Id : Integer);
      entry cantV (C : out Integer);
   end en_Vacunacion;

   task body en_Vacunacion is
      cant : Integer := 0;
   begin
      loop
         select
            accept entrar (Id : Integer) do
               cant := cant + 1;
               Put_Line ("La vaca " & Integer'Image (Id) & " está entrando al área de vacunación");
            end entrar;
         or
            accept salir (Id : Integer) do
               cant := cant - 1;
               Put_Line ("La vaca " & Integer'Image (Id) & " está saliendo al área de vacunación");
            end salir;
         or
            accept cantV (C : out Integer) do
               C := cant;
            end cantV;
         end select;
      end loop;
   end en_Vacunacion;

      
   task en_Ordene is
      entry entrar (Id : Integer);
      entry salir  (Id : Integer);
   end en_Ordene;

   task body en_Ordene is
      cant : Integer := 0;
   begin
      loop
         select
            when cant < 15 =>
               accept entrar (Id : Integer) do
                  cant := cant + 1;
                  Put_Line ("La vaca " & Integer'Image (Id) & " está entrando al área de ordeñe");
               end entrar;
         or
            accept salir (Id : Integer) do
               cant := cant - 1;
               Put_Line ("La vaca " & Integer'Image (Id) & " está saliendo al área de ordeñe");
            end salir;
         end select;
      end loop;
   end en_Ordene;


   task type Camion is
      entry ingresar (Id : Integer; Numero : Integer);
   end Camion;

   Camion1, Camion2 : Camion;

   task body Camion is
      cant : Integer := 0;
   begin
      loop
         accept ingresar (Id : Integer; Numero : Integer) do
            if cant < 50 then
               cant := cant + 1;
               Put_Line ("La vaca " & Integer'Image (Id) & " está entrando al Camión " & Integer'Image (Numero));
            end if;
         end ingresar;
      end loop;
   end Camion;

   task Selector_Camion is
      entry elegir (Cual : out Integer);
      entry estaLleno (L : out Boolean);
   end Selector_Camion;

   task body Selector_Camion is
      c1, c2 : Integer := 0;
   begin
      loop
         select
            when (c1 < 50 or else c2 < 50) =>
               accept elegir (Cual : out Integer) do
                  if c1 < 50 then
                     Cual := 1; c1 := c1 + 1;
                  else
                     Cual := 2; c2 := c2 + 1;
                  end if;
               end elegir;
         or
               accept estaLleno (L : out Boolean) do
                  L := (c1 = 50) and then (c2 = 50);
               end estaLleno;
         end select;
      end loop;
   end Selector_Camion;


   procedure darVacuna (Id : Integer) is
   begin
      Capacidad_Vac.entrar;

      Pasillo.entrar;
      en_Vacunacion.entrar (Id);
      Pasillo.salir;

      delay Random_Up_To (2);

      Pasillo.entrar;
      en_Vacunacion.salir (Id);
      Pasillo.salir;

      Capacidad_Vac.salir;
   end darVacuna;

   procedure Ordeniar (Id : Integer) is
   begin
      en_Ordene.entrar (Id);
      delay Random_Up_To (3);
      en_Ordene.salir (Id);
   end Ordeniar;

   procedure Subir_Camion (Id : Integer) is
      Cual : Integer;
   begin
      Selector_Camion.elegir (Cual);
      if Cual = 1 then
         Camion1.ingresar (Id, 1);
      else
         Camion2.ingresar (Id, 2);
      end if;
   end Subir_Camion;

   task type Vaca (Id : Integer);

   task body Vaca is
      Primero_Ordene : constant Boolean := Rand_Bool.Random (Gen_Bool); -- si se ordeña primero o no para cada vaca
   begin
      if Primero_Ordene then
         Ordeniar (Id);
         darVacuna (Id);
      else
         darVacuna (Id);
         Ordeniar (Id);
      end if;
      Subir_Camion (Id);
   end Vaca;

   type Vaca_Ref is access Vaca;
   Vacas : array (1 .. 100) of Vaca_Ref; -- punteros a los task Vaca


begin
   Rand_Bool.Reset (Gen_Bool);
   Reset (Gen_Float);

   for I in 1 .. 100 loop
      Vacas (I) := new Vaca (I);
   end loop;

   declare
      Lleno : Boolean := False;
   begin
      loop
         Selector_Camion.estaLleno (Lleno);
         exit when Lleno;
         delay 0.2;
      end loop;
   end;

   Put_Line ("Camiones completos.");

end Tambo;