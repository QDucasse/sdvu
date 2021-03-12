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
          -- Enable signals based on the state
          O_reset          : out STD_LOGIC;
          O_enable_ALU     : out STD_LOGIC;
          O_enable_CFG_MEM : out STD_LOGIC;
          O_enable_DECODER : out STD_LOGIC;
          O_enable_PC      : out STD_LOGIC;
          O_enable_PRG_MEM : out STD_LOGIC;
          O_enable_REG     : out STD_LOGIC;

          -- Other signals
          O_CFG_MEM_we : out STD_LOGIC;
          O_REG_we     : out STD_LOGIC;
          O_PC_OPCode  : out STD_LOGIC_VECTOR(PC_OP_SIZE-1 downto 0)

          );
end control_unit;

-- =================
--   Architecture
-- =================

architecture arch_control_unit of control_unit is
    -- Internal Objects
    type state is (
      STATE_RESET,  -- Reset the system components
      STATE_FETCH1, -- Process PC
      STATE_FETCH2, -- Use PC to get instruction
      STATE_DECODE, -- Decode instruction
      STATE_STORE1, -- Process the regs to get the value to store
      STATE_STORE2, -- Store the value in memory
      STATE_LOAD1,  -- Get the value at the given address
      STATE_LOAD2,  -- Store it in registers
      STATE_BIN1,   -- Get the values behind registers
      STATE_BIN2,   -- Do the actual calculation
      STATE_BIN3    -- Store the result in a register
    );
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

              -- INSTRUCTION TRANSITIONS
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
                    current_state <= STATE_STORE1;
                  when OP_LOAD =>
                    current_state <= STATE_LOAD1;
                  when OP_JMP =>
                    current_state <= STATE_FETCH1;
                  when others =>
                    current_state <= STATE_BIN1;
                end case;

              -- PROCESS STORE TRANSITIONS
              when STATE_STORE1 =>
                current_state <= STATE_STORE2;
              when STATE_STORE2 =>
                current_state <= STATE_FETCH1;

              -- PROCESS LOAD TRANSITIONS
              when STATE_LOAD1 =>
                current_state <= STATE_LOAD2;
              when STATE_LOAD2 =>
                current_state <= STATE_FETCH1;

              -- PROCESS BIN/NOT TRANSITIONS
              when STATE_BIN1 =>
                current_state <= STATE_BIN2;
              when STATE_BIN2 =>
                current_state <= STATE_BIN3;
              when STATE_BIN3 =>
                current_state <= STATE_FETCH1;

              when others =>
                current_state <= STATE_RESET;
            end case;
          end if;
        end if;
    end process;

    -- State mapping to the outputs
    O_reset          <= '1' when current_state = STATE_RESET else '0';
    O_enable_PC      <= '1' when current_state = STATE_FETCH1 else '0';
    O_enable_PRG_MEM <= '1' when current_state = STATE_FETCH2 else '0';

    -- CFG memory needed when loading or storing a value
    O_enable_CFG_MEM <= '1' when (
                               current_state = STATE_LOAD1 or
                               current_state = STATE_STORE2
                               )
                            else '0';
    O_enable_DECODER <= '1' when current_state = STATE_DECODE else '0';
    O_enable_ALU     <= '1' when current_state = STATE_BIN2 else '0';
    -- Reg needed when retrieving the operands of a binary operation
    --                 writing the result to a register
    --                 getting the value to store
    --                 loading a value from memory
    -- TODO            getting address in RAA
    O_enable_REG     <= '1' when (
                               current_state = STATE_BIN1 or
                               current_state = STATE_BIN3 or
                               current_state = STATE_STORE1 or
                               current_state = STATE_LOAD2
                              )
                            else '0';

    -- Write to memory in case of STORE
    O_CFG_MEM_we <= '1' when current_state = STATE_STORE2 else '0';
    -- Write to register in case of result of a binary operation or load
    O_REG_we     <= '1' when (
                           current_state = STATE_LOAD2 or
                           current_state = STATE_BIN3
                          )
                        else '0';


end arch_control_unit;
