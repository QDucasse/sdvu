-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Decoder of the incoming 16-bits instruction to extract the different
-- selectors as well as the operation to perform.

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

entity decoder is
    port (I_clock   : in STD_LOGIC; -- Clock
          I_enable  : in STD_LOGIC; -- Enable
          -- Inputs
          I_instruction: in STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);   -- 32-bit Instruction
          -- Outputs
          O_op_code        : out STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);       -- ALU operation to perform
          O_cfgMask        : out STD_LOGIC_VECTOR (1 downto 0);               -- Configuration mask for the instruction
          O_rD, O_rA, O_rB : out STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0); -- Registers (rd, ra and rb)
          O_immA, O_immB   : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);      -- Immediate value A and B from instruction
          O_address        : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);      -- Address for JMP, STORE and LOAD
          O_type           : out STD_LOGIC_VECTOR (1 downto 0)                -- Type of the value loaded or stored
          );
end decoder;

-- =================
--   Architecture
-- =================

architecture arch_decoder of decoder is
    -- Internal Objects
    signal current_op : STD_LOGIC_VECTOR(OP_SIZE-1 downto 0) := (others => '0');
begin
    -- Processes
    DecodeInstr: process(I_clock) -- I_clock added to the sensitivity list of the process
      constant ZERO : std_logic_vector(REG_SIZE-1 downto 0) := (others => '0');
    begin
        if rising_edge(I_clock) then  -- If new cycle and enable
            if I_enable = '1' then        -- If enable
                current_op <= I_instruction(31 downto 28); -- Decode ALU operation
                -- Switch on the opcode
                case current_op is
                  when OP_NOT => -- NOT OPERATION
                    -- Used
                    O_rD <= I_instruction(27 downto 24); -- 0000 1111 0000 0000 0000 0000 0000 0000
                    O_rA <= I_instruction(3  downto  0); -- 0000 0000 0000 0000 0000 0000 0000 1111
                    -- Unused
                    O_cfgMask <= (others => '0');
                    O_rB      <= (others => '0');
                    O_immA    <= (others => '0');
                    O_immB    <= (others => '0');
                    O_type    <= (others => '0');
                    O_address <= (others => '0');

                  when OP_LOAD => --LOAD OPERATION
                    -- Used
                    O_cfgMask <= I_instruction(27 downto 26);       -- 0000 1100 0000 0000 0000 0000 0000 0000
                    O_type    <= I_instruction(25 downto 24);       -- 0000 0011 0000 0000 0000 0000 0000 0000
                    O_rD      <= I_instruction(23 downto 20);       -- 0000 0000 1111 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(3  downto  0);       -- 0000 0000 0000 0000 0000 0000 0000 1111
                    O_immA    <= ZERO(REG_SIZE-1 downto 11) & I_instruction(10 downto 0); -- 0000 0000 0000 0000 0000 0111 1111 1111
                    O_address <= ZERO(REG_SIZE-1 downto 20) & I_instruction(19 downto 0); -- 0000 0000 0000 1111 1111 1111 1111 1111
                    -- Unused
                    O_rB      <= (others => '0');
                    O_immB    <= (others => '0');

                  when OP_STORE => -- STORE OPERATION
                    -- Used
                    O_cfgMask <= I_instruction(27 downto 26);       -- 0000 1100 0000 0000 0000 0000 0000 0000
                    O_type    <= I_instruction(25 downto 24);       -- 0000 0011 0000 0000 0000 0000 0000 0000
                    O_rD      <= I_instruction(23 downto 20);       -- 0000 0000 1111 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(3  downto  0);       -- 0000 0000 0000 0000 0000 0000 0000 1111
                    O_address <= ZERO(REG_SIZE-1 downto 20) & I_instruction(19 downto 0); -- 0000 0000 0000 1111 1111 1111 1111 1111
                    -- Unused
                    O_rB      <= (others => '0');
                    O_immA    <= (others => '0');
                    O_immB    <= (others => '0');

                  when OP_JMP => -- JUMP OPERATION
                    -- Used
                    O_rD      <= I_instruction(27 downto 24);       -- 0000 1111 0000 0000 0000 0000 0000 0000
                    O_address <= ZERO(REG_SIZE-1 downto 24) & I_instruction(23 downto 0); -- 0000 0000 1111 1111 1111 1111 1111 1111
                    -- Unused
                    O_cfgMask <= (others => '0');
                    O_rB      <= (others => '0');
                    O_rA      <= (others => '0');
                    O_immA    <= (others => '0');
                    O_immB    <= (others => '0');
                    O_type    <= (others => '0');

                  when others => -- BINARY OPERATION
                   -- Used
                    O_cfgMask <= I_instruction(27 downto 26);        -- 0000 1100 0000 0000 0000 0000 0000 0000
                    O_rD      <= I_instruction(25 downto 22);        -- 0000 0011 1100 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(14 downto 11);        -- 0000 0000 0000 0000 0111 1000 0000 0000
                    O_rB      <= I_instruction(3  downto  0);        -- 0000 0000 0000 0000 0000 0000 0000 1111
                    O_immA    <= ZERO(REG_SIZE-1 downto 11) & I_instruction(21 downto 11); -- 0000 0000 0011 1111 1111 1000 0000 0000
                    O_immB    <= ZERO(REG_SIZE-1 downto 11) & I_instruction(10 downto 0);  -- 0000 0000 0000 0000 0000 0111 1111 1111
                    -- Unused
                    O_type    <= (others => '0');
                    O_address <= (others => '0');
                end case;
                O_op_code <= current_op;
            end if;
        end if;
    end process;
end arch_decoder;
