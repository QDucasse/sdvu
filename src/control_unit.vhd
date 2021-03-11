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
    port (I_clock   : in  STD_LOGIC;                                 -- Clock signal
          I_reset   : in  STD_LOGIC;                                 -- Reset signal
          -- Inputs
          I_op_code : in STD_LOGIC_VECTOR(OP_SIZE-1 downto 0);       -- Instruction Op Code
          -- Outputs
          O_state   : out STD_LOGIC_VECTOR (STATE_NUMBER-1 downto 0) -- State of the control unit

          -- -- Enable signals based on the state
          -- O_enable_ALU     : STD_LOGIC;
          -- O_enable_CFG_MEM : STD_LOGIC;
          -- O_enable_DECODER : STD_LOGIC;
          -- O_enable_PC      : STD_LOGIC;
          -- O_enable_PRG_MEM : STD_LOGIC;
          -- O_enable_REG     : STD_LOGIC;
          -- -- Config Memory signals
          -- O_CFG_MEM_type    :
          -- O_CFG_MEM_we      :
          -- O_CFG_MEM_address :
          -- O_CFG_MEM_data    :
          -- I_CFG_MEM_data    :
          -- -- Program Memory signals
          -- O_PRG_MEM_address :
          -- I_PRG_MEM_data    :
          );
end control_unit;

-- =================
--   Architecture
-- =================

architecture arch_control_unit of control_unit is
    -- Internal Objects
    -- type state is (
    --   STATE_RESET,
    --   STATE_FETCH1,
    --   STATE_FETCH2,
    --   STATE_DECODE,
    --   STATE_STORE,
    --   STATE_LOAD,
    --   STATE_JUMP,
    --   STATE_BIN,
    --   STATE_NOT,
    --   STATE_READ_REG_STORE,
    --   STATE_READ_REG_BIN,
    --   STATE_WRITE_REG,
    --   STATE_READ_MEM,
    --   STATE_WRITE_MEM
    -- );
    signal current_state : state := STATE_RESET;
begin

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
                    current_state <= STATE_JUMP;
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
                current_state <= STATE_WRITE_REG;

              -- PROCESS JMP TRANSITIONS
              when STATE_JUMP =>
                current_state <= STATE_FETCH1;

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
