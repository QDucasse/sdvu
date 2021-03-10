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
             STATE_NUMBER : natural := 13);
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
    signal current_state : STD_LOGIC_VECTOR(STATE_NUMBER-1 downto 0) := STATE_RESET;
begin
    -- Combinational Logic


    -- Processes
    NextState: process(I_clock) -- I_clock added to the sensitivity list of the process
    begin
        if rising_edge(I_clock) then
          if I_reset = '1' then
            current_state <= STATE_RESET;
          else
            case current_state is
              -- DIRECT TRANSITION TO THE NEXT STATE
              when STATE_RESET =>
                current_state <= STATE_FETCH1;
              when STATE_FETCH1 =>
                current_state <= STATE_FETCH2;
              when STATE_FETCH2 =>
                current_state <= STATE_DECODE;
              -- SWITCH ON THE DECODE
              when STATE_DECODE =>
                case I_op_code is
                  when OP_STORE =>
                    current_state <= STATE_STORE;
                  when OP_LOAD =>
                    current_state <= STATE_LOAD;
                  when OP_JMP =>
                    current_state <= STATE_JMP;
                  when others =>
                    current_state <= STATE_BIN;
                end case;

              -- PROCESS STORE TRANSITIONS
              when STATE_STORE =>
                current_state <= STATE_READ_REG_STORE;
              when STATE_READ_REG_STORE =>
                current_state <= STATE_WRITE_MEM
                ;
              -- PROCESS LOAD TRANSITIONS
              when STATE_LOAD =>
                current_state <= STATE_READ_MEM;
              when STATE_READ_MEM =>
                current_state <= STATE_REG_WRITE;

              -- PROCESS JMP TRANSITIONS
              when STATE_JMP =>
                current_state <= FETCH1;

              -- PROCESS BIN/NOT TRANSITIONS
              when STATE_BIN =>
                current_state <= STATE_READ_REG_BIN;
              when STATE_READ_REG_BIN =>
                current_state <= STATE_WRITE_REG;

              when others =>
                current_state <= STATE_RESET;
            end case;
          end if;
        end if;
    end process;
    O_state <= current_state;
end arch_control_unit;
