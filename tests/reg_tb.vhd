-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the Register File

-- =================
--    Libraries
-- =================

library ieee;
use IEEE.std_logic_1164.all;

library work;
use work.sdvu_constants.all;
use work.tb_helpers.all;
-- =================
--      Entity
-- =================

entity reg_tb is
end reg_tb;

-- =================
--   Architecture
-- =================

architecture arch_reg_tb of reg_tb is

    -- Clock and Reset signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clock   : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Signal definitions for the entity
    signal I_we     : STD_LOGIC;
    signal I_selD   : STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
    signal I_selA   : STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
    signal I_selB   : STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
    signal I_dataD  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal O_dataB  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal O_dataA  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal O_dataD  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);

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

   -- Design Under Test (DUT)
   dut: entity work.reg(arch_reg)
     port map (
       I_clock  => clock,
       I_reset  => reset,
       I_enable => enable,
       I_we     => I_we,
       I_selD   => I_selD,
       I_selA   => I_selA,
       I_selB   => I_selB,
       I_dataD  => I_dataD,
       O_dataB  => O_dataB,
       O_dataA  => O_dataA,
       O_dataD  => O_dataD
     );

   -- Stimulus process
   StimulusProcess: process
   begin
      wait until reset = '0';
      wait until enable  = '1';
      report "REGISTER: Running testbench";

      -- Test Write 1: Write to RD - Read RA
      -- Write phase
      I_selD <= X"4";         -- Destination: R4
      I_dataD <= X"0000CAFE"; -- Data to write: 0xCAFE
      I_we <= '1';            -- Write data on output
      wait_cycles(clock, 2);
      -- Read phase
      I_selA <= X"4";         -- Read R4 -> Write to O_dataA
      I_selB <= X"4";
      I_selD <= X"4";
      I_we <= '0';
      wait_cycles(clock, 1);
      assert_true(O_dataA=X"0000CAFE", "Write - Read RA");
      assert_true(O_dataB=X"0000CAFE", "Write - Read RB");
      assert_true(O_dataD=X"0000CAFE", "Write - Read RD");

      running <= false;
      report "REGISTER: Testbench Complete";
   end process;

end arch_reg_tb;
