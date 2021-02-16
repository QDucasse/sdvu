-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- All the constants used by the different components (OP_CODES, CFG bitmasks, etc.)

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

-- =================
--      Package
-- =================

package constant_codes is

  -- Opcodes
  constant OP_ADD:   std_logic_vector(3 downto 0) :=  "0000";
  constant OP_SUB:   std_logic_vector(3 downto 0) :=  "0001";
  constant OP_MUL:   std_logic_vector(3 downto 0) :=  "0010";
  constant OP_DIV:   std_logic_vector(3 downto 0) :=  "0011";
  constant OP_MOD:   std_logic_vector(3 downto 0) :=  "0100";
  constant OP_AND:   std_logic_vector(3 downto 0) :=  "0101";
  constant OP_OR:    std_logic_vector(3 downto 0) :=  "0110";
  constant OP_LT:    std_logic_vector(3 downto 0) :=  "0111";
  constant OP_GT:    std_logic_vector(3 downto 0) :=  "1000";
  constant OP_EQ:    std_logic_vector(3 downto 0) :=  "1001";
  constant OP_NOT:   std_logic_vector(3 downto 0) :=  "1010";
  constant OP_JMP:   std_logic_vector(3 downto 0) :=  "1011";
  constant OP_STORE: std_logic_vector(3 downto 0) :=  "1100";
  constant OP_LOAD:  std_logic_vector(3 downto 0) :=  "1101";

  -- Config bitmasks for BINARY operations
  constant CFG_RR: std_logic_vector(1 downto 0) := "00";
  constant CFG_RI: std_logic_vector(1 downto 0) := "01";
  constant CFG_IR: std_logic_vector(1 downto 0) := "10";
  constant CFG_II: std_logic_vector(1 downto 0) := "11";

  -- Config bitmasks for LOAD operations
  constant LOAD_REG: std_logic_vector(1 downto 0) := "00";
  constant LOAD_IMM: std_logic_vector(1 downto 0) := "01";
  constant LOAD_ADR: std_logic_vector(1 downto 0) := "10";
  constant LOAD_RAA: std_logic_vector(1 downto 0) := "11";

  -- Config bitmasks for STORE operations
  constant STORE_ADR: std_logic_vector(1 downto 0) := "00";
  constant STORE_RAA: std_logic_vector(1 downto 0) := "01";

  -- Types of values
  constant VAL_BOOL:  std_logic_vector(1 downto 0) := "00";
  constant VAL_BYTE:  std_logic_vector(1 downto 0) := "01";
  constant VAL_INT:   std_logic_vector(1 downto 0) := "10";
  constant VAL_STATE: std_logic_vector(1 downto 0) := "11";

  -- PC unit opcodes
  constant PCU_OP_NOP:    std_logic_vector(1 downto 0):= "00";
  constant PCU_OP_INC:    std_logic_vector(1 downto 0):= "01";
  constant PCU_OP_ASSIGN: std_logic_vector(1 downto 0):= "10";
  constant PCU_OP_RESET:  std_logic_vector(1 downto 0):= "11";

end package constant_codes;


package body constant_codes is
  -- Empty body since only constants are used in this package
end package body constant_codes;
