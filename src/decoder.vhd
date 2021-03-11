-- Project Structure from TPU Blogpost series by @domipheus
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
    generic (OP_SIZE      : natural := 4;  -- Size of op-code (4-bits)
             REG_SIZE     : natural := 32; -- Size of a register
             REG_SEL_SIZE : natural :=  4; -- Register selector on 4 bits (16 regs)
             INSTR_SIZE   : natural := 32
             );
    port (I_clock   : in STD_LOGIC; -- Clock
          I_enable  : in STD_LOGIC; -- Enable
          -- Base instruction
          I_instruction: in STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);   -- 32-bit Instruction
          -- Selectors to extract from the instruction
          O_op_code        : out STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);         -- ALU operation to perform
          O_cfgMask        : out STD_LOGIC_VECTOR (1  downto 0);         -- Configuration mask for the instruction
          O_rD, O_rA, O_rB : out STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);  -- Registers (rd, ra and rb)
          O_immA, O_immB   : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);  -- Immediate value A and B from instruction
          O_address        : out STD_LOGIC_VECTOR (REG_SIZE downto 0);         -- Address for JMP, STORE and LOAD
          O_type           : out STD_LOGIC_VECTOR (1  downto 0);         -- Type of the value loaded or stored
          -- TODO: Remove?
          O_WE      : out STD_LOGIC                               -- Write Enabled
          );
end decoder;

-- =================
--   Architecture
-- =================

architecture arch_decoder of decoder is
    -- Internal Objects
    signal cmp_op : std_logic_vector(3 downto 0);
    -- None
begin
    -- Processes
    DecodeInstr: process(I_clock) -- I_clock added to the sensitivity list of the process
    begin
        if rising_edge(I_clock) then  -- If new cycle and enable
            if I_enable = '1' then        -- If enable
                cmp_op <= I_instruction(31 downto 28); -- Decode ALU operation
                O_op_code <= cmp_op;
                -- Zero out all outputs to avoid latch creation
                O_cfgMask <= (others => '0');
                O_rB      <= (others => '0');
                O_immA    <= (others => '0');
                O_immB    <= (others => '0');
                O_type    <= (others => '0');
                O_address <= (others => '0');
                -- Switch on the opcode
                case cmp_op is
                  when OP_NOT => -- NOT OPERATION
                    O_rD      <= I_instruction(27 downto 24); -- 0000 1111 0000 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(3  downto  0); -- 0000 0000 0000 0000 0000 0000 0000 1111
                  when OP_LOAD => --LOAD OPERATION
                    O_cfgMask <= I_instruction(27 downto 26);          -- 0000 1100 0000 0000 0000 0000 0000 0000
                    O_type    <= I_instruction(25 downto 24);          -- 0000 0011 0000 0000 0000 0000 0000 0000
                    O_rD      <= I_instruction(23 downto 20);          -- 0000 0000 1111 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(3  downto  0);          -- 0000 0000 0000 0000 0000 0000 0000 1111
                    O_immA    <= I_instruction(10 downto  0);          -- 0000 0000 0000 0000 0000 0111 1111 1111
                    O_address <= "000000000000" & I_instruction(19 downto  0); -- 0000 0000 0000 1111 1111 1111 1111 1111
                  when OP_STORE => -- STORE OPERATION
                    O_cfgMask <= I_instruction(27 downto 26);          -- 0000 1100 0000 0000 0000 0000 0000 0000
                    O_type    <= I_instruction(25 downto 24);          -- 0000 0011 0000 0000 0000 0000 0000 0000
                    O_rD      <= I_instruction(23 downto 20);          -- 0000 0000 1111 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(3  downto  0);          -- 0000 0000 0000 0000 0000 0000 0000 1111
                    O_address <= "000000000000" & I_instruction(19 downto  0); -- 0000 0000 0000 1111 1111 1111 1111 1111
                  when OP_JMP => -- JUMP OPERATION
                    O_rA      <= I_instruction(27 downto 24);              -- 0000 1111 0000 0000 0000 0000 0000 0000
                    O_address <= "00000000" & I_instruction(23 downto  0); -- 0000 0000 1111 1111 1111 1111 1111 1111
                  when others => -- BINARY OPERATION
                    O_cfgMask <= I_instruction(27 downto 26); -- 0000 1100 0000 0000 0000 0000 0000 0000
                    O_rD      <= I_instruction(25 downto 22); -- 0000 0011 1100 0000 0000 0000 0000 0000
                    O_rA      <= I_instruction(14 downto 11); -- 0000 0000 0000 0000 0111 1000 0000 0000
                    O_rB      <= I_instruction(3  downto  0); -- 0000 0000 0000 0000 0000 0000 0000 1111
                    O_immA    <= I_instruction(21 downto 11); -- 0000 0000 0011 1111 1111 1000 0000 0000
                    O_immB    <= I_instruction(10 downto  0); -- 0000 0000 0000 0000 0000 0111 1111 1111
                end case;
                -- Write enable set to NO in case of STORE and JMP
                case cmp_op is
                    when OP_STORE | OP_JMP =>
                      O_WE <= '0';
                    when others =>
                      O_WE <= '1';
                end case;
            end if;
        end if;
    end process;
end arch_decoder;
