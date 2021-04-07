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
    signal I_cfg_mask       : STD_LOGIC_VECTOR(1 downto 0);
    signal I_JMP_condition  : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);

    signal O_reset          : STD_LOGIC;
    signal O_enable_ALU     : STD_LOGIC;
    signal O_enable_CFG_MEM : STD_LOGIC;
    signal O_enable_DECODER : STD_LOGIC;
    signal O_enable_PC      : STD_LOGIC;
    signal O_enable_PRG_MEM : STD_LOGIC;
    signal O_enable_REG     : STD_LOGIC;

    signal O_return_config  : STD_LOGIC;
    signal O_CFG_MEM_we     : STD_LOGIC;
    signal O_CFG_MEM_RAA    : STD_LOGIC;
    signal O_REG_we_ALU     : STD_LOGIC;
    signal O_REG_we_LOAD    : STD_LOGIC;
    signal O_REG_we_MOVIMM  : STD_LOGIC;
    signal O_REG_we_MOVREG  : STD_LOGIC;

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
        I_cfg_mask       => I_cfg_mask,
        I_PC_OPCode      => O_PC_OPCode,
        I_CFG_MEM_RAA    => O_CFG_MEM_RAA,
        I_JMP_condition  => I_JMP_condition,

        O_reset          => O_reset,
        O_enable_ALU     => O_enable_ALU,
        O_enable_CFG_MEM => O_enable_CFG_MEM,
        O_enable_DECODER => O_enable_DECODER,
        O_enable_PC      => O_enable_PC,
        O_enable_PRG_MEM => O_enable_PRG_MEM,
        O_enable_REG     => O_enable_REG,

        O_return_config  => O_return_config,
        O_CFG_MEM_we     => O_CFG_MEM_we,
        O_CFG_MEM_RAA    => O_CFG_MEM_RAA,
        O_REG_we_ALU     => O_REG_we_ALU,
        O_REG_we_LOAD    => O_REG_we_LOAD,
        O_REG_we_MOVIMM  => O_REG_we_MOVIMM,
        O_REG_we_MOVREG  => O_REG_we_MOVREG,

        O_PC_OPCode      => O_PC_OPCode
      );


    -- Stimulus process
    StimulusProcess: process
    begin
      report "Control Unit: Running testbench";
      -- TESTING OPERATIONS
      -- Test 1: Initial reset
      -- assert_true(external, STATE_RESET1)
      wait_cycles(clock, 2);
      assert_true(O_reset='1',             "RESET1 - Reset set");
      assert_true(O_enable_ALU='0',        "RESET1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',    "RESET1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',    "RESET1 - No enable DECODER");
      assert_true(O_enable_PC='0',         "RESET1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',    "RESET1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',        "RESET1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',        "RESET1 - No we CFG_MEM");
      assert_true(O_REG_we_ALU='0',        "RESET1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',       "RESET1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',     "RESET1 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',     "RESET1 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_RESET, "RESET1 - PC operation: RESET");
      assert_true(O_CFG_MEM_RAA='0',       "RESET1 - RAA mode not enabled");
      assert_true(O_return_config='0',     "RESET1 - No config return");

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
      assert_true(O_CFG_MEM_RAA='0',       "RESET2 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',        "RESET2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',       "RESET2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',     "RESET2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',     "RESET2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP,   "RESET2 - PC operation: NOP");
      assert_true(O_return_config='0',     "RESET2 - No config return");

      -- Test 3: Fetch1
      wait_cycles(clock, 1);
      assert_true(O_reset='0',             "FETCH1 - Reset not set");
      assert_true(O_enable_ALU='0',        "FETCH1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',    "FETCH1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',    "FETCH1 - No enable DECODER");
      assert_true(O_enable_PC='1',         "FETCH1 - Enable PC");
      assert_true(O_enable_PRG_MEM='0',    "FETCH1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',        "FETCH1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',        "FETCH1 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',       "FETCH1 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',        "FETCH1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',       "FETCH1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',     "FETCH1 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',     "FETCH1 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP,   "FETCH1 - PC operation: NOP");
      assert_true(O_return_config='0',     "FETCH1 - No config return");


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
      assert_true(O_CFG_MEM_RAA='0',     "FETCH2 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',      "FETCH2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "FETCH2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "FETCH2 - PC operation: NOP");
      assert_true(O_return_config='0',   "FETCH2 - No config return");

      -- Test 5: Decode 1
      I_op_code <= OP_JMP;
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "DECODE1 - Reset not set");
      assert_true(O_enable_ALU='0',      "DECODE1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "DECODE1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='1',  "DECODE1 - Enable DECODER");
      assert_true(O_enable_PC='0',       "DECODE1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "DECODE1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "DECODE1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "DECODE1 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "DECODE1 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',      "DECODE1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "DECODE1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "DECODE1 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "DECODE1 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "DECODE1 - PC operation: NOP");
      assert_true(O_return_config='0',   "DECODE1 - No config return");

      -- Test 6: Decode 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "DECODE2 - Reset not set");
      assert_true(O_enable_ALU='0',         "DECODE2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "DECODE2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "DECODE2 - Enable DECODER");
      assert_true(O_enable_PC='0',          "DECODE2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',     "DECODE2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "DECODE2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "DECODE2 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',        "DECODE2 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',         "DECODE2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',        "DECODE2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',      "DECODE2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',      "DECODE2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP,    "DECODE2 - PC operation: NOP");
      assert_true(O_return_config='0',      "DECODE2 - No config return");

      -- Test 7: JMP 1
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "JMP1 - Reset not set");
      assert_true(O_enable_ALU='0',         "JMP1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "JMP1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "JMP1 - No enable DECODER");
      assert_true(O_enable_PC='0',          "JMP1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',     "JMP1 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',         "JMP1 - Enable REG");
      assert_true(O_CFG_MEM_we='0',         "JMP1 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',        "JMP1 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',         "JMP1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',        "JMP1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',      "JMP1 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',      "JMP1 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP,    "JMP1 - PC operation: NOP");
      assert_true(O_return_config='0',      "JMP1 - No config return");

      -- Test 8: JMP 2
      I_JMP_condition <= X"00000001";
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "JMP2 - Reset not set");
      assert_true(O_enable_ALU='0',         "JMP2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "JMP2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "JMP2 - No enable DECODER");
      assert_true(O_enable_PC='0',          "JMP2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',     "JMP2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "JMP2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "JMP2 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',        "JMP2 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',         "JMP2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',        "JMP2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',      "JMP2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',      "JMP2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_ASSIGN, "JMP2 - PC operation: ASSIGN");
      assert_true(O_return_config='0',      "JMP2 - No config return");

      -- Test 9: Fetch 1 from JMP - ASSIGN
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "FETCH1 JMP ASSIGN - Reset not set");
      assert_true(O_enable_ALU='0',         "FETCH1 JMP ASSIGN - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "FETCH1 JMP ASSIGN - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "FETCH1 JMP ASSIGN - No enable DECODER");
      assert_true(O_enable_PC='1',          "FETCH1 JMP ASSIGN - Enable PC");
      assert_true(O_enable_PRG_MEM='0',     "FETCH1 JMP ASSIGN - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "FETCH1 JMP ASSIGN - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "FETCH1 JMP ASSIGN - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',        "FETCH1 JMP ASSIGN - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',         "FETCH1 JMP ASSIGN - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',        "FETCH1 JMP ASSIGN - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',      "FETCH1 JMP ASSIGN - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',      "FETCH1 JMP ASSIGN - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_ASSIGN, "FETCH1 JMP ASSIGN - PC operation: ASSIGN");
      assert_true(O_return_config='0',      "FETCH1 JMP ASSIGN - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 4);

      -- Test 10: JMP 2
      I_JMP_condition <= X"00000000";
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "JMP2 - Reset not set");
      assert_true(O_enable_ALU='0',         "JMP2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "JMP2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "JMP2 - No enable DECODER");
      assert_true(O_enable_PC='0',          "JMP2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',     "JMP2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "JMP2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "JMP2 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',        "JMP2 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',         "JMP2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',        "JMP2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',      "JMP2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',      "JMP2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC,    "JMP2 - PC operation: INC");
      assert_true(O_return_config='0',      "JMP2 - No config return");

      -- Test 11: Fetch 1 from JMP - INC
      wait_cycles(clock, 1);
      assert_true(O_reset='0',              "FETCH1 JMP INC - Reset not set");
      assert_true(O_enable_ALU='0',         "FETCH1 JMP INC - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',     "FETCH1 JMP INC - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',     "FETCH1 JMP INC - No enable DECODER");
      assert_true(O_enable_PC='1',          "FETCH1 JMP INC - Enable PC");
      assert_true(O_enable_PRG_MEM='0',     "FETCH1 JMP INC - No enable PRG_MEM");
      assert_true(O_enable_REG='0',         "FETCH1 JMP INC - No enable REG");
      assert_true(O_CFG_MEM_we='0',         "FETCH1 JMP INC - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',        "FETCH1 JMP INC - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',         "FETCH1 JMP INC - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',        "FETCH1 JMP INC - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',      "FETCH1 JMP INC - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',      "FETCH1 JMP INC - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC,    "FETCH1 JMP INC - PC operation: INC");
      assert_true(O_return_config='0',      "FETCH1 JMP INC - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 2);

      -- Test 12: Store ADR
      I_op_code <= OP_STORE;
      I_cfg_mask <= STORE_ADR;
      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "STORE1 - Reset not set");
      assert_true(O_enable_ALU='0',      "STORE1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "STORE1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "STORE1 - No enable DECODER");
      assert_true(O_enable_PC='0',       "STORE1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "STORE1 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "STORE1 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "STORE1 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "STORE1 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',      "STORE1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "STORE1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "STORE1 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "STORE1 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "STORE1 - PC operation: NOP");
      assert_true(O_return_config='0',   "STORE1 - No config return");

      -- Test 13: Store 2 from STORE ADR
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "STORE2 - Reset not set");
      assert_true(O_enable_ALU='0',      "STORE2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='1',  "STORE2 - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "STORE2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "STORE2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "STORE2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "STORE2 - No enable REG");
      assert_true(O_CFG_MEM_we='1',      "STORE2 - WE CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "STORE2 - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',      "STORE2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "STORE2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "STORE2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "STORE2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "STORE2 - PC operation: INC");
      assert_true(O_return_config='0',   "STORE2 - No config return");

      -- Test 14: Fetch 1 from STORE ADR
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 STORE - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 STORE - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 STORE - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 STORE - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 STORE - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 STORE - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 STORE - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 STORE - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "FETCH1 STORE - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',      "FETCH1 STORE - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH1 STORE - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH1 STORE - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "FETCH1 STORE - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 STORE - PC operation: INC");
      assert_true(O_return_config='0',   "FETCH1 STORE - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 2);
      -- Test 15: Store RAA
      I_op_code <= OP_STORE;
      I_cfg_mask <= STORE_RAA;
      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "STORERAA - Reset not set");
      assert_true(O_enable_ALU='0',      "STORERAA - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "STORERAA - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "STORERAA - No enable DECODER");
      assert_true(O_enable_PC='0',       "STORERAA - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "STORERAA - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "STORERAA - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "STORERAA - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='1',     "STORERAA - RAA mode enabled");
      assert_true(O_REG_we_ALU='0',      "STORERAA - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "STORERAA - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "STORERAA - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "STORERAA - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "STORERAA - PC operation: NOP");
      assert_true(O_CFG_MEM_RAA='1',     "STORERAA - RAA mode enabled");
      assert_true(O_return_config='0',   "STORERAA - No config return");

      -- Test 16: Store 2 from STORE ADR
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "STORE2 RAA - Reset not set");
      assert_true(O_enable_ALU='0',      "STORE2 RAA - No enable ALU");
      assert_true(O_enable_CFG_MEM='1',  "STORE2 RAA - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "STORE2 RAA - No enable DECODER");
      assert_true(O_enable_PC='0',       "STORE2 RAA - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "STORE2 RAA - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "STORE2 RAA - No enable REG");
      assert_true(O_CFG_MEM_we='1',      "STORE2 RAA - WE CFG_MEM");
      assert_true(O_CFG_MEM_RAA='1',     "STORE2 RAA - RAA mode not enabled");
      assert_true(O_REG_we_ALU='0',      "STORE2 RAA - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "STORE2 RAA - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "STORE2 RAA - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "STORE2 RAA - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "STORE2 RAA - PC operation: INC");
      assert_true(O_return_config='0',   "STORE2 RAA - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 3);
      -- Test 17: Load 1
      I_op_code <= OP_LOAD;
      I_cfg_mask <= LOAD_ADR;

      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "LOAD1 - Reset not set");
      assert_true(O_enable_ALU='0',      "LOAD1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='1',  "LOAD1 - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "LOAD1 - No enable DECODER");
      assert_true(O_enable_PC='0',       "LOAD1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "LOAD1 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "LOAD1 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "LOAD1 - No we CFG_MEM");
      assert_true(O_REG_we_ALU='0',      "LOAD1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "LOAD1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "LOAD1 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "LOAD1 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "LOAD1 - PC operation: NOP");
      assert_true(O_CFG_MEM_RAA='0',     "LOAD1 - RAA mode not enabled");
      assert_true(O_return_config='0',   "LOAD1 - No config return");

      -- Test 18: Load 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "LOAD2 - Reset not set");
      assert_true(O_enable_ALU='0',      "LOAD2 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "LOAD2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "LOAD2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "LOAD2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "LOAD2 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "LOAD2 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "LOAD2 - No we CFG_MEM");
      assert_true(O_REG_we_ALU='0',      "LOAD2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='1',     "LOAD2 - Enable we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "LOAD2 - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "LOAD2 - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "LOAD2 - PC operation: INC");
      assert_true(O_return_config='0',   "LOAD2 - No config return");

      -- Test 19: Fetch 1 from Load
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 LOAD - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 LOAD - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 LOAD - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 LOAD - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 LOAD - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 LOAD - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 LOAD - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 LOAD - No we CFG_MEM");
      assert_true(O_REG_we_ALU='0',      "FETCH1 LOAD - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH1 LOAD - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH1 LOAD - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "FETCH1 LOAD - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 LOAD - PC operation: INC");
      assert_true(O_return_config='0',   "FETCH1 LOAD - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 2);
      -- Test 20: Load RAA
      I_op_code <= OP_LOAD;
      I_cfg_mask <= LOAD_RAA;

      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "LOAD RAA - Reset not set");
      assert_true(O_enable_ALU='0',      "LOAD RAA - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "LOAD RAA - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "LOAD RAA - No enable DECODER");
      assert_true(O_enable_PC='0',       "LOAD RAA - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "LOAD RAA - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "LOAD RAA - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "LOAD RAA - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='1',     "LOAD RAA - RAA mode enabled");
      assert_true(O_REG_we_ALU='0',      "LOAD RAA - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "LOAD RAA - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "LOAD RAA - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "LOAD RAA - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "LOAD RAA - PC operation: NOP");
      assert_true(O_return_config='0',   "LOAD RAA - No config return");

      -- Test 21: Load 1 from RAA
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "LOAD1 from RAA - Reset not set");
      assert_true(O_enable_ALU='0',      "LOAD1 from RAA - No enable ALU");
      assert_true(O_enable_CFG_MEM='1',  "LOAD1 from RAA - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "LOAD1 from RAA - No enable DECODER");
      assert_true(O_enable_PC='0',       "LOAD1 from RAA - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "LOAD1 from RAA - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "LOAD1 from RAA - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "LOAD1 from RAA - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='1',     "LOAD1 from RAA - RAA mode enabled");
      assert_true(O_REG_we_ALU='0',      "LOAD1 from RAA - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "LOAD1 from RAA - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "LOAD1 from RAA - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "LOAD1 from RAA - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_NOP, "LOAD1 from RAA - PC operation: NOP");
      assert_true(O_return_config='0',   "LOAD1 from RAA - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 4);
      -- Test 22: MOV IMM
      I_op_code <= OP_LOAD;
      I_cfg_mask <= LOAD_IMM;

      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "MOV IMM - Reset not set");
      assert_true(O_enable_ALU='0',      "MOV IMM - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "MOV IMM - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "MOV IMM - No enable DECODER");
      assert_true(O_enable_PC='0',       "MOV IMM - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "MOV IMM - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "MOV IMM - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "MOV IMM - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "MOV IMM - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "MOV IMM - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "MOV IMM - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='1',   "MOV IMM - WE REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "MOV IMM - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "MOV IMM - PC operation: INC");
      assert_true(O_return_config='0',   "MOV IMM - No config return");

      -- Test 23: Fetch 1 from MOV IMM
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 MOVIMM - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 MOVIMM - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 MOVIMM - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 MOVIMM - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 MOVIMM - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 MOVIMM - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 MOVIMM - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 MOVIMM - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "FETCH1 MOVIMM - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "FETCH1 MOVIMM - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH1 MOVIMM - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH1 MOVIMM - No we REG MOVREG");
      assert_true(O_REG_we_MOVREG='0',   "FETCH1 MOVIMM - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 MOVIMM - PC operation: INC");
      assert_true(O_return_config='0',   "FETCH1 MOVIMM - No config return");

      -- (Re-fetch, wait until state decode2)
      wait_cycles(clock, 2);
      -- Test 24: MOVREG
      I_op_code <= OP_LOAD;
      I_cfg_mask <= LOAD_REG;

      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "MOV REG - Reset not set");
      assert_true(O_enable_ALU='0',      "MOV REG - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "MOV REG - Enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "MOV REG - No enable DECODER");
      assert_true(O_enable_PC='0',       "MOV REG - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "MOV REG - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "MOV REG - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "MOV REG - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "MOV REG - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "MOV REG - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "MOV REG - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "MOV REG - WE REG MOVREG");
      assert_true(O_REG_we_MOVREG='1',   "MOV REG - No we REG MOVIMM");
      assert_true(O_PC_OPCode=PC_OP_INC, "MOV REG - PC operation: INC");
      assert_true(O_return_config='0',   "MOV REG - No config return");

      -- Test 25: Fetch 1 from MOV REG
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 MOVREG - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 MOVREG - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 MOVREG - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 MOVREG - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 MOVREG - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 MOVREG - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 MOVREG - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 MOVREG - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "FETCH1 MOVREG - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "FETCH1 MOVREG - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH1 MOVREG - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH1 MOVREG - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "FETCH1 MOVREG - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 MOVREG - PC operation: INC");
      assert_true(O_return_config='0',   "FETCH1 MOVREG - No config return");


      -- (Reset wait until state decode2)
      wait_cycles(clock, 2);
      -- Test 26: Bin 1
      I_op_code <= OP_ADD;
      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "BIN1 - Reset not set");
      assert_true(O_enable_ALU='0',      "BIN1 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "BIN1 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "BIN1 - No enable DECODER");
      assert_true(O_enable_PC='0',       "BIN1 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "BIN1 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "BIN1 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "BIN1 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "BIN1 - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "BIN1 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "BIN1 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "BIN1 - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "BIN1 - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "BIN1 - PC operation: NOP");
      assert_true(O_return_config='0',   "BIN1 - No config return");

      -- Test 27: Bin 2
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "BIN2 - Reset not set");
      assert_true(O_enable_ALU='1',      "BIN2 - Enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "BIN2 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "BIN2 - No enable DECODER");
      assert_true(O_enable_PC='0',       "BIN2 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "BIN2 - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "BIN2 - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "BIN2 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "BIN2 MOVIMM - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "BIN2 - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "BIN2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "BIN2 - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "BIN2 - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "BIN2 - PC operation: NOP");
      assert_true(O_return_config='0',   "BIN2 - No config return");

      -- Test 28: Bin 3
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "BIN3 - Reset not set");
      assert_true(O_enable_ALU='0',      "BIN3 - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "BIN3 - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "BIN3 - No enable DECODER");
      assert_true(O_enable_PC='0',       "BIN3 - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "BIN3 - No enable PRG_MEM");
      assert_true(O_enable_REG='1',      "BIN3 - Enable REG");
      assert_true(O_CFG_MEM_we='0',      "BIN3 - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "BIN3 - No RAA mode");
      assert_true(O_REG_we_ALU='1',      "BIN2 - WE REG ALU");
      assert_true(O_REG_we_LOAD='0',     "BIN2 - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "BIN2 - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "BIN2 - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_INC, "BIN3 - PC operation: INC");
      assert_true(O_return_config='0',   "BIN3 - No config return");

      -- Test 29: Fetch 1 from Bin
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 BIN - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 BIN - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 BIN - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 BIN - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 BIN - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 BIN - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 BIN - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 BIN - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "FETCH1 BIN - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "FETCH1 BIN - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH1 BIN - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH1 BIN - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "FETCH1 BIN - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 BIN - PC operation: INC");
      assert_true(O_return_config='0',   "FETCH1 BIN - No config return");

      -- (Reset wait until state decode2)
      wait_cycles(clock, 2);
      -- Test 30: ENDGA
      I_op_code <= OP_ENDGA;
      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "ENDGA - Reset not set");
      assert_true(O_enable_ALU='0',      "ENDGA - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "ENDGA - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "ENDGA - No enable DECODER");
      assert_true(O_enable_PC='0',       "ENDGA - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "ENDGA - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "ENDGA - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "ENDGA - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "ENDGA - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "ENDGA - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "ENDGA - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "ENDGA - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "ENDGA - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_INC, "ENDGA - PC operation: INC");
      assert_true(O_return_config='1',   "ENDGA - Config return enabled");

      -- Test 31: Fetch 1 from ENDGA
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "FETCH1 ENDGA - Reset not set");
      assert_true(O_enable_ALU='0',      "FETCH1 ENDGA - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "FETCH1 ENDGA - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "FETCH1 ENDGA - No enable DECODER");
      assert_true(O_enable_PC='1',       "FETCH1 ENDGA - Enable PC");
      assert_true(O_enable_PRG_MEM='0',  "FETCH1 ENDGA - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "FETCH1 ENDGA - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "FETCH1 ENDGA - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "FETCH1 ENDGA - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "FETCH1 ENDGA - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "FETCH1 ENDGA - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "FETCH1 ENDGA - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "FETCH1 ENDGA - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_INC, "FETCH1 ENDGA - PC operation: INC");
      assert_true(O_return_config='0',   "FETCH1 ENDGA - No config return");

      -- (Reset wait until state decode2)
      wait_cycles(clock, 2);
      -- Test 33: NOP
      I_op_code <= OP_NOP;
      wait_cycles(clock, 2);
      assert_true(O_reset='0',           "NOP - Reset not set");
      assert_true(O_enable_ALU='0',      "NOP - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "NOP - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "NOP - No enable DECODER");
      assert_true(O_enable_PC='0',       "NOP - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "NOP - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "NOP - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "NOP - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "NOP - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "NOP - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "NOP - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "NOP - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "NOP - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "NOP - PC operation: NOP");
      assert_true(O_return_config='0',   "NOP - No config return");

      -- Test 34: END
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "END - Reset not set");
      assert_true(O_enable_ALU='0',      "END - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "END - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "END - No enable DECODER");
      assert_true(O_enable_PC='0',       "END - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "END - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "END - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "END - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "END - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "END - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "END - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "END - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "END - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "NOP - PC operation: NOP");
      assert_true(O_return_config='0',   "END - No config return");

      -- Test 35: Another END
      wait_cycles(clock, 1);
      assert_true(O_reset='0',           "END END - Reset not set");
      assert_true(O_enable_ALU='0',      "END END - No enable ALU");
      assert_true(O_enable_CFG_MEM='0',  "END END - No enable CFG_MEM");
      assert_true(O_enable_DECODER='0',  "END END - No enable DECODER");
      assert_true(O_enable_PC='0',       "END END - No enable PC");
      assert_true(O_enable_PRG_MEM='0',  "END END - No enable PRG_MEM");
      assert_true(O_enable_REG='0',      "END END - No enable REG");
      assert_true(O_CFG_MEM_we='0',      "END END - No we CFG_MEM");
      assert_true(O_CFG_MEM_RAA='0',     "END END - No RAA mode");
      assert_true(O_REG_we_ALU='0',      "END END - No we REG ALU");
      assert_true(O_REG_we_LOAD='0',     "END END - No we REG LOAD");
      assert_true(O_REG_we_MOVIMM='0',   "END END - No we REG MOVIMM");
      assert_true(O_REG_we_MOVREG='0',   "END END - No we REG MOVREG");
      assert_true(O_PC_OPCode=PC_OP_NOP, "NOP - PC operation: NOP");
      assert_true(O_return_config='0',   "END END - No config return");

      running <= false;
      report "Control Unit: Testbench complete";
    end process;

end arch_control_unit_tb;
