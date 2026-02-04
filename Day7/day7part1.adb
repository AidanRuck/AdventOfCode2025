with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

procedure Day7part1 is
   package LineVec is new Ada.Containers.Vectors
     (Index_Type => Positive,
      Element_Type => Unbounded_String);

   -- Vector type to store each line of the input

   Lines : LineVec.Vector;
   -- This holds the lines of the input file

   Filename : Unbounded_String := To_Unbounded_String ("day7input.txt");

   type GridAccess is access all String;

   type GridArray is array (Positive range <>) of GridAccess;
   type GridArrayAccess is access GridArray;

   Grid : GridArrayAccess := null;
   Height : Natural := 0;
   Width : Natural := 0;

   StartRow : Natural := 0;
   StartColumn : Natural := 0;
   -- Starting position is S

   function Max (A, B : Natural) return Natural is
   begin
      if A > B then
         return A;
      else
         return B;
      end if;
   end Max;
   -- Helper function to get max of two numbers

begin
   if Argument_Count >= 1 then
      Filename := To_Unbounded_String (Argument (1));
   end if;
   -- Check filename from command line (just in case)

   -- This will read file line by line
   declare
      F : File_Type;
   begin
      Open (F, In_File, To_String (Filename));

      while not End_Of_File (F) loop
         declare
            -- Store one line at a time
            LineString : Unbounded_String := To_Unbounded_String ("");
            C : Character;
         begin
            while not End_Of_Line (F) loop
               Get (F, C);
               Append (LineString, C);
            end loop;
            -- Read until a newline character

            if not End_Of_File (F) then
               Skip_Line (F);
            end if;
            -- Skip said newline character

            Lines.Append (LineString);
            Width := Max (Width, Natural (Length (LineString)));
            -- Track the current widest line
         end;
      end loop;

      Close (F);

   exception
      when others =>
         Put_Line ("Error: could not open or read file: " & To_String (Filename));
         return;
   end;

   Height := Natural (Lines.Length);

   if Height = 0 or Width = 0 then
      Put_Line ("Error: empty input");
      return;
   end if;
   -- Find the grid size

   Grid := new GridArray (1 .. Height);
   for R in 1 .. Height loop
      Grid.all (R) := null;
   end loop;
   -- Build the grid and pad with a .

   for R in 1 .. Height loop
      declare
         S : constant String := To_String (Lines (R));
         RowString : String (1 .. Width);
      begin
         for C in 1 .. Width loop
            if C <= S'Length then
               RowString (C) := S (C);
            else
               RowString (C) := '.';
            end if;
         end loop;

         Grid.all (R) := new String'(RowString);
         -- Allocate memory for a row
      end;
   end loop;

   for R in 1 .. Height loop
      for C in 1 .. Width loop
         if Grid.all (R).all (C) = 'S' then
            StartRow := R;
            StartColumn := C;
         end if;
      end loop;
   end loop;

   if StartRow = 0 then
      Put_Line ("Error: could not find 'S' in the grid");
      return;
   end if;

   declare
   -- Simulate the beams
      type BoolArray is array (1 .. Width) of Boolean;

      Active : BoolArray := (others => False);
      -- Active will be if there is a beam in the column
      Splits : Long_Long_Integer := 0;
      -- This counts how many times a splitter (^) is hit
   begin
      Active (StartColumn) := True;

      for R in StartRow + 1 .. Height loop
      -- This will process a row downward
         loop
         -- Loop until no more splits on row
            declare
               DidSplit : Boolean := False;
            begin
               for C in 1 .. Width loop
                  if Active (C) and then Grid.all (R).all (C) = '^' then
                  -- When a beam hits a splitter
                     Active (C) := False;
                     -- Remove current beam

                     if C > 1 then
                     -- Create one to the left
                        Active (C - 1) := True;
                     end if;

                     if C < Width then
                        Active (C + 1) := True;
                        -- Create one to the right
                     end if;

                     Splits := Splits + 1;
                     DidSplit := True;
                     -- Flag that a split occurred
                  end if;
               end loop;

               exit when not DidSplit;
               -- Stop when no more splits on the row
            end;
         end loop;
      end loop;

      Put_Line ("Split Count = " & Long_Long_Integer'Image (Splits));
   end;
end Day7part1; 
