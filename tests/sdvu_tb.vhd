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

entity config_memory_tb is
end config_memory_tb;

-- =================
--   Architecture
-- =================

architecture arch_sdvu_tb of sdvu_tb is
  -- Clock, Reset and Enable signals
  constant HALF_PERIOD : time := 5 ns;       -- Clock half period
  signal clock         : std_logic  := '0';  -- Clock signal
  signal reset         : std_logic  := '0';  -- Reset signal
  signal running       : boolean    := true; -- Running flag, Simulation continues while true

    -- Signals for entity
    signal I_CFG_MEM_data    : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
    signal O_enable_CFG_MEM  : STD_LOGIC;
    signal O_CFG_MEM_we      : STD_LOGIC;
    signal O_CFG_MEM_type    : STD_LOGIC_VECTOR(1 downto 0);
    signal O_CFG_MEM_address : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
    signal O_CFG_MEM_data    : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
    signal I_PRG_MEM_data    : STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
    signal O_enable_PRG_MEM  : STD_LOGIC;
    signal O_PRG_MEM_we      : STD_LOGIC;
    signal O_PRG_MEM_PC      : std_logic_vector(PC_SIZE-1 downto 0);

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
      dut: entity work.program_memory(arch_program_memory)
        port map (
          I_clock           => clock,
          I_reset           => reset,

          I_CFG_MEM_data    => I_CFG_MEM_data,
          O_enable_CFG_MEM  => O_enable_CFG_MEM,
          O_CFG_MEM_we      => O_CFG_MEM_we,
          O_CFG_MEM_type    => O_CFG_MEM_type,
          O_CFG_MEM_address => O_CFG_MEM_address,
          O_CFG_MEM_data    => O_CFG_MEM_data,

          I_PRG_MEM_data    => I_PRG_MEM_data,
          O_enable_PRG_MEM  => O_enable_PRG_MEM,
          O_PRG_MEM_we      => O_PRG_MEM_we,
          O_PRG_MEM_PC      => O_PRG_MEM_PC
        );

      -- Stimulus process
      StimulusProcess: process
      begin
        wait until reset = '0';
        wait_cycles(clock, 1);
        report "SDVU: Running testbench";





        running <= false;
        report "SDVU: Testbench complete";
      end process;

end arch_sdvu_tb;
