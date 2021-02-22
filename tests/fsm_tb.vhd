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

entity fsm_tb is
end fsm_tb;

-- =================
--   Architecture
-- =================

architecture arch_fsm_tb of fsm_tb is
    -- Internal Objects
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clk     : std_logic  := '0';  -- Clock signal
    signal reset   : std_logic  := '0';  -- Reset signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clk);
       end loop;
     end procedure;

     -- Entity Constants
     constant PC_SIZE : natural := 16;

     -- Entity Signals
     signal O_state : STD_LOGIC_VECTOR (1 downto 0);


begin
    -- Clock, reset and enable signals
    reset <= '0', '1' after 10 ns;
    clk <= not(clk) after HALF_PERIOD when running else clk;
    -- DUT
    dut: entity work.fsm(arch_fsm)
        port map (
          I_clk   => clk,
          I_reset => reset,
          O_state => O_state
        );

    -- Stimulus process
    StimulusProcess: process
    begin
      wait until reset='1';
      report "FSM: Running testbench";
      -- TESTING OPERATIONS

      -- Test 1: Initial decode
      wait_cycles(1);
      if (O_state=FSM_DECODE) then report "Test INITIAL DECODE: Passed" severity NOTE;
        else report "Test INITIAL DECODE: Failed" severity FAILURE;
      end if;

      -- Test 2: Decode -> Reg Read
      wait_cycles(1);
      if (O_state=FSM_REGREAD) then report "Test DECODE REGREAD: Passed" severity NOTE;
        else report "Test DECODE REGREAD: Failed" severity FAILURE;
      end if;

      -- Test 3: Reg Read -> ALU
      wait_cycles(1);
      if (O_state=FSM_ALU) then report "Test REGREAD ALU: Passed" severity NOTE;
        else report "Test REGREAD ALU: Failed" severity FAILURE;
      end if;

      -- Test 4: ALU -> Reg Write
      wait_cycles(1);
      if (O_state=FSM_REGWRITE) then report "Test ALU REGWRITE: Passed" severity NOTE;
        else report "Test ALU REGWRITE: Failed" severity FAILURE;
      end if;

      -- Test 5: Reg Write -> Decode
      wait_cycles(1);
      if (O_state=FSM_DECODE) then report "Test REGWRITE DECODE: Passed" severity NOTE;
        else report "Test REGWRITE DECODE: Failed" severity FAILURE;
      end if;

      running <= false;
      report "PC: Testbench complete";
    end process;

end arch_fsm_tb;
