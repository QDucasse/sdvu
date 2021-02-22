-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Arithmetic Logic Unit that performs the logic operations.
-- Here it means performing the actual operations behind the OPCODES.


-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.constant_codes.all;

-- =================
--      Entity
-- =================

entity alu is
    generic (REG_WIDTH : natural := 16;
             OP_SIZE   : natural := 4
             );
    port (I_clk        : in STD_LOGIC; -- Clock signal
          I_en         : in STD_LOGIC; -- Enable
          I_reset      : in STD_LOGIC; -- Reset
          -- Instruction selectors
          I_aluop    : in STD_LOGIC_VECTOR (3  downto 0);          -- ALU operation to perform
          I_cfgMask  : in STD_LOGIC_VECTOR (1  downto 0);          -- Configuration mask for the instruction
          I_dataA    : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Input data A
          I_dataB    : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Input data B
          I_dataImmA : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Immediate value A
          I_dataImmB : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Immediate value B
          I_address  : in STD_LOGIC_VECTOR (23 downto 0);          -- Address for JMP, STORE and LOAD
          I_type     : in STD_LOGIC_VECTOR (1  downto 0);          -- Type of the value loaded or stored
          I_WE       : in STD_LOGIC                                -- Write Enable

          O_dataResult : out STD_LOGIC_VECTOR (23 downto 0); --Result of the operation
          O_WE : out STD_LOGIC -- Pass over the write enable
          );
end alu;

-- =================
--   Architecture
-- =================

architecture arch_alu of alu is
    -- Internal Objects
    -- Internal register for operation result. (able to hold the 24-bits address in case of JMP)
    signal s_result : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    -- Internal bit to signal the need for branching
    signal s_shouldBranch : STD_LOGIC := '0';
    -- Comparators to bring locally static choices
    signal cmp_op     : std_logic_vector(3 downto 0);
begin
    -- Processes
    PerformOperation: process(I_clk, I_en, I_reset) -- I_clk and I_en added to the sensitivity list of the process
    begin
      -- Operations routine
      if rising_edge(I_clk) then  -- New cycle
        if I_reset = '1' then     -- Reset routine
          s_result <= (others => '0');
        elsif I_en = '1':         -- Enable
          O_WE <= I_WE;           -- Propagate write enable
          cmp_op <= I_aluop(3 downto 0);
          case cmp_op is

              -- ADD operation
              -- =============
              when OP_ADD =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) + unsigned(I_dataB));
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) + unsigned(I_dataImmB));
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) + unsigned(I_dataB));
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) + unsigned(I_dataImmB));
                end case;
                s_shouldBranch = '0'; -- No need for branching

              -- SUB operation
              -- =============
              when OP_SUB =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) - unsigned(I_dataB));
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) - unsigned(I_dataImmB));
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) - unsigned(I_dataB));
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) - unsigned(I_dataImmB));
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- MUL operation
              -- =============
              when OP_MUL =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) * unsigned(I_dataB));
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) * unsigned(I_dataImmB));
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) * unsigned(I_dataB));
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) * unsigned(I_dataImmB));
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- DIV operation
              -- =============
              when OP_DIV =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) / unsigned(I_dataB));
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) / unsigned(I_dataImmB));
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) / unsigned(I_dataB));
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) / unsigned(I_dataImmB));
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- MOD operation
              -- =============
              when OP_MOD =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) % unsigned(I_dataB));
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) % unsigned(I_dataImmB));
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) % unsigned(I_dataB));
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) % unsigned(I_dataImmB));
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- AND operation
              -- =============
              when OP_AND =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataA and I_dataB;
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataA and I_dataImmB;
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataImmA and I_dataB;
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataImmA and I_dataImmB;
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- OR operation
              -- =============
              when OP_OR =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataA or I_dataB;
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataA or I_dataImmB;
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataImmA or I_dataB;
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= I_dataImmA or I_dataImmB;
                end case;
                s_shouldBranch <= '0'; -- No need for branching.


              -- LT operation
              -- =============
              when OP_LT =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(REG_WIDTH-1 downto 0) <= unsigned(I_dataA) < unsigned(I_dataB);
                  when CFG_RI then
                    s_result(REG_WIDTH-1 downto 0) <= unsigned(I_dataA) < unsigned(I_dataImmB);
                  when CFG_IR then
                    s_result(REG_WIDTH-1 downto 0) <= unsigned(I_dataImmA) < unsigned(I_dataB);
                  when CFG_II then
                    s_result(REG_WIDTH-1 downto 0) <= unsigned(I_dataImmA) < unsigned(I_dataImmB);
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- GT operation
              -- ============
              when OP_GT =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(1 downto 0) <= unsigned(I_dataA) > unsigned(I_dataB);
                  when CFG_RI then
                    s_result(1 downto 0) <= unsigned(I_dataA) > unsigned(I_dataImmB);
                  when CFG_IR then
                    s_result(1 downto 0) <= unsigned(I_dataImmA) > unsigned(I_dataB);
                  when CFG_II then
                    s_result(1 downto 0) <= unsigned(I_dataImmA) > unsigned(I_dataImmB);
                end case;
                s_shouldBranch <= '0'; -- No need for branching.


              -- EQ operation
              -- ============
              when OP_GT =>
                case I_cfgMask is
                  when CFG_RR then
                    s_result(1 downto 0) <= unsigned(I_dataA) = unsigned(I_dataB);
                  when CFG_RI then
                    s_result(1 downto 0) <= unsigned(I_dataA) = unsigned(I_dataImmB);
                  when CFG_IR then
                    s_result(1 downto 0) <= unsigned(I_dataImmA) = unsigned(I_dataB);
                  when CFG_II then
                    s_result(1 downto 0) <= unsigned(I_dataImmA) = unsigned(I_dataImmB);
                end case;
                s_shouldBranch <= '0'; -- No need for branching.

              -- NOT operation
              -- =============
              when OP_NOT =>
                s_result(REG_WIDTH-1 downto 0) <= not I_dataA;
                s_shouldBranch <= '0'; -- No need for branching.

              -- JMP operation
              -- ================
              when OP_JMP =>
                -- Set target anyway
                s_result(23 downto 0) <= I_address;
                -- If condition verified, shouldBranch set to true
                if I_dataA then
                  s_shouldBranch = '1';
                else
                  s_shouldBranch = '0';
                end if;

              -- STORE operation
              -- ==============
              when OP_STORE =>
                s_shouldBranch <= '0';

              -- LOAD operation
              -- ==============
              when OP_LOAD =>
                s_shouldBranch <= '0';

              -- Other operations
              -- ================
              when others =>
                s_result <= X"FFFF"; -- Default Result Code

          end case;
        end if;
      end if;
    end process;

    -- Propagate to outputs
    O_dataResult <= s_result(23 downto 0);
    O_shouldBranch <= s_shouldBranch;

end arch_alu;
