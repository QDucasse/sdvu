-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Read-only memory where program instructions are stored.

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.textio.all;

library work;
use work.sdvu_constants.all;

-- =================
--      Entity
-- =================

entity program_memory is
    port (I_clock   : in STD_LOGIC; -- Clock
          I_reset   : in STD_LOGIC; -- Reset
          I_enable  : in STD_LOGIC; -- Enable

          I_PC    : in STD_LOGIC_VECTOR (PC_SIZE-1 downto 0)     := (others => '0'); -- Address of the new instruction
          O_data  : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0) := (others => '0')  -- Data at address
          );
end program_memory;

-- =================
--   Architecture
-- =================

architecture arch_program_memory of program_memory is
    type memory_file is array (0 to 2**PROG_MEM_SIZE-1) of STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);  -- 128 32-bit addresses

    -- Functions
    impure function init_prg_mem return memory_file is
      file text_file : text open read_mode is "cfg/prg_mem.ini";
      variable text_line : line;
      variable memory_content : memory_file;
      variable file_ended : boolean := false;
    begin
      for i in 0 to 2**PROG_MEM_SIZE-1 loop
        if endfile(text_file) then
          memory_content(i) := X"00000000";
        else
          readline(text_file, text_line);
          hread(text_line, memory_content(i));
        end if;
      end loop;
      return memory_content;
    end function;

    -- Internal objects
    signal memory_bank: memory_file := init_prg_mem; -- Affectation of the array and initialization at 0

begin
  -- Processes
  TransferData: process(I_clock) -- I_clock added to the sensitivity list of the process
  begin

      if rising_edge(I_clock) then  -- If new cycle
        if I_reset = '1' then     -- Reset
          memory_bank <= (others => X"00000000");
        elsif I_enable = '1' then
          -- Read from the address to the output
          O_data <= memory_bank(to_integer(unsigned(I_PC(7 downto 0))));
        end if;
    end if;
  end process;
end arch_program_memory;
