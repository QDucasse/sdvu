-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench file for the ALU

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

entity alu_tb is
end alu_tb;

-- =================
--   Architecture
-- =================

architecture arch_alu_tb of alu_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clock   : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Entity Signals
    signal I_op_code : STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
    signal I_cfgMask : STD_LOGIC_VECTOR (1 downto 0);
    signal I_dataA   : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_dataB   : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_immA    : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_immB    : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_address : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_type    : STD_LOGIC_VECTOR (1 downto 0);
    signal O_result  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);

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

      EnableProcess : process
      begin
        genPulse(enable, 20 ns, false);
      end process;

    -- DUT
    dut: entity work.alu(arch_alu)
      port map (
        I_clock   => clock,
        I_enable  => enable,
        I_reset   => reset,
        I_op_code => I_op_code,
        I_cfgMask => I_cfgMask,
        I_dataA   => I_dataA,
        I_dataB   => I_dataB,
        I_immA    => I_immA,
        I_immB    => I_immB,
        I_address => I_address,
        I_type    => I_type,
        O_result  => O_result
      );


    -- Stimulus process
    StimulusProcess: process
      variable cmp : boolean := false;
    begin
      wait until reset = '0';
      wait until enable = '1';
      report "ALU: Running testbench";

      -- TESTING OPERATIONS
      -- Test 1 - Default output
      wait_cycles(clock, 1);
      assert_true(O_result=X"FFFFFFFF", "Default output");

      -- =============
      -- Test 2: ADD
      I_op_code <= OP_ADD;
      I_dataA <= X"0000000E";
      I_immA  <= X"0000000D";
      I_dataB <= X"00000001";
      I_immB  <= X"00000002";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000F", "ADD RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000010", "ADD RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000E", "ADD IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000F", "ADD II");

      -- =============
      -- Test 3: SUB
      I_op_code <= OP_SUB;
      I_dataA <= X"0000000E";
      I_immA  <= X"0000000D";
      I_dataB <= X"00000001";
      I_immB  <= X"00000002";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000D", "SUB RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000C", "SUB RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000C", "SUB IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000B", "SUB II");

      -- =============
      -- Test 3: MUL
      I_op_code <= OP_MUL;
      I_dataA <= X"0000000E";
      I_immA  <= X"0000000D";
      I_dataB <= X"00000001";
      I_immB  <= X"00000002";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000E", "MUL RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000001C", "MUL RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000000D", "MUL IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"0000001A", "MUL II");

      -- =============
      -- Test 4: AND
      I_op_code <= OP_AND;
      I_dataA <= X"00000001";
      I_immA  <= X"00000000";
      I_dataB <= X"00000001";
      I_immB  <= X"00000000";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "AND RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "AND RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "AND IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "AND II");


      -- =============
      -- Test 5: OR
      I_op_code <= OP_OR;
      I_dataA <= X"00000001";
      I_immA  <= X"00000000";
      I_dataB <= X"00000001";
      I_immB  <= X"00000000";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "OR RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "OR RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "OR IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "OR II");

      -- =============
      -- Test 5: LT
      I_op_code <= OP_LT;
      I_dataA <= X"0000000C";
      I_immA  <= X"0000000E";
      I_dataB <= X"0000000D";
      I_immB  <= X"0000000F";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "LT RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "LT RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "LT IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "LT II");

      -- =============
      -- Test 6: GT
      I_op_code <= OP_GT;
      I_dataA <= X"0000000C";
      I_immA  <= X"0000000E";
      I_dataB <= X"0000000D";
      I_immB  <= X"0000000F";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "GT RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "GT RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "GT IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "GT II");

      -- =============
      -- Test 7: EQ
      I_op_code <= OP_EQ;
      I_dataA <= X"0000000C";
      I_immA  <= X"0000000E";
      I_dataB <= X"0000000E";
      I_immB  <= X"0000000C";
      -- RR
      I_cfgMask <= CFG_RR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "EQ RR");
      -- IR
      I_cfgMask <= CFG_RI;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "EQ RI");
      -- RI
      I_cfgMask <= CFG_IR;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "EQ IR");
      -- II
      I_cfgMask <= CFG_II;
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "EQ II");

      -- =============
      -- Test 8: NOT
      I_op_code <= OP_NOT;
      I_dataA <= X"0000000C";
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000000", "NOT from true");

      I_dataA <= X"00000000";
      wait_cycles(clock, 1);
      assert_true(O_result=X"00000001", "NOT from false");


      running <= false;
      report "ALU: Testbench complete";
    end process;

end arch_alu_tb;
