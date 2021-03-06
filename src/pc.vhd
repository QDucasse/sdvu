-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Program Counter unit, it can either:
--        - Increment the program counter
--        - Change the value of the program counter
--        - Do nothing (halt)
--        - Set the program counter to the reset vector (0x0000)

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

entity pc is
    port (I_clock     : in  STD_LOGIC; -- Clock
          I_reset     : in  STD_LOGIC; -- Reset
          I_enable    : in  STD_LOGIC; -- Unit
          -- Inputs
          I_newPC     : in STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);     -- Incoming Program Counter to assign
          I_PC_OPCode : in  STD_LOGIC_VECTOR (PC_OP_SIZE-1 downto 0); -- Type of operation that needs to be performed
          -- Outputs
          O_PC        : out STD_LOGIC_VECTOR (PC_SIZE-1 downto 0)     -- Output Program Counter
          );
end pc;


-- =================
--   Architecture
-- =================

architecture arch_pc of pc is
  -- Internal Objects
  -- Internal vector to keep the current PC to work on
  signal current_pc : STD_LOGIC_VECTOR(PC_SIZE-1 downto 0) := (others => '0');

begin
  -- Processes
  ProcessOperation: process (I_clock, I_reset)

  begin
    -- Process operation on PC
    if rising_edge(I_clock) then
      -- Reset routine
      if I_reset = '1' then
        current_pc <= (others => '0');
      elsif I_enable = '1' then
        case I_PC_OPCode is
          when PC_OP_NOP =>    -- NOP | Nothing to do, keep PC the same / halt
          when PC_OP_INC =>    -- INC | Increment the PC
            current_pc <= std_logic_vector(unsigned(current_pc) + 1);
          when PC_OP_ASSIGN => -- ASSIGN | Set the PC from an external input
            current_pc <= I_newPC; -- Input PC to assign
          when PC_OP_RESET =>  -- RESET | Set the PC to X"0000"
            current_pc <= (others => '0');
          when others =>
            -- unreachable
        end case;
      end if;
    end if;
  end process;

  -- Propagate the internal PC to the output
  O_PC <= current_pc;

end arch_pc;
