-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for SDVU

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

entity sdvu_tb is
end sdvu_tb;

-- =================
--   Architecture
-- =================

architecture arch_sdvu_tb of sdvu_tb is
  -- Clock, Reset and Enable signals
  constant HALF_PERIOD : time       := 5 ns; -- Clock half period
  signal clock         : std_logic  := '0';  -- Clock signal
  signal reset         : std_logic  := '0';  -- Reset signal
  signal running       : boolean    := true; -- Running flag, Simulation continues while true

    -- Signals for entity
    signal O_idle                : STD_LOGIC;
    -- CFG MEM Related
    signal I_CFG_MEM_data        : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
    signal O_enable_CFG_MEM      : STD_LOGIC;
    signal O_return_config       : STD_LOGIC;
    signal O_CFG_MEM_we          : STD_LOGIC;
    signal O_CFG_MEM_RAA         : STD_LOGIC;
    signal O_CFG_MEM_type        : STD_LOGIC_VECTOR(1 downto 0);
    signal O_CFG_MEM_address     : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
    signal O_CFG_MEM_address_RAA : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
    signal O_CFG_MEM_data        : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
    -- PRG MEM Related
    signal I_PRG_MEM_data        : STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
    signal O_enable_PRG_MEM      : STD_LOGIC;
    signal O_PRG_MEM_PC          : STD_LOGIC_VECTOR(PC_SIZE-1 downto 0);


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
      dut: entity work.sdvu(arch_sdvu)
        port map (
          I_clock               => clock,
          I_reset               => reset,
          O_idle                => O_idle,
          I_CFG_MEM_data        => I_CFG_MEM_data,
          O_enable_CFG_MEM      => O_enable_CFG_MEM,
          O_return_config       => O_return_config,
          O_CFG_MEM_we          => O_CFG_MEM_we,
          O_CFG_MEM_RAA         => O_CFG_MEM_RAA,
          O_CFG_MEM_type        => O_CFG_MEM_type,
          O_CFG_MEM_address     => O_CFG_MEM_address,
          O_CFG_MEM_address_RAA => O_CFG_MEM_address_RAA,
          O_CFG_MEM_data        => O_CFG_MEM_data,
          I_PRG_MEM_data        => I_PRG_MEM_data,
          O_enable_PRG_MEM      => O_enable_PRG_MEM,
          O_PRG_MEM_PC          => O_PRG_MEM_PC
        );

      -- Stimulus process
      StimulusProcess: process
      begin
        wait until reset = '0';
        report "SDVU: Running testbench";
        wait_cycles(clock, 4);
        I_PRG_MEM_data <= OP_ADD & CFG_II & "1111" & "00000000001" & "00000000010";
        wait_cycles(clock, 6);
        I_PRG_MEM_data <= OP_ADD & CFG_II & "1110" & "00000000100" & "00000000011";
        wait_cycles(clock, 6);
        I_PRG_MEM_data <= OP_ADD & CFG_RR & "1101" & "00000001111" & "00000001110";
        wait_cycles(clock, 7);

        I_PRG_MEM_data <= OP_LOAD & LOAD_ADR & TYPE_BOOL & "1100" & "00000000000000001111";
        I_CFG_MEM_data <= X"00000001";
        wait_cycles(clock, 6);
        I_PRG_MEM_data <= OP_JMP & "0000000000000000000000000011";
        wait_cycles(clock, 6);
        running <= false;
        report "SDVU: Testbench complete";
      end process;

end arch_sdvu_tb;
