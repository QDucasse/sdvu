-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- FSM for the control unit

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
          I_op_code   : in STD_LOGIC_VECTOR(OP_SIZE-1 downto 0);    -- Instruction Op Code
          I_cfg_mask  : in STD_LOGIC_VECTOR(1 downto 0);            -- Conig mask
          I_PC_OPCode : in STD_LOGIC_VECTOR(PC_OP_SIZE-1 downto 0); -- Carry over PC operation
          I_address     : in STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
          I_address_RAA : in STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
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
          O_CFG_MEM_we    : out STD_LOGIC;
          O_REG_we_ALU    : out STD_LOGIC;
          O_REG_we_LOAD   : out STD_LOGIC;
          O_REG_we_MOVIMM : out STD_LOGIC;
          O_REG_we_MOVREG : out STD_LOGIC;
          O_address       : out STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
          O_PC_OPCode     : out STD_LOGIC_VECTOR(PC_OP_SIZE-1 downto 0)
          );
end control_unit;

-- =================
--   Architecture
-- =================

architecture arch_control_unit of control_unit is
    -- Internal Objects
    type state is (
      STATE_RESET1,   -- Transfer the reset signal to the other components
      STATE_RESET2,   -- Wait for the propagation of the reset
      STATE_FETCH1,   -- Process PC
      STATE_FETCH2,   -- Use PC to get instruction
      STATE_DECODE1,  -- Decode instruction
      STATE_DECODE2,  -- Switch on the instruction
      STATE_STORE1,   -- Process the regs to get the value to store
      STATE_STORERAA, -- Process Register as Address
      STATE_STORE2,   -- Store the value in memory
      STATE_LOAD1,    -- Get the value at the given address
      STATE_LOADRAA,  -- Process Register as Address
      STATE_LOAD2,    -- Store it in registers
      STATE_MOVREG,   -- Get the value if from a register
      STATE_MOVIMM,   -- Store it in the new register
      STATE_BIN1,     -- Get the values behind registers
      STATE_BIN2,     -- Do the actual calculation
      STATE_BIN3      -- Store the result in a register
    );
    signal current_state : state := STATE_RESET1;
