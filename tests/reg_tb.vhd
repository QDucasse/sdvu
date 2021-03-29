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
    signal I_we_ALU       : STD_LOGIC;
    signal I_we_LOAD      : STD_LOGIC;
    signal I_we_MOVREG    : STD_LOGIC;
    signal I_we_MOVIMM    : STD_LOGIC;
    signal I_selD         : STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
    signal I_selA         : STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
    signal I_selB         : STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
    signal I_dataD_ALU    : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_dataD_LOAD   : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_dataD_MOVIMM : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal O_dataB        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal O_dataA        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal O_dataD        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);


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
       I_we_ALU       => I_we_ALU,
       I_we_LOAD      => I_we_LOAD,
       I_we_MOVREG    => I_we_MOVREG,
       I_we_MOVIMM    => I_we_MOVIMM,
       I_selD         => I_selD,
       I_selA         => I_selA,
       I_selB         => I_selB,
       I_dataD_ALU    => I_dataD_ALU,
       I_dataD_LOAD   => I_dataD_LOAD,
       I_dataD_MOVIMM => I_dataD_MOVIMM,
       O_dataB        => O_dataB,
       O_dataA        => O_dataA,
       O_dataD        => O_dataD
     );

   -- Stimulus process
   StimulusProcess: process
   begin
      wait until reset = '0';
      wait until enable  = '1';
      report "REGISTER: Running testbench";

      -- Test 1: Write/Read from ALU
      -- Write phase
      I_selA <= X"2";         -- LHS: 2
      I_selB <= X"3";         -- RHS: 3
      I_selD <= X"4";         -- Destination: R4
      I_dataD_ALU <= X"0000CAFE"; -- Data to write: 0xCAFE
      I_we_ALU <= '1';            -- Write data on output
      wait_cycles(clock, 2);
      -- Read phase
      I_selA <= X"4";         -- Read R4 -> Write to O_dataA
      I_selB <= X"4";
      I_selD <= X"4";
      I_we_ALU <= '0';
      wait_cycles(clock, 2);
      assert_true(O_dataA=X"0000CAFE", "Write/Read ALU - RA");
      assert_true(O_dataB=X"0000CAFE", "Write/Read ALU - RB");
      assert_true(O_dataD=X"0000CAFE", "Write/Read ALU - RD");

      -- Test 2: Write from LOAD
      -- Write phase
      I_selA <= X"2";         -- LHS: 2
      I_selB <= X"3";         -- RHS: 3
      I_selD <= X"5";         -- Destination: R5
      I_dataD_LOAD <= X"0000CACA"; -- Data to write: 0xCACA
      I_we_LOAD <= '1';            -- Write data on output
      wait_cycles(clock, 2);
      -- Read phase
      I_selA <= X"5";         -- Read R4 -> Write to O_dataA
      I_selB <= X"5";
      I_selD <= X"5";
      I_we_LOAD <= '0';
      wait_cycles(clock, 2);
      assert_true(O_dataA=X"0000CACA", "Write/Read LOAD - RA");
      assert_true(O_dataB=X"0000CACA", "Write/Read LOAD - RB");
      assert_true(O_dataD=X"0000CACA", "Write/Read LOAD - RD");

      -- Test 3: Write with MOVIMM
      -- Write phase
      I_selA <= X"2";         -- LHS: 2
      I_selB <= X"3";         -- RHS: 3
      I_selD <= X"6";         -- Destination: R4
      I_dataD_MOVIMM <= X"00000DAB"; -- Data to write: 0xDAB
      I_we_MOVIMM <= '1';            -- Write data on output
      wait_cycles(clock, 2);
      -- Read phase
      I_selA <= X"6";         -- Read R4 -> Write to O_dataA
      I_selB <= X"6";
      I_selD <= X"6";
      I_we_MOVIMM <= '0';
      wait_cycles(clock, 2);
      assert_true(O_dataA=X"00000DAB", "Write/Read MOVIMM - RA");
      assert_true(O_dataB=X"00000DAB", "Write/Read MOVIMM - RB");
      assert_true(O_dataD=X"00000DAB", "Write/Read MOVIMM - RD");

      -- Test 4: Write with MOVREG
      -- Write phase
      I_selA <= X"6";         -- LHS: 6 the aimed register
      I_selB <= X"3";         -- RHS: 3
      I_selD <= X"2";         -- Destination: R2
      I_we_MOVREG <= '1';     -- Write data to another register
      wait_cycles(clock, 2);
      -- Read phase
      I_selA <= X"2";         -- Read R2 -> Write to O_dataA
      I_selB <= X"2";
      I_selD <= X"2";
      I_we_MOVREG <= '0';
      wait_cycles(clock, 2);
      assert_true(O_dataA=X"00000DAB", "Write/Read MOVREG - RA");
      assert_true(O_dataB=X"00000DAB", "Write/Read MOVREG - RB");
      assert_true(O_dataD=X"00000DAB", "Write/Read MOVREG - RD");



      running <= false;
      report "REGISTER: Testbench Complete";
   end process;

end arch_reg_tb;
