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
use work.sdvu_constants.all;

-- =================
--      Entity
-- =================

entity alu is
    port (I_clock  : in STD_LOGIC; -- Clock
          I_enable : in STD_LOGIC; -- Enable
          I_reset  : in STD_LOGIC; -- Reset
          -- Inputs
          I_op_code  : in STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);  -- ALU operation to perform
          I_cfgMask  : in STD_LOGIC_VECTOR (1 downto 0);          -- Configuration mask for the instruction
          I_dataA    : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0); -- Input data A
          I_dataB    : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0); -- Input data B
          I_immA     : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0); -- Immediate value A
          I_immB     : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0); -- Immediate value B
          -- Outputs
          O_result : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0) -- Result of the operation
          );
end alu;

-- =================
--   Architecture
-- =================

architecture arch_alu of alu is

    -- Functions
    -- Overloading comparators to produce an STD LOGIC output
    -- LESS THAN
    function bool_to_logic(bool : boolean) return STD_LOGIC_VECTOR is
      variable result : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0) := (others => '0');
    begin
      if bool then
        result(0) := '1';
      end if;
      return result;
    end function bool_to_logic;

    -- Internal Objects
    -- Internal register for operation result. (able to hold the 24-bits address in case of JMP)
    signal s_result : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0) := (others => '0');
    -- Comparators to bring locally static choices
