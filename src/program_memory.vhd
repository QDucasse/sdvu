-- Project Structure from TPU Blogpost series by @domipheus
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

library work;
use work.sdvu_constants.all;

-- =================
--      Entity
-- =================

entity program_memory is
    port (I_clock   : in STD_LOGIC; -- Clock
          I_reset   : in STD_LOGIC; -- Reset
          I_enable  : in STD_LOGIC; -- Enable

          I_address : in STD_LOGIC_VECTOR (PROG_MEM_SIZE-1 downto 0); -- Address of the new instruction
          O_data  : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0) -- Data at address
          );
end program_memory;

-- =================
--   Architecture
-- =================

architecture arch_program_memory of program_memory is
    -- Internal Objects
    type memory_file is array (0 to 2**PROG_MEM_SIZE-1) of STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);  -- 128 32-bit addresses
    signal memory_bank: memory_file := (others => X"00000000"); -- Affectation of the array and initialization at 0

begin
  -- Processes
  TransferData: process(I_clock) -- I_clock added to the sensitivity list of the process
  begin
      if rising_edge(I_clock) then  -- If new cycle
        if I_reset = '1' then     -- Reset
          memory_bank <= (others => X"00000000");
        else
          -- Read from the address to the output
          O_data <= memory_bank(to_integer(unsigned(I_address)));
        end if;
    end if;
  end process;
end arch_program_memory;
