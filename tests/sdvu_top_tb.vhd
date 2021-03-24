-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for SDVU + Memories

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

entity sdvu_top_tb is
end sdvu_top_tb;

-- =================
--   Architecture
-- =================

architecture arch_sdvu_top_tb of sdvu_top_tb is
  -- Clock, Reset and Enable signals
  constant HALF_PERIOD : time       := 5 ns; -- Clock half period
  signal clock         : std_logic  := '0';  -- Clock signal
  signal reset         : std_logic  := '0';  -- Reset signal
  signal running       : boolean    := true; -- Running flag, Simulation continues while true

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
      dut: entity work.sdvu_top(arch_sdvu_top)
        port map (
          I_clock           => clock,
          I_reset           => reset
        );

      -- Stimulus process
      StimulusProcess: process
      begin
        wait until reset = '0';
        report "SDVU TOP: Running testbench";
        wait_cycles(clock, 200);
        running <= false;
        report "SDVU: Testbench complete";
      end process;

end arch_sdvu_top_tb;