begin
    -- Processes
    PerformOperation: process(I_clock, I_enable, I_reset) -- I_clock and I_enable added to the sensitivity list of the process
      constant ZERO : std_logic_vector(REG_SIZE-1 downto 0) := (others => '0');
    begin
      -- Operations routine
      if rising_edge(I_clock) then
        if I_reset = '1' then -- Reset routine
          s_result <= (others => '0');
        elsif I_enable = '1' then  -- Enable
          case I_op_code(OP_SIZE-1 downto 0) is

              -- ADD operation
              -- =============
              when OP_ADD =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= std_logic_vector(resize(unsigned(I_dataA) + unsigned(I_dataB), REG_SIZE));
                  when CFG_RI =>
                    s_result <= std_logic_vector(resize(unsigned(I_dataA) + unsigned(I_immB), REG_SIZE));
                  when CFG_IR =>
                    s_result <= std_logic_vector(resize(unsigned(I_immA) + unsigned(I_dataB), REG_SIZE));
                  when CFG_II =>
                    s_result <= std_logic_vector(resize(unsigned(I_immA) + unsigned(I_immB), REG_SIZE));
                  when others =>
                    -- unreachable
                end case;

              -- SUB operation
              -- =============
              when OP_SUB =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= std_logic_vector(resize(unsigned(I_dataA) - unsigned(I_dataB), REG_SIZE));
                  when CFG_RI =>
                    s_result <= std_logic_vector(resize(unsigned(I_dataA) - unsigned(I_immB), REG_SIZE));
                  when CFG_IR =>
                    s_result <= std_logic_vector(resize(unsigned(I_immA) - unsigned(I_dataB), REG_SIZE));
                  when CFG_II =>
                    s_result <= std_logic_vector(resize(unsigned(I_immA) - unsigned(I_immB), REG_SIZE));
                  when others =>
                    -- unreachable
                end case;

              -- MUL operation
              -- =============
              when OP_MUL =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= std_logic_vector(resize(unsigned(I_dataA) * unsigned(I_dataB), REG_SIZE));
                  when CFG_RI =>
                    s_result <= std_logic_vector(resize(unsigned(I_dataA) * unsigned(I_immB), REG_SIZE));
                  when CFG_IR =>
                    s_result <= std_logic_vector(resize(unsigned(I_immA) * unsigned(I_dataB), REG_SIZE));
                  when CFG_II =>
                    s_result <= std_logic_vector(resize(unsigned(I_immA) * unsigned(I_immB), REG_SIZE));
                  when others =>
                    -- unreachable
                end case;

              -- DIV operation
              -- =============
              -- when OP_DIV =>
                -- case I_cfgMask is
                --   when CFG_RR then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_dataA) / unsigned(I_dataB));
                --   when CFG_RI then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_dataA) / unsigned(I_immB));
                --   when CFG_IR then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_immA) / unsigned(I_dataB));
                --   when CFG_II then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_immA) / unsigned(I_immB));
                -- end case;

              -- MOD operation
              -- =============
              -- when OP_MOD =>
                -- case I_cfgMask is
                --   when CFG_RR then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_dataA) mod unsigned(I_dataB));
                --   when CFG_RI then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_dataA) mod unsigned(I_immB));
                --   when CFG_IR then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_immA) mod unsigned(I_dataB));
                --   when CFG_II then
                --     s_result(REG_SIZE-1 downto 0) <= std_logic_vector(unsigned(I_immA) mod unsigned(I_immB));
                -- end case;

              -- -- AND operation
              -- -- =============
              -- when OP_AND =>
              --   case I_cfgMask is
              --     when CFG_RR =>
              --       s_result <= I_dataA and I_dataB;
              --     when CFG_RI =>
              --       s_result <= I_dataA and I_immB;
              --     when CFG_IR =>
              --       s_result <= I_immA and I_dataB;
              --     when CFG_II =>
              --       s_result <= I_immA and I_immB;
              --     when others =>
              --       -- unreachable
              --   end case;

              -- OR operation
              -- =============
              when OP_OR =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= bool_to_logic(unsigned(I_dataA) /= 0 or unsigned(I_dataB) /= 0);
                  when CFG_RI =>
                    s_result <= bool_to_logic(unsigned(I_dataA) /= 0 or unsigned(I_immB) /= 0);
                  when CFG_IR =>
                    s_result <= bool_to_logic(unsigned(I_immA) /= 0 or unsigned(I_dataB) /= 0);
                  when CFG_II =>
                    s_result <= bool_to_logic(unsigned(I_immA) /= 0 or unsigned(I_immB) /= 0);
                  when others =>
                    -- unreachable
                end case;


              -- LT operation
              -- =============
              when OP_LT =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= bool_to_logic(I_dataA < I_dataB);
                  when CFG_RI =>
                    s_result <= bool_to_logic(I_dataA < I_immB);
                  when CFG_IR =>
                    s_result <= bool_to_logic(I_immA < I_dataB);
                  when CFG_II =>
                    s_result <= bool_to_logic(I_immA < I_immB);
                  when others =>
                    -- unreachable
                end case;

              -- GT operation
              -- ============
              when OP_GT =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= bool_to_logic(I_dataA > I_dataB);
                  when CFG_RI =>
                    s_result <= bool_to_logic(I_dataA > I_immB);
                  when CFG_IR =>
                    s_result <= bool_to_logic(I_immA > I_dataB);
                  when CFG_II =>
                    s_result <= bool_to_logic(I_immA > I_immB);
                  when others =>
                    -- unreachable
                end case;


              -- EQ operation
              -- ============
              when OP_EQ | OP_AND =>
                case I_cfgMask is
                  when CFG_RR =>
                    s_result <= bool_to_logic(I_dataA = I_dataB);
                  when CFG_RI =>
                    s_result <= bool_to_logic(I_dataA = I_immB);
                  when CFG_IR =>
                    s_result <= bool_to_logic(I_immA = I_dataB);
                  when CFG_II =>
                    s_result <= bool_to_logic(I_immA = I_immB);
                  when others =>
                    -- unreachable
                end case;

              -- NOT operation
              -- =============
              when OP_NOT =>
                if I_dataA = ZERO then
                  s_result <= ZERO(REG_SIZE-1 downto 1) & '1';
                else
                  s_result <= ZERO(REG_SIZE-1 downto 1) & '0';
                end if;


              -- Other operations
              -- ================
              when others =>
                -- Default Result Code

          end case;
        end if;
      end if;
    end process;


    -- Propagate to outputs
    O_result <= s_result;

end arch_alu;
