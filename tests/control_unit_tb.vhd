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
      test_expression(O_reset='0',           "FETCH1 - Reset not set");
      test_expression(O_enable_ALU='0',      "FETCH1 - No enable ALU");
      test_expression(O_enable_CFG_MEM='0',  "FETCH1 - No enable CFG_MEM");
      test_expression(O_enable_DECODER='0',  "FETCH1 - No enable DECODER");
      test_expression(O_enable_PC='1',       "FETCH1 - Enable PC");
      test_expression(O_enable_PRG_MEM='0',  "FETCH1 - No enable PRG_MEM");
      test_expression(O_enable_REG='0',      "FETCH1 - No enable REG");
      test_expression(O_CFG_MEM_we='0',      "FETCH1 - No we CFG_MEM");
      test_expression(O_REG_we='0',          "FETCH1 - No we REG");
      test_expression(O_PC_OPCode=PC_OP_NOP, "FETCH1 - PC operation: NOP");

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

      -- (Reset wait until state decode)
      -- Test 6: Store 1

      -- Test 7: Store 2

      -- Test 8: Fetch 1 from Store

      -- (Reset wait until state decode)
      -- Test 9: Load 1

      -- Test 10: Load 2

      -- Test 11: Fetch 1 from Load

      -- (Reset wait until state decode)
      -- Test 12: Bin 1

      -- Test 13: Bin 2

      -- Test 14: Bin 3

      -- Test 15: Fetch 1 from Bin
      wait_cycles(clock, 50);
      running <= false;
      report "Control Unit: Testbench complete";
    end process;

end arch_control_unit_tb;
