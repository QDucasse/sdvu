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

  signal I_new_config    : STD_LOGIC_VECTOR (2** CFG_MEM_SIZE-1 downto 0);
  signal I_init_bin      : STD_LOGIC;
  signal I_binary        : prog_memory;
  signal O_idle          : STD_LOGIC;
  signal O_return_config : STD_LOGIC;
  signal O_config        : STD_LOGIC_VECTOR (2**CFG_MEM_SIZE-1 downto 0);

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
          I_clock         => clock,
          I_reset         => reset,
          I_init_bin      => I_init_bin,
          I_binary        => I_binary,
          I_new_config    => I_new_config,
          O_idle          => O_idle,
          O_return_config => O_return_config,
          O_config        => O_config
        );


      -- Stimulus process
      StimulusProcess: process
        constant ZERO : STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0) := (others => '0');
      begin

        I_new_config <= X"0000000000000000000000000000000000010001000000050000000400000003";
        wait until reset = '0';
        report "SDVU TOP: Running testbench";
        wait_cycles(clock, 10);
        I_new_config <= X"0000000000000000000000000000000000010001000000050000000500000005";
        wait_cycles(clock, 200);
        -- wait until O_idle = '1';
        running <= false;
        report "SDVU: Testbench complete";
      end process;

end arch_sdvu_top_tb;
