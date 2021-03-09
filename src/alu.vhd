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
    generic (REG_WIDTH : natural := 32;
             OP_SIZE   : natural := 4
             );
    port (I_clock  : in STD_LOGIC; -- Clock
          I_enable : in STD_LOGIC; -- Enable
          I_reset  : in STD_LOGIC; -- Reset
          -- Inputs
          I_aluop    : in STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);   -- ALU operation to perform
          I_cfgMask  : in STD_LOGIC_VECTOR (1 downto 0);           -- Configuration mask for the instruction
          I_dataA    : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);    -- Input data A
          I_dataB    : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);    -- Input data B
          I_dataImmA : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);    -- Immediate value A
          I_dataImmB : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);    -- Immediate value B
          I_address  : in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Address for JMP, STORE and LOAD
          I_type     : in STD_LOGIC_VECTOR (1 downto 0);           -- Type of the value loaded or stored
          I_WE       : in STD_LOGIC;                               -- Write Enable
          -- Outputs
          O_dataResult : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Result of the operation
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
    PerformOperation: process(I_clock, I_enable, I_reset) -- I_clock and I_enable added to the sensitivity list of the process
    begin
      -- Operations routine
      if rising_edge(I_clock) then
        if I_reset = '1' then -- Reset routine
          s_result <= (others => '0');
        elsif I_enable= '1':  -- Enable
          O_WE <= I_WE;       -- Propagate write enable
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

              -- DIV operation
              -- =============
              -- when OP_DIV =>
                -- case I_cfgMask is
                --   when CFG_RR then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) / unsigned(I_dataB));
                --   when CFG_RI then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) / unsigned(I_dataImmB));
                --   when CFG_IR then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) / unsigned(I_dataB));
                --   when CFG_II then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) / unsigned(I_dataImmB));
                -- end case;

              -- MOD operation
              -- =============
              -- when OP_MOD =>
                -- case I_cfgMask is
                --   when CFG_RR then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) mod unsigned(I_dataB));
                --   when CFG_RI then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataA) mod unsigned(I_dataImmB));
                --   when CFG_IR then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) mod unsigned(I_dataB));
                --   when CFG_II then
                --     s_result(REG_WIDTH-1 downto 0) <= std_logic_vector(unsigned(I_dataImmA) mod unsigned(I_dataImmB));
                -- end case;

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

              -- NOT operation
              -- =============
              when OP_NOT =>
                s_result(REG_WIDTH-1 downto 0) <= not I_dataA;

              -- -- JMP operation
              -- -- ================
              -- when OP_JMP =>
              --   -- Set target anyway
              --   s_result(23 downto 0) <= I_address;
              --   -- If condition verified, shouldBranch set to true
              --   if I_dataA then
              --     s_shouldBranch = '1';
              --   else
              --     s_shouldBranch = '0';
              --   end if;
              --
              -- -- STORE operation
              -- -- ==============
              -- when OP_STORE =>
              --   s_shouldBranch <= '0';
              --
              -- -- LOAD operation
              -- -- ==============
              -- when OP_LOAD =>
              --   s_shouldBranch <= '0';

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

end arch_alu;
