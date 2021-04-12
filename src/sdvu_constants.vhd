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
use IEEE.numeric_std.all;

-- =================
--      Package
-- =================

package sdvu_constants is

  -- Opcodes
  constant OP_NOP:   STD_LOGIC_VECTOR(3 downto 0) :=  "0000";
  constant OP_ADD:   STD_LOGIC_VECTOR(3 downto 0) :=  "0001";
  constant OP_SUB:   STD_LOGIC_VECTOR(3 downto 0) :=  "0010";
  constant OP_MUL:   STD_LOGIC_VECTOR(3 downto 0) :=  "0011";
  constant OP_DIV:   STD_LOGIC_VECTOR(3 downto 0) :=  "0100";
  constant OP_MOD:   STD_LOGIC_VECTOR(3 downto 0) :=  "0101";
  constant OP_AND:   STD_LOGIC_VECTOR(3 downto 0) :=  "0110";
  constant OP_OR:    STD_LOGIC_VECTOR(3 downto 0) :=  "0111";
  constant OP_LT:    STD_LOGIC_VECTOR(3 downto 0) :=  "1000";
  constant OP_GT:    STD_LOGIC_VECTOR(3 downto 0) :=  "1001";
  constant OP_EQ:    STD_LOGIC_VECTOR(3 downto 0) :=  "1010";
  constant OP_NOT:   STD_LOGIC_VECTOR(3 downto 0) :=  "1011";
  constant OP_JMP:   STD_LOGIC_VECTOR(3 downto 0) :=  "1100";
  constant OP_STORE: STD_LOGIC_VECTOR(3 downto 0) :=  "1101";
  constant OP_LOAD:  STD_LOGIC_VECTOR(3 downto 0) :=  "1110";
  constant OP_ENDGA: STD_LOGIC_VECTOR(3 downto 0) :=  "1111";

  -- Config bitmasks for BINARY operations
  constant CFG_RR: STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant CFG_RI: STD_LOGIC_VECTOR(1 downto 0) := "01";
  constant CFG_IR: STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant CFG_II: STD_LOGIC_VECTOR(1 downto 0) := "11";

  -- Config bitmasks for LOAD operations
  constant LOAD_REG: STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant LOAD_IMM: STD_LOGIC_VECTOR(1 downto 0) := "01";
  constant LOAD_ADR: STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant LOAD_RAA: STD_LOGIC_VECTOR(1 downto 0) := "11";

  -- Config bitmasks for STORE operations
  constant STORE_ADR: STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant STORE_RAA: STD_LOGIC_VECTOR(1 downto 0) := "01";

  -- Types of values
  constant TYPE_BOOL:  STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant TYPE_BYTE:  STD_LOGIC_VECTOR(1 downto 0) := "01";
  constant TYPE_INT:   STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant TYPE_STATE: STD_LOGIC_VECTOR(1 downto 0) := "11";

  -- Sizes of the types
  constant SIZE_BOOL:  natural := 8;
  constant SIZE_BYTE:  natural := 8;
  constant SIZE_INT:   natural := 32;
  constant SIZE_STATE: natural := 16;

  -- PC unit opcodes
  constant PC_OP_NOP    : STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant PC_OP_INC    : STD_LOGIC_VECTOR(1 downto 0) := "01";
  constant PC_OP_ASSIGN : STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant PC_OP_RESET  : STD_LOGIC_VECTOR(1 downto 0) := "11";

  -- Design constants

  -- Instruction related
  constant INSTR_SIZE    : natural := 32;
  constant OP_SIZE       : natural := 4;
  -- Register related
  constant REG_SIZE      : natural := 32;
  constant REG_SEL_SIZE  : natural := 4;
  -- Control unit related
  constant STATE_NUMBER  : natural := 14;
  -- PC related
  constant PC_SIZE       : natural := 32;
  constant PC_OP_SIZE    : natural := 2;
  -- Memory related
  constant PROG_MEM_SIZE : natural := 5;
  constant CFG_MEM_SIZE  : natural := 8;
  constant TYPE_SIZE     : natural := 32;
  -- Coordinator
  constant CORE_NUMBER   : natural := 3;

  -- Program Memory types
  type prog_memory is array (0 to 2**PROG_MEM_SIZE-1) of STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
  type prog_memory_array is array (0 to CORE_NUMBER-1) of prog_memory;
  -- Config Memory types
  subtype config_memory is STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0);
  type config_memory_array is array (0 to CORE_NUMBER-1) of config_memory;

end package sdvu_constants;
