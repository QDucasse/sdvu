-- Project Structure from TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Simple control unit with different states
--    Decode
--    Reg Read
--    ALU
--    Reg Write

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

entity control_unit is
    generic (OP_SIZE      : natural := 4;
             STATE_NUMBER : natural := 12);
    port (I_clock   : in  STD_LOGIC;                                 -- Clock signal
          I_reset   : in  STD_LOGIC;                                 -- Reset signal
          -- Inputs
          I_op_code : in STD_LOGIC_VECTOR(OP_SIZE-1 downto 0);       -- Instruction Op Code
          -- Outputs
          O_state   : out STD_LOGIC_VECTOR (STATE_NUMBER-1 downto 0) -- State of the control unit
          );
end control_unit;

-- =================
--   Architecture
-- =================

architecture arch_control_unit of control_unit is
    -- Internal Objects
    signal current_state : STD_LOGIC_VECTOR(1 downto 0) := CONTROL_UNIT_DECODE;
begin
    -- Processes
    NextState: process(I_clock) -- I_clock added to the sensitivity list of the process
    begin
        if rising_edge(I_clock) then
          if I_reset = '1' then
            current_state <= CONTROL_UNIT_DECODE;
          else
            -- Pipeline: Decode - Reg Read - ALU - Reg Write - Decode - ...
            case current_state is
              when CONTROL_UNIT_DECODE =>
                current_state <= CONTROL_UNIT_REGREAD;
              when CONTROL_UNIT_REGREAD =>
                current_state <= CONTROL_UNIT_ALU;
              when CONTROL_UNIT_ALU =>
                current_state <= CONTROL_UNIT_REGWRITE;
              when CONTROL_UNIT_REGWRITE =>
                current_state <= CONTROL_UNIT_DECODE;
              when others =>
                current_state <= CONTROL_UNIT_DECODE;
            end case;
          end if;
        end if;
    end process;
    O_state <= current_state;
end arch_control_unit;
