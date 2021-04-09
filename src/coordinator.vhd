-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Coordinator of the different cores. Handles the UART and initializes the config memory.
-- Waits for all the cores to be in IDLE mode before sending a reset signal along
-- with a new configuration.

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.sdvu_constants.all;

-- =================
--      Entity
-- =================

-- Entity
entity coordinator is
  port(I_clock : in STD_LOGIC;
       I_reset : in STD_LOGIC;
       -- Inputs
       I_binaries        : in prog_memory_array;                            -- Initial binaries to load the program with
       I_new_config      : in STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0); -- New config to load in the cores
       -- Outputs
       O_configs         : out config_memory_array;                         -- Output all the config memories obtained
       O_changed_configs : out STD_LOGIC_VECTOR(CORE_NUMBER-1 downto 0)     -- Bit array to notify if a given config has changed
       );
end coordinator;

-- =================
--   Architecture
-- =================

architecture arch_coordinator of coordinator is
  -- Internal signals
  signal s_new_configs     : config_memory_array;
  signal s_changed_configs : STD_LOGIC_VECTOR(CORE_NUMBER-1 downto 0);
  signal s_idle_status     : STD_LOGIC_VECTOR(CORE_NUMBER-1 downto 0);
  signal s_resets          : STD_LOGIC_VECTOR(CORE_NUMBER-1 downto 0);
  -- Components
  component sdvu_top
  port (
    I_clock         : in  STD_LOGIC;
    I_reset         : in  STD_LOGIC;
    I_new_config    : in  STD_LOGIC_VECTOR (2** CFG_MEM_SIZE-1 downto 0);
    O_idle          : out STD_LOGIC;
    O_return_config : out STD_LOGIC;
    O_config        : out STD_LOGIC_VECTOR (2**CFG_MEM_SIZE-1 downto 0)
  );
  end component sdvu_top;
  -- Functions
  -- Checks if all bits of a given vector are set to a given value
  function is_all(vec : std_logic_vector; val : std_logic) return boolean is
    constant all_bits : std_logic_vector(vec'range) := (others => val);
  begin
    return vec = all_bits;
  end function;
begin

  -- Component instances
  GenerateCores:
  for i in 0 to CORE_NUMBER-1 generate
     sdvu_core : sdvu_top
       port map (
         I_clock         => I_clock,
         I_reset         => s_resets(i),
         I_new_config    => I_new_config,
         O_idle          => s_idle_status(i),
         O_return_config => s_changed_configs(i),
         O_config        => s_new_configs(i)
       );
  end generate;

  -- Processes
  Coordinate: process(I_clock)-- I_clock added to the sensitivity list of the process
  begin
    if rising_edge(I_clock) then -- if new_cycle
      if I_reset = '1' then      -- Reset procedure (send reset and set the initial program)
        for i in 0 to CORE_NUMBER-1 loop
          -- Map an input of the initial program memory
        end loop;
      elsif is_all(s_idle_status, '1') then
        s_resets <= (others => '1');
      else
        s_resets <= (others => '0');
      end if;
    end if;

  end process;

  O_configs         <= s_new_configs;
  O_changed_configs <= s_changed_configs;

end architecture arch_coordinator;
