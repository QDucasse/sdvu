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

entity pc_tb is
end pc_tb;

-- =================
--   Architecture
-- =================

architecture arch_pc_tb of pc_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clock   : std_logic  := '0';  -- Clock signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

     -- Entity Signals
     signal I_newPC     : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
     signal I_PC_OPCode : STD_LOGIC_VECTOR (PC_OP_SIZE-1 downto 0);
     signal O_PC        : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);

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
    dut: entity work.pc(arch_pc)
      port map (
        I_clock     => clock,
        I_reset     => reset,
        I_enable    => enable,
        I_newPC     => I_newPC,
        I_PC_OPCode => I_PC_OPCode,
        O_PC        => O_PC
      );

    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset = '0';
      wait until enable = '1';
      report "PC: Running testbench";
      -- TESTING OPERATIONS

      -- Test 1: ASSIGN | Assign PC
      I_PC_OPCode <= PC_OP_ASSIGN;
      I_newPC<= X"FEED";
      wait_cycles(clock, 2);
      assert_true(O_PC=X"FEED", "Assign");

      -- Test 2: NOP | Do nothing
      I_PC_OPCode <= PC_OP_NOP;
      wait_cycles(clock, 1);
      assert_true(O_PC=X"FEED", "No operation");

      -- Test 3: INC | Increment the PC
      I_PC_OPCode <= PC_OP_INC;
      wait_cycles(clock, 1);
      assert_true(O_PC=X"FEEE", "Increment");


      -- Test 4: RESET | Reset the PC
      I_PC_OPCode <= PC_OP_RESET;
      wait_cycles(clock, 1);
      assert_true(O_PC=X"0000", "Reset");

      running <= false;
      report "PC: Testbench complete";
    end process;

end arch_pc_tb;
