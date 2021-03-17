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
    signal clock     : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

     -- Entity Signals
     signal O_state : STD_LOGIC_VECTOR (1 downto 0);


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
          I_clock   => clock,
          I_reset => reset,
          O_state => O_state
        );

    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset = '0';
      report "CONTROL_UNIT: Running testbench";
      -- TESTING OPERATIONS

      -- Test 1: Initial decode
      wait_cycles(1);
      if (O_state=CONTROL_UNIT_DECODE) then report "Test INITIAL DECODE: Passed" severity NOTE;
        else report "Test INITIAL DECODE: Failed" severity FAILURE;
      end if;

      -- Test 2: Decode -> Reg Read
      wait_cycles(1);
      if (O_state=CONTROL_UNIT_REGREAD) then report "Test DECODE REGREAD: Passed" severity NOTE;
        else report "Test DECODE REGREAD: Failed" severity FAILURE;
      end if;

      -- Test 3: Reg Read -> ALU
      wait_cycles(1);
      if (O_state=CONTROL_UNIT_ALU) then report "Test REGREAD ALU: Passed" severity NOTE;
        else report "Test REGREAD ALU: Failed" severity FAILURE;
      end if;

      -- Test 4: ALU -> Reg Write
      wait_cycles(1);
      if (O_state=CONTROL_UNIT_REGWRITE) then report "Test ALU REGWRITE: Passed" severity NOTE;
        else report "Test ALU REGWRITE: Failed" severity FAILURE;
      end if;

      -- Test 5: Reg Write -> Decode
      wait_cycles(1);
      if (O_state=CONTROL_UNIT_DECODE) then report "Test REGWRITE DECODE: Passed" severity NOTE;
        else report "Test REGWRITE DECODE: Failed" severity FAILURE;
      end if;

      running <= false;
      report "PC: Testbench complete";
    end process;

end arch_control_unit_tb;
