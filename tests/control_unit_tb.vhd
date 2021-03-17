-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Program Counter Benchmark

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.sdvu_constants.all;
use work.tb_helpers.all;

-- =================
--      Entity
-- =================

entity control_unit_tb is
end control_unit_tb;

-- =================
--   Architecture
-- =================

architecture arch_control_unit_tb of control_unit_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clock   : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

     -- Entity Signals
    signal I_op_code        : STD_LOGIC_VECTOR(OP_SIZE-1 downto 0);
    signal O_reset          : STD_LOGIC;
    signal O_enable_ALU     : STD_LOGIC;
    signal O_enable_CFG_MEM : STD_LOGIC;
    signal O_enable_DECODER : STD_LOGIC;
    signal O_enable_PC      : STD_LOGIC;
    signal O_enable_PRG_MEM : STD_LOGIC;
    signal O_enable_REG     : STD_LOGIC;
    signal O_CFG_MEM_we     : STD_LOGIC;
    signal O_REG_we         : STD_LOGIC;
    signal O_PC_OPCode      : STD_LOGIC_VECTOR(PC_OP_SIZE-1 downto 0);


begin
    -- Clock, Reset and Enable generation
    ClockProcess : process
    begin
      genClock(clock, running, HALF_PERIOD);
    end process;

    ResetProcess : process
    begin
      genPulse(reset, 10 ns, true);
    end process;

    -- DUT
    dut: entity work.control_unit(arch_control_unit)
      port map (
        I_clock          => clock,
        I_reset          => reset,
        I_op_code        => I_op_code,
        I_PC_OPCode      => O_PC_OPCode,
        O_reset          => O_reset,
        O_enable_ALU     => O_enable_ALU,
        O_enable_CFG_MEM => O_enable_CFG_MEM,
        O_enable_DECODER => O_enable_DECODER,
        O_enable_PC      => O_enable_PC,
        O_enable_PRG_MEM => O_enable_PRG_MEM,
        O_enable_REG     => O_enable_REG,
        O_CFG_MEM_we     => O_CFG_MEM_we,
        O_REG_we         => O_REG_we,
        O_PC_OPCode      => O_PC_OPCode
      );

    -- Stimulus process
    StimulusProcess: process
    begin
      report "Control Unit: Running testbench";
      I_op_code <= OP_ADD;
      -- TESTING OPERATIONS
      wait_cycles(clock, 1);
      -- Test 1: Initial reset
      -- test_expression(external, STATE_RESET)
      test_expression(O_reset='1',             "RESET - Reset set");
      test_expression(O_enable_ALU='0',        "RESET - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',    "RESET - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',    "RESET - No enable DECODER");
      test_expression(O_enable_PC='0',         "RESET - No enable PC");
      test_expression(O_enable_PRG_MEM='0',    "RESET - No enable PRG_MEM");
      test_expression(O_enable_REG='0',        "RESET - No enable REG");
      test_expression(O_CFG_MEM_we='0',        "RESET - No we CFG_MEM");
      test_expression(O_REG_we='0',            "RESET - No we REG");
      test_expression(O_PC_OPCode=PC_OP_RESET, "RESET - PC operation: RESET");

      -- Test 2: Fetch
      wait_cycles(clock, 1);
      test_expression(O_reset='0',             "FETCH1 - Reset not set");
      test_expression(O_enable_ALU='0',        "FETCH1 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',    "FETCH1 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',    "FETCH1 - No enable DECODER");
      test_expression(O_enable_PC='1',         "FETCH1 - Enable PC");
      test_expression(O_enable_PRG_MEM='0',    "FETCH1 - No enable PRG_MEM");
      test_expression(O_enable_REG='0',        "FETCH1 - No enable REG");
      test_expression(O_CFG_MEM_we='0',        "FETCH1 - No we CFG_MEM");
      test_expression(O_REG_we='0',            "FETCH1 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_INC,   "FETCH1 - PC operation: INC");

      -- Test 3: Fetch 2
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "FETCH2 - Reset not set");
      test_expression(O_enable_ALU='0',      "FETCH2 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "FETCH2 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "FETCH2 - No enable DECODER");
      test_expression(O_enable_PC='0',       "FETCH2 - No enable PC");
      test_expression(O_enable_PRG_MEM='1',  "FETCH2 - Enable PRG_MEM");
      test_expression(O_enable_REG='0',      "FETCH2 - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "FETCH2 - No we CFG_MEM");
      test_expression(O_REG_we='0',          "FETCH2 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_NOP, "FETCH2 - PC operation: NOP");

      -- Test 4: Decode
      I_op_code <= OP_JMP;
      wait_cycles(clock, 1);
      test_expression(O_reset='0',              "DECODE - Reset not set");
      test_expression(O_enable_ALU='0',         "DECODE - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',     "DECODE - No enable CFG_MEM");
      test_expression(O_enable_DECODER='1',     "DECODE - Enable DECODER");
      test_expression(O_enable_PC='0',          "DECODE - No enable PC");
      test_expression(O_enable_PRG_MEM='0',     "DECODE - No enable PRG_MEM");
      test_expression(O_enable_REG='0',         "DECODE - No enable REG");
      test_expression(O_CFG_MEM_we='0',         "DECODE - No we CFG_MEM");
      test_expression(O_REG_we='0',             "DECODE - No we REG");
      test_expression(O_PC_OPCode=PC_OP_ASSIGN, "DECODE - PC operation: ASSIGN");

      -- Test 5: Fetch 1 from JMP
      wait_cycles(clock, 1);
      test_expression(O_reset='0',              "FETCH1 JMP - Reset not set");
      test_expression(O_enable_ALU='0',         "FETCH1 JMP - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',     "FETCH1 JMP - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',     "FETCH1 JMP - No enable DECODER");
      test_expression(O_enable_PC='1',          "FETCH1 JMP - Enable PC");
      test_expression(O_enable_PRG_MEM='0',     "FETCH1 JMP - No enable PRG_MEM");
      test_expression(O_enable_REG='0',         "FETCH1 JMP - No enable REG");
      test_expression(O_CFG_MEM_we='0',         "FETCH1 JMP - No we CFG_MEM");
      test_expression(O_REG_we='0',             "FETCH1 JMP - No we REG");
      test_expression(O_PC_OPCode=PC_OP_ASSIGN, "FETCH1 JMP - PC operation: ASSIGN");

      -- (Re-fetch, wait until state decode)
      wait_cycles(clock, 2);
      -- Test 6: Store 1
      I_op_code <= OP_STORE;
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "STORE1 - Reset not set");
      test_expression(O_enable_ALU='0',      "STORE1 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "STORE1 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "STORE1 - No enable DECODER");
      test_expression(O_enable_PC='0',       "STORE1 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "STORE1 - No enable PRG_MEM");
      test_expression(O_enable_REG='1',      "STORE1 - Enable REG");
      test_expression(O_CFG_MEM_we='0',      "STORE1 - No we CFG_MEM");
      test_expression(O_REG_we='0',          "STORE1 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_NOP, "STORE1 - PC operation: NOP");

      -- Test 7: Store 2
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "STORE2 - Reset not set");
      test_expression(O_enable_ALU='0',      "STORE2 - No enable ALU");
      test_expression(O_enable_CFG_MEM='1',  "STORE2 - Enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "STORE2 - No enable DECODER");
      test_expression(O_enable_PC='0',       "STORE2 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "STORE2 - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "STORE2 - No enable REG");
      test_expression(O_CFG_MEM_we='1',      "STORE2 - WE CFG_MEM");
      test_expression(O_REG_we='0',          "STORE2 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_INC, "STORE2 - PC operation: INC");

      -- Test 8: Fetch 1 from Store
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "FETCH1 STORE - Reset not set");
      test_expression(O_enable_ALU='0',      "FETCH1 STORE - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "FETCH1 STORE - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "FETCH1 STORE - No enable DECODER");
      test_expression(O_enable_PC='1',       "FETCH1 STORE - Enable PC");
      test_expression(O_enable_PRG_MEM='0',  "FETCH1 STORE - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "FETCH1 STORE - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "FETCH1 STORE - No we CFG_MEM");
      test_expression(O_REG_we='0',          "FETCH1 STORE - No we REG");
      test_expression(O_PC_OPCode=PC_OP_INC, "FETCH1 STORE - PC operation: INC");

      -- (Re-fetch, wait until state decode)
      wait_cycles(clock, 2);
      -- Test 9: Load 1
      I_op_code <= OP_LOAD;
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "LOAD1 - Reset not set");
      test_expression(O_enable_ALU='0',      "LOAD1 - No enable ALU");
      test_expression(O_enable_CFG_MEM='1',  "LOAD1 - Enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "LOAD1 - No enable DECODER");
      test_expression(O_enable_PC='0',       "LOAD1 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "LOAD1 - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "LOAD1 - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "LOAD1 - No we CFG_MEM");
      test_expression(O_REG_we='0',          "LOAD1 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_NOP, "LOAD1 - PC operation: NOP");

      -- Test 10: Load 2
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "LOAD2 - Reset not set");
      test_expression(O_enable_ALU='0',      "LOAD2 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "LOAD2 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "LOAD2 - No enable DECODER");
      test_expression(O_enable_PC='0',       "LOAD2 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "LOAD2 - No enable PRG_MEM");
      test_expression(O_enable_REG='1',      "LOAD2 - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "LOAD2 - No we CFG_MEM");
      test_expression(O_REG_we='1',          "LOAD2 - WE REG");
      test_expression(O_PC_OPCode=PC_OP_INC, "LOAD2 - PC operation: INC");

      -- Test 11: Fetch 1 from Load
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "FETCH1 LOAD - Reset not set");
      test_expression(O_enable_ALU='0',      "FETCH1 LOAD - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "FETCH1 LOAD - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "FETCH1 LOAD - No enable DECODER");
      test_expression(O_enable_PC='1',       "FETCH1 LOAD - Enable PC");
      test_expression(O_enable_PRG_MEM='0',  "FETCH1 LOAD - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "FETCH1 LOAD - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "FETCH1 LOAD - No we CFG_MEM");
      test_expression(O_REG_we='0',          "FETCH1 LOAD - No we REG");
      test_expression(O_PC_OPCode=PC_OP_INC, "FETCH1 LOAD - PC operation: INC");

      -- (Reset wait until state decode)
      wait_cycles(clock, 2);
      -- Test 12: Bin 1
      I_op_code <= OP_ADD;
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "BIN1 - Reset not set");
      test_expression(O_enable_ALU='0',      "BIN1 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "BIN1 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "BIN1 - No enable DECODER");
      test_expression(O_enable_PC='0',       "BIN1 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "BIN1 - No enable PRG_MEM");
      test_expression(O_enable_REG='1',      "BIN1 - Enable REG");
      test_expression(O_CFG_MEM_we='0',      "BIN1 - No we CFG_MEM");
      test_expression(O_REG_we='0',          "BIN1 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_NOP, "BIN1 - PC operation: NOP");

      -- Test 13: Bin 2
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "BIN2 - Reset not set");
      test_expression(O_enable_ALU='1',      "BIN2 - Enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "BIN2 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "BIN2 - No enable DECODER");
      test_expression(O_enable_PC='0',       "BIN2 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "BIN2 - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "BIN2 - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "BIN2 - No we CFG_MEM");
      test_expression(O_REG_we='0',          "BIN2 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_NOP, "BIN2 - PC operation: NOP");

      -- Test 14: Bin 3
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "BIN3 - Reset not set");
      test_expression(O_enable_ALU='0',      "BIN3 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "BIN3 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "BIN3 - No enable DECODER");
      test_expression(O_enable_PC='0',       "BIN3 - No enable PC");
      test_expression(O_enable_PRG_MEM='0',  "BIN3 - No enable PRG_MEM");
      test_expression(O_enable_REG='1',      "BIN3 - Enable REG");
      test_expression(O_CFG_MEM_we='0',      "BIN3 - No we CFG_MEM");
      test_expression(O_REG_we='1',          "BIN3 - WE REG");
      test_expression(O_PC_OPCode=PC_OP_INC, "BIN3 - PC operation: INC");


      -- Test 15: Fetch 1 from Bin
      wait_cycles(clock, 1);
      test_expression(O_reset='0',           "FETCH1 LOAD - Reset not set");
      test_expression(O_enable_ALU='0',      "FETCH1 LOAD - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "FETCH1 LOAD - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "FETCH1 LOAD - No enable DECODER");
      test_expression(O_enable_PC='1',       "FETCH1 LOAD - Enable PC");
      test_expression(O_enable_PRG_MEM='0',  "FETCH1 LOAD - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "FETCH1 LOAD - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "FETCH1 LOAD - No we CFG_MEM");
      test_expression(O_REG_we='0',          "FETCH1 LOAD - No we REG");
      test_expression(O_PC_OPCode=PC_OP_INC, "FETCH1 LOAD - PC operation: INC");

      running <= false;
      report "Control Unit: Testbench complete";
    end process;

end arch_control_unit_tb;
