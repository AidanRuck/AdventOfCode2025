with Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

procedure Day7part2 is

   subtype CountType is Long_Long_Integer;
   -- 64-bit integer

   Filename : constant String := "day7input.txt";

   package LineVec is new Ada.Containers.Vectors
      (Index_Type   => Positive,
       Element_Type => Unbounded_String);

   Lines : LineVec.Vector;
   -- Store each row dynamically

   Height : Natural := 0;
   Width : Natural := 0;
   StartColumn : Natural := 0;
   StartRow : Natural := 0;

   function CharAt (Row : Positive; Col : Positive) return Character is
      S : constant String := To_String (Lines (Row));
   begin
      return S (Col);
   end CharAt;
   -- Helper to read character from grid

   procedure ReadInput is
      F : File_Type;
   begin
      Put_Line ("Opening file: " & Filename);
      Open (F, In_File, Filename);

      while not End_Of_File (F) loop
         declare
            Buffer : constant String := Get_Line (F);
         begin
            Height := Height + 1;

            if Height = 1 then
               Width := Buffer'Length;
            end if;

            Lines.Append (To_Unbounded_String (Buffer));
            -- Copy into stored row

            for c in Buffer'Range loop
               if Buffer (c) = 'S' then
                  StartRow := Height;
                  StartColumn := Natural (c);
               end if;
               -- Find S
            end loop;

         end;
      end loop;

      Close (F);

      Put_Line ("Read" & Natural'Image (Height) & " rows, Width=" & Natural'Image (Width));
   end ReadInput;

begin
   ReadInput;
   -- Takes the input file

   if StartRow = 0 then
      Put_Line ("No 'S' found");
      return;
   end if;

   declare
      -- Counts(column) will be the count of timelines
      type CountArray is array (Positive range <>) of CountType;

      Counts : CountArray (1..Width) := (others => 0);
      NextCounts : CountArray (1..Width) := (others => 0);
      Exited : CountType := 0;

   begin
      if StartRow + 1 <= Height then
         Counts (StartColumn) := 1;
         -- Particle should start one line below S
      else
         Put_Line ("1");
         -- If S is on the last row, it can exit
         return;
      end if;

      for r in (StartRow + 1)..Height loop
      -- Go row by row from start + 1 to height

         NextCounts := (others => 0);

         for c in 1..Width loop
            if Counts (c) /= 0 then

               if CharAt (Positive (r), Positive (c)) = '^' then

                  -- Split to left
                  if c = 1 then
                     Exited := Exited + Counts (c);
                  else
                     NextCounts (c - 1) :=
                        NextCounts (c - 1) + Counts (c);
                  end if;

                  -- Split right
                  if c = Width then
                     Exited := Exited + Counts (c);
                  else
                     NextCounts (c + 1) :=
                        NextCounts (c + 1) + Counts (c);
                  end if;

               else
                  -- When normal, keep going in same column
                  NextCounts (c) :=
                     NextCounts (c) + Counts (c);
               end if;

            end if;
         end loop;

         Counts := NextCounts;

      end loop;

      for c in 1..Width loop
         Exited := Exited + Counts (c);
      end loop;
      -- Anything still in Counts will fall off bottom

      Put_Line ("Count = " & CountType'Image (Exited));

   end;
end Day7part2;
