-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the Control Unit

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
      -- assert_true(external, STATE_RESET1)
      assert_true(O_reset='1',             "RESET1 - Reset set");
      assert_true(O_enable_ALU='0',        "RESET1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',    "RESET1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',    "RESET1 - No enable DECODER");
      assert_true(O_enable_PC='0',         "RESET1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',    "RESET1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',        "RESET1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',        "RESET1 - No we CFG_MEM");
      assert_true(O_REG_we='0',            "RESET1 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_RESET, "RESET1 - PC operation: RESET");

      -- Test 2: Reset 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',             "RESET2 - No reset set");
      assert_true(O_enable_ALU='0',        "RESET2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',    "RESET2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',    "RESET2 - No enable DECODER");
      assert_true(O_enable_PC='0',         "RESET2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',    "RESET2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',        "RESET2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',        "RESET2 - No we CFG_MEM");
      assert_true(O_REG_we='0',            "RESET2 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP,   "RESET2 - PC operation: NOP");

      -- Test 3: Fetch
      wait_cycles(clock, 1);
      assert_true(O_reset='0',             "FETCH1 - Reset not set");
      assert_true(O_enable_ALU='0',        "FETCH1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',    "FETCH1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',    "FETCH1 - No enable DECODER");
      assert_true(O_enable_PC='1',         "FETCH1 - Enable PC");
      assert_true(O_enable_PRG_MEM='0',    "FETCH1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',        "FETCH1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',        "FETCH1 - No we CFG_MEM");
      assert_true(O_REG_we='0',            "FETCH1 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP,   "FETCH1 - PC operation: NOP");

      -- Test 4: Fetch 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH2 - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "FETCH2 - No enable PC");
      assert_true(O_enable_PRG_MEM='1',  "FETCH2 - Enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH2 - No we CFG_MEM");
      assert_true(O_REG_we='0',          "FETCH2 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "FETCH2 - PC operation: NOP");

      -- Test 5: Decode
      I_op_code <= OP_JMP;
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "DECODE - Reset not set");
      assert_true(O_enable_ALU='0',         "DECODE - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "DECODE - No enable CFG_MEM");
      assert_true(O_enable_DECODER='1',     "DECODE - Enable DECODER");
      assert_true(O_enable_PC='0',          "DECODE - No enable PC");
      assert_true(O_enable_PRG_MEM='0',     "DECODE - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "DECODE - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "DECODE - No we CFG_MEM");
      assert_true(O_REG_we='0',             "DECODE - No we REG");
      assert_true(O_PC_OPCode=PC_OP_ASSIGN, "DECODE - PC operation: ASSIGN");

      -- Test 6: Fetch 1 from JMP
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "FETCH1 JMP - Reset not set");
      assert_true(O_enable_ALU='0',         "FETCH1 JMP - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "FETCH1 JMP - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "FETCH1 JMP - No enable DECODER");
      assert_true(O_enable_PC='1',          "FETCH1 JMP - Enable PC");
      assert_true(O_enable_PRG_MEM='0',     "FETCH1 JMP - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "FETCH1 JMP - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "FETCH1 JMP - No we CFG_MEM");
      assert_true(O_REG_we='0',             "FETCH1 JMP - No we REG");
      assert_true(O_PC_OPCode=PC_OP_ASSIGN, "FETCH1 JMP - PC operation: ASSIGN");

      -- (Re-fetch, wait until state decode)
      wait_cycles(clock, 2);
      -- Test 7: Store 1
      I_op_code <= OP_STORE;
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "STORE1 - Reset not set");
      assert_true(O_enable_ALU='0',      "STORE1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "STORE1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "STORE1 - No enable DECODER");
      assert_true(O_enable_PC='0',       "STORE1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "STORE1 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "STORE1 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "STORE1 - No we CFG_MEM");
      assert_true(O_REG_we='0',          "STORE1 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "STORE1 - PC operation: NOP");

      -- Test 8: Store 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "STORE2 - Reset not set");
      assert_true(O_enable_ALU='0',      "STORE2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='1',  "STORE2 - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "STORE2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "STORE2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "STORE2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "STORE2 - No enable REG");
      assert_true(O_CFG_MEM_we='1',      "STORE2 - WE CFG_MEM");
      assert_true(O_REG_we='0',          "STORE2 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_INC, "STORE2 - PC operation: INC");

      -- Test 9: Fetch 1 from Store
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 STORE - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 STORE - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 STORE - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 STORE - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 STORE - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 STORE - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 STORE - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 STORE - No we CFG_MEM");
      assert_true(O_REG_we='0',          "FETCH1 STORE - No we REG");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 STORE - PC operation: INC");

      -- (Re-fetch, wait until state decode)
      wait_cycles(clock, 2);
      -- Test 10: Load 1
      I_op_code <= OP_LOAD;
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "LOAD1 - Reset not set");
      assert_true(O_enable_ALU='0',      "LOAD1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='1',  "LOAD1 - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "LOAD1 - No enable DECODER");
      assert_true(O_enable_PC='0',       "LOAD1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "LOAD1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "LOAD1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "LOAD1 - No we CFG_MEM");
      assert_true(O_REG_we='0',          "LOAD1 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "LOAD1 - PC operation: NOP");

      -- Test 11: Load 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "LOAD2 - Reset not set");
      assert_true(O_enable_ALU='0',      "LOAD2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "LOAD2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "LOAD2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "LOAD2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "LOAD2 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "LOAD2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "LOAD2 - No we CFG_MEM");
      assert_true(O_REG_we='1',          "LOAD2 - WE REG");
      assert_true(O_PC_OPCode=PC_OP_INC, "LOAD2 - PC operation: INC");

      -- Test 12: Fetch 1 from Load
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 LOAD - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 LOAD - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 LOAD - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 LOAD - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 LOAD - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 LOAD - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 LOAD - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 LOAD - No we CFG_MEM");
      assert_true(O_REG_we='0',          "FETCH1 LOAD - No we REG");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 LOAD - PC operation: INC");

      -- (Reset wait until state decode)
      wait_cycles(clock, 2);
      -- Test 13: Bin 1
      I_op_code <= OP_ADD;
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "BIN1 - Reset not set");
      assert_true(O_enable_ALU='0',      "BIN1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "BIN1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "BIN1 - No enable DECODER");
      assert_true(O_enable_PC='0',       "BIN1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "BIN1 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "BIN1 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "BIN1 - No we CFG_MEM");
      assert_true(O_REG_we='0',          "BIN1 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "BIN1 - PC operation: NOP");

      -- Test 14: Bin 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "BIN2 - Reset not set");
      assert_true(O_enable_ALU='1',      "BIN2 - Enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "BIN2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "BIN2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "BIN2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "BIN2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "BIN2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "BIN2 - No we CFG_MEM");
      assert_true(O_REG_we='0',          "BIN2 - No we REG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "BIN2 - PC operation: NOP");

      -- Test 15: Bin 3
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "BIN3 - Reset not set");
      assert_true(O_enable_ALU='0',      "BIN3 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "BIN3 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "BIN3 - No enable DECODER");
      assert_true(O_enable_PC='0',       "BIN3 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "BIN3 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "BIN3 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "BIN3 - No we CFG_MEM");
      assert_true(O_REG_we='1',          "BIN3 - WE REG");
      assert_true(O_PC_OPCode=PC_OP_INC, "BIN3 - PC operation: INC");


      -- Test 16: Fetch 1 from Bin
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 LOAD - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 LOAD - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 LOAD - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 LOAD - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 LOAD - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 LOAD - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 LOAD - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 LOAD - No we CFG_MEM");
      assert_true(O_REG_we='0',          "FETCH1 LOAD - No we REG");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 LOAD - PC operation: INC");

      running <= false;
      report "Control Unit: Testbench complete";
    end process;

end arch_control_unit_tb;
