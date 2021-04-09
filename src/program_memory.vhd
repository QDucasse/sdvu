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
    port (I_clock    : in STD_LOGIC; -- Clock
          I_enable   : in STD_LOGIC; -- Enable
          I_init_bin : in STD_LOGIC; -- Initialize prg mem

          I_binary : in prog_memory; -- The program binary to load in memory
          I_PC     : in STD_LOGIC_VECTOR (PC_SIZE-1 downto 0)     := (others => '0'); -- Address of the new instruction
          O_data   : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0) := (others => '0')  -- Data at address
          );
end program_memory;

-- =================
--   Architecture
-- =================

architecture arch_program_memory of program_memory is
    -- Internal objects
    signal memory_content: prog_memory;
begin
  -- Processes
  TransferData: process(I_clock) -- I_clock added to the sensitivity list of the process
  begin

      if rising_edge(I_clock) then  -- If new cycle
        if I_init_bin = '1' then       -- Initialization
          memory_content <= I_binary;
        elsif I_enable = '1' then
          -- Read from the address to the output
          O_data <= memory_content(to_integer(unsigned(I_PC(7 downto 0))));
        end if;
    end if;
  end process;
end arch_program_memory;
