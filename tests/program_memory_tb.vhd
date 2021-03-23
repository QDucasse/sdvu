-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the ram entity.

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

entity program_memory_tb is
end program_memory_tb;

-- =================
--   Architecture
-- =================

architecture arch_program_memory_tb of program_memory_tb is
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns;       -- Clock half period
    signal clock         : std_logic  := '0';  -- Clock signal
    signal reset         : std_logic  := '0';  -- Reset signal
    signal enable        : std_logic  := '0';  -- Enable signal
    signal running       : boolean    := true; -- Running flag, Simulation continues while true

    -- Signals for entity
    signal I_PC     : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0) := X"0000";
    signal O_data   : STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);

    -- Internal memory as an external

    begin
      -- Clock, Reset and Enable generation
      ClockProcess : process
      begin
        genClock(clock, running, HALF_PERIOD);
      end process;

      EnableProcess : process
      begin
        genPulse(enable, 20 ns, false);
      end process;

    -- DUT
    dut: entity work.program_memory(arch_program_memory)
      port map (
        I_clock  => clock,
        I_reset  => reset,
        I_enable => enable,
        I_PC     => I_PC,
        O_data   => O_data
      );

    -- Stimulus process
    StimulusProcess: process
      -- External to access the internal memory object
      type memory_file is array (0 to 2**PROG_MEM_SIZE-1) of STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
      -- alias mem_bank is <<signal dut.memory_bank : memory_file>>;
    begin
      reset <= '0';
      wait until enable = '1';
      report "Program Memory: Running testbench";

      -- Test 1: Fetch first instruction
      I_PC <= X"0000";
      wait_cycles(clock, 1);
      assert_true(O_data=X"DBE00060", "Fetch first instruction");

      -- Test 1: Fetch second instruction
      I_PC <= X"0001";
      wait_cycles(clock, 1);
      assert_true(O_data=X"94007000", "Fetch second instruction");

      -- Test Reset
      reset <= '1';
      wait_cycles(clock, 1);

      I_PC <= X"0002";
      reset <= '0';
      wait_cycles(clock, 1);
      assert_true(O_data=X"00000000", "Reset");

      running <= false;
      report "Program Memory: Testbench complete";
    end process;

end arch_program_memory_tb;
