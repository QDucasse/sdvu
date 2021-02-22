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

entity fsm is
    port (I_clk   : in  STD_LOGIC;                      -- Clock signal
          I_reset : in  STD_LOGIC;                      -- Reset signal
          O_state : out STD_LOGIC_VECTOR (1 downto 0)   -- State of the control unit
          );
end fsm;

-- =================
--   Architecture
-- =================

architecture arch_fsm of fsm is
    -- Internal Objects
    signal current_state : STD_LOGIC_VECTOR(1 downto 0) := FSM_DECODE;
begin
    -- Processes
    StateIncrement: process(I_clk) -- I_clk added to the sensitivity list of the process
    begin
        if rising_edge(I_clk) then
          if I_reset = '1' then
            current_state <= FSM_DECODE;
          else
            -- Pipeline: Decode - Reg Read - ALU - Reg Write - Decode - ...
            case current_state is
              when FSM_DECODE =>
                current_state <= FSM_REGREAD;
              when FSM_REGREAD =>
                current_state <= FSM_ALU;
              when FSM_ALU =>
                current_state <= FSM_REGWRITE;
              when FSM_REGWRITE =>
                current_state <= FSM_DECODE;
              when others =>
                current_state <= FSM_DECODE;
            end case;
          end if;
        end if;
    end process;
    O_state <= current_state;
end arch_fsm;