begin

    -- Processes
    NextState: process(I_clock) -- I_clock added to the sensitivity list of the process
    begin
        if rising_edge(I_clock) then
          if I_reset = '1' then
            current_state <= STATE_RESET1;
          else
            case current_state is
              -- RESET TRANSITION
              when STATE_RESET1 =>
                current_state <= STATE_RESET2;

              -- INSTRUCTION TRANSITIONS
              when STATE_RESET2 =>
                current_state <= STATE_FETCH1;
              when STATE_FETCH1 =>
                current_state <= STATE_FETCH2;
              when STATE_FETCH2 =>
                current_state <= STATE_DECODE1;
              when STATE_DECODE1 =>
                current_state <= STATE_DECODE2;

              -- SWITCH ON THE DECODE1
              when STATE_DECODE2 =>
                case I_op_code is
                  -- STORE
                  when OP_STORE =>
                    case I_cfg_mask is
                      when STORE_ADR =>
                        current_state <= STATE_STORE1;
                      when STORE_RAA =>
                        current_state <= STATE_STORERAA;
                      when others =>
                        -- unreachable
                    end case;
                    -- LOAD
                  when OP_LOAD =>
                    case I_cfg_mask is
                      when LOAD_ADR =>
                        current_state <= STATE_LOAD1;
                      when LOAD_RAA =>
                        current_state <= STATE_LOADRAA;
                      when LOAD_REG =>
                        current_state <= STATE_MOVREG;
                      when LOAD_IMM =>
                        current_state <= STATE_MOVIMM;
                      when others =>
                        -- unreachable
                    end case;
                  -- JUMP
                  when OP_JMP =>
                    current_state <= STATE_FETCH1;
                  -- BINARY
                  when others =>
                    current_state <= STATE_BIN1;
                end case;

              -- PROCESS STORE TRANSITIONS
              when STATE_STORE1 =>
                current_state <= STATE_STORE2;
              when STATE_STORERAA =>
                current_state <= STATE_STORE2;
              when STATE_STORE2 =>
                current_state <= STATE_FETCH1;

              -- PROCESS LOAD TRANSITIONS
              when STATE_LOAD1 =>
                current_state <= STATE_LOAD2;
              when STATE_LOADRAA =>
                current_state <= STATE_LOAD1;
              when STATE_LOAD2 =>
                current_state <= STATE_FETCH1;

              -- PROCESS MOVE TRANSITIONS
              when STATE_MOVIMM =>
                current_state <= STATE_FETCH1;
              when STATE_MOVREG =>
                current_state <= STATE_FETCH1;

              -- PROCESS BIN/NOT TRANSITIONS
              when STATE_BIN1 =>
                current_state <= STATE_BIN2;
              when STATE_BIN2 =>
                current_state <= STATE_BIN3;
              when STATE_BIN3 =>
                current_state <= STATE_FETCH1;

              when others =>
                current_state <= STATE_RESET1;
            end case;
          end if;
        end if;
    end process;

    -- State mapping to the outputs
    O_reset          <= '1' when current_state = STATE_RESET1 else '0';
    O_enable_PC      <= '1' when current_state = STATE_FETCH1 else '0';
    O_enable_PRG_MEM <= '1' when current_state = STATE_FETCH2 else '0';

    -- CFG memory needed when loading or storing a value
    O_enable_CFG_MEM <= '1' when (
                               current_state = STATE_LOAD1 or
                               current_state = STATE_STORE2
                               )
                            else '0';
    O_enable_DECODER <= '1' when current_state = STATE_DECODE1 else '0';
    O_enable_ALU     <= '1' when current_state = STATE_BIN2 else '0';
    -- Reg needed when retrieving the operands of a binary operation
    --                 writing the result to a register
    --                 getting the value to store
    --                 loading a value from memory
    -- TODO            getting address in RAA
    O_enable_REG     <= '1' when (
                               current_state = STATE_BIN1     or
                               current_state = STATE_BIN3     or
                               current_state = STATE_STORE1   or
                               current_state = STATE_STORERAA or
                               current_state = STATE_LOADRAA  or
                               current_state = STATE_LOAD2    or
                               current_state = STATE_MOVIMM   or
                               current_state = STATE_MOVREG
                              )
                            else '0';

    -- Write to memory in case of STORE
    O_CFG_MEM_we    <= '1' when current_state = STATE_STORE2 else '0';
    -- Write to register in case of result of a binary operation or load
    O_REG_we_ALU    <= '1' when current_state = STATE_BIN3 else '0';
    -- Write to register in case of a memory read (load)
    O_REG_we_LOAD   <= '1' when current_state = STATE_LOAD2 else '0';
    -- Write to register from an immediate value
    O_REG_we_MOVIMM <= '1' when current_state = STATE_MOVIMM else '0';
    -- Write to register from another register
    O_REG_we_MOVREG <= '1' when current_state = STATE_MOVREG else '0';
    -- The PC op code is either:
    -- RESET in case of a reset
    -- ASSIGN when JMP (in decode state) --> needs to be propagated with the first line
    -- INC when finishing a load, store or bin
    -- NOP otherwise
    O_PC_OPCode  <= I_PC_OPCode when (current_state = STATE_FETCH1 and I_PC_OPCode /= PC_OP_RESET)
                    else PC_OP_INC when (
                                 current_state = STATE_LOAD2 or
                                 current_state = STATE_STORE2 or
                                 current_state = STATE_BIN3 or
                                 current_state = STATE_FETCH1
                                )
                    else PC_OP_ASSIGN when current_state = STATE_DECODE2
                    else PC_OP_RESET when current_state = STATE_RESET1
                    else PC_OP_NOP;

    -- The address signal is either equal to the address from the decoder
    -- or the content of a register (RAA)
    O_address <= I_address_RAA when (current_state = STATE_LOADRAA or current_state = STATE_STORERAA)
                        else I_address;

end arch_control_unit;
