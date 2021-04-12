-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the Coordinator

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.sdvu_constants.all;
use work.tb_helpers.all;

entity coordinator_tb is
end coordinator_tb;

-- =================
--   Architecture
-- =================

architecture arch_coordinator_tb of coordinator_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clock   : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    signal I_clock           : STD_LOGIC;
    signal I_binaries        : prog_memory_array;
    signal I_new_config      : STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0);
    signal O_configs         : config_memory_array;
    signal O_changed_configs : STD_LOGIC_VECTOR(CORE_NUMBER-1 downto 0);
    signal adding_0          : prog_memory := (
      X"EBE00060",
      X"A4007000",
      X"EAD00000",
      X"84406A58",
      X"60000001",
      X"C000000D",
      X"E4E00001",
      X"EAC00020",
      X"E0C0000D",
      X"D2C00020",
      X"D2D00000",
      X"D3E00060",
      X"F0000000",
      X"EBE00060",
      X"A4007001",
      X"C0000019",
      X"E4E00002",
      X"EAD00020",
      X"EAC00000",
      X"1000680C",
      X"E0D00000",
      X"D2C00000",
      X"D2D00020",
      X"D3E00060",
      X"F0000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000"
    );
    signal adding_1 : prog_memory := (
      X"EBE00060",
      X"A4007002",
      X"C000000B",
      X"E4E00000",
      X"EAD00020",
      X"EAC00000",
      X"E0C0000D",
      X"D2C00000",
      X"D2D00020",
      X"D3E00060",
      X"F0000000",
      X"EBE00070",
      X"A4007000",
      X"EAD00000",
      X"84406A58",
      X"60000001",
      X"C0000018",
      X"E4E00001",
      X"EAC00040",
      X"E0C0000D",
      X"D2C00040",
      X"D2D00000",
      X"D3E00070",
      X"F0000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000"
    );
    signal adding_2 : prog_memory := (
      X"EBE00070",
      X"A4007001",
      X"C000000C",
      X"E4E00002",
      X"EAD00040",
      X"EAC00000",
      X"1000680C",
      X"E0D00000",
      X"D2C00000",
      X"D2D00040",
      X"D3E00070",
      X"F0000000",
      X"EBE00070",
      X"A4007002",
      X"C0000017",
      X"E4E00000",
      X"EAD00040",
      X"EAC00000",
      X"E0C0000D",
      X"D2C00000",
      X"D2D00040",
      X"D3E00070",
      X"F0000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000",
      X"00000000"
    );


begin
    -- Clock and Reset generation
    ClockProcess : process
    begin
      genClock(clock, running, HALF_PERIOD);
    end process;

    ResetProcess : process
    begin
      genPulse(reset, 10 ns, true);
    end process;

    dut : entity work.coordinator(arch_coordinator)
    port map (
      I_clock           => clock,
      I_reset           => reset,

      I_binaries        => I_binaries,
      I_new_config      => I_new_config,
      O_configs         => O_configs,
      O_changed_configs => O_changed_configs
    );

    -- Stimulus process
    StimulusProcess: process
    begin
      I_binaries(0) <= adding_0;
      I_binaries(1) <= adding_1;
      I_binaries(2) <= adding_2;
      I_new_config <= X"0000000000000000000000000000000000010001000000050000000400000003";
      wait until reset = '0';
      report "Coordinator: Running testbench";

      wait_cycles(clock, 200);
      I_new_config <= X"0000000000000000000000000000000000020002000000060000000500000004";
      running <= false;
      report "Coordinator: Testbench complete";
    end process;

end arch_coordinator_tb;
