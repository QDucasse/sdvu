-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the Config Memory

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.tb_helpers.all;
use work.sdvu_constants.all;

-- =================
--      Entity
-- =================

entity config_memory_tb is
end config_memory_tb;

-- =================
--   Architecture
-- =================

architecture arch_config_memory_tb of config_memory_tb is
    -- Clock, Reset and Enable signals
    constant HALF_PERIOD : TIME := 5 ns; -- Clock half period
    signal clock   : STD_LOGIC  := '0';  -- Clock signal
    signal reset   : STD_LOGIC  := '0';  -- Reset signal
    signal enable  : STD_LOGIC  := '0';  -- Enable signal
    signal running : BOOLEAN    := true; -- Running flag, Simulation continues while true

    -- Signals for entity
    signal I_we          : STD_LOGIC;
    signal I_raa         : STD_LOGIC;
    signal I_type        : STD_LOGIC_VECTOR(1 downto 0);
    signal I_address     : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_address_raa : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
    signal I_data        : STD_LOGIC_VECTOR (TYPE_SIZE-1 downto 0);
    signal O_data        : STD_LOGIC_VECTOR (TYPE_SIZE-1 downto 0);

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

    -- DUT
    dut: entity work.config_memory(arch_config_memory)
      port map (
        I_clock       => clock,
        I_enable      => enable,
        I_reset       => reset,
        I_we          => I_we,
        I_raa         => I_raa,
        I_address_raa => I_address_raa,
        I_type        => I_type,
        I_address     => I_address,
        I_data        => I_data,
        O_data        => O_data
      );

    -- Stimulus process
    StimulusProcess: process
      -- External to access the internal memory object
--      alias mem_bank is << signal dut.memory_bank : STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0)>>;
    begin
      wait until reset = '0';
      wait_cycles(clock, 1);
      report "Config Memory: Running testbench";

      -- TESTING OPERATIONS

      -- Test 1: Write (Boolean)
      I_we <= '1'; -- Enable writing
      I_address <= X"00000000"; -- 32-bit address (8)
      I_type <= TYPE_BOOL;      -- Boolean value, 8 bits
      I_data <= X"000000BA";    -- 32-bit data (depends on the type of the data) -> 8 bits here
      wait_cycles(clock, 1);
--      assert_true(mem_bank(15 downto 8)=X"BA", "Write Boolean");

      -- Test 2: Read (Boolean)
      I_we <= '0'; -- Disable writing => Reading
      wait_cycles(clock, 2);
      assert_true(O_data=X"000000BA", "Read Boolean");

      -- Test 3: Write (Byte)
      I_we <= '1'; -- Enable writing
      I_address <= X"00000010"; -- 32-bit address (16)
      I_type <= TYPE_BYTE;      -- Byte value, 8 bits
      I_data <= X"000000BA";    -- 32-bit data (depends on the type of the data) -> 8 bits here
      wait_cycles(clock, 1);
--      assert_true(mem_bank(23 downto 16)=X"BA", "Write Byte");
--      assert_true(mem_bank(15 downto 8)=X"BA", "Write Byte - No side effect");

      -- Test 4: Read (Byte)
      I_we <= '0'; -- Disable writing => Reading
      wait_cycles(clock, 2);
      assert_true(O_data=X"000000BA", "Read Byte");

      -- Test 5: Write (Int)
      I_we <= '1'; -- Enable writing
      I_address <= X"00000018"; -- 32-bit address (24)
      I_type <= TYPE_INT;       -- Int value, 32 bits
      I_data <= X"ABCDEF98";    -- 32-bit data (depends on the type of the data) -> 32 bits here
      wait_cycles(clock, 1);
--      assert_true(mem_bank(55 downto 24)=X"ABCDEF98", "Write INT");
--      assert_true(mem_bank(23 downto 8)=X"BABA", "Write Int - No side effect");

      -- Test 6: Read (Int)
      I_we <= '0'; -- Disable writing => Reading
      wait_cycles(clock, 2);
      assert_true(O_data=X"ABCDEF98", "Read INT");

      -- Test 7: Write (State)
      I_we <= '1'; -- Enable writing
      I_address <= X"00000038"; -- 32-bit address (56)
      I_type <= TYPE_STATE;     -- State value, 16 bits
      I_data <= X"0000ABCD";    -- 32-bit data (depends on the type of the data) -> 16 bits here
      wait_cycles(clock, 1);
--      assert_true(mem_bank(71 downto 56)=X"ABCD", "Write State");
--      assert_true(mem_bank(55 downto 8)=X"ABCDEF98BABA", "Write State - No side effect");

      -- Test 8: Read (State)
      I_we <= '0'; -- Disable writing => Reading
      wait_cycles(clock, 2);
      assert_true(O_data=X"0000ABCD", "Read State");

      running <= false;
      report "Config Memory: Testbench complete";
    end process;

end arch_config_memory_tb;
