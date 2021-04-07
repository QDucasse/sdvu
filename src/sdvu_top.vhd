-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Top component linking sdvu to the memories

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
entity sdvu_top is
  port(I_clock : in STD_LOGIC;
       I_reset : in STD_LOGIC;
       O_config : out STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0)
       );
end sdvu_top;

-- Architecture
architecture arch_sdvu_top of sdvu_top is
  -- Internal objects

  -- Signals
  -- CFG MEM related
  signal s_enable_CFG_MEM      : STD_LOGIC;
  signal s_return_config       : STD_LOGIC;
  signal s_CFG_MEM_data_write  : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
  signal s_CFG_MEM_we          : STD_LOGIC;
  signal s_CFG_MEM_RAA         : STD_LOGIC;
  signal s_CFG_MEM_type        : STD_LOGIC_VECTOR(1 downto 0);
  signal s_CFG_MEM_address     : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
  signal s_CFG_MEM_address_RAA : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
  signal s_CFG_MEM_data_read   : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
  signal s_output_config       : STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0);
  -- PRG MEM related
  signal s_enable_PRG_MEM : STD_LOGIC;
  signal s_PRG_MEM_data   : STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
  signal s_PRG_MEM_PC     : STD_LOGIC_VECTOR(PC_SIZE-1 downto 0);

begin
  -- Components Mapping
  sdvu : entity work.sdvu(arch_sdvu)
    port map (
      I_clock               => I_clock,
      I_reset               => I_reset,
      I_CFG_MEM_data        => s_CFG_MEM_data_read,
      O_enable_CFG_MEM      => s_enable_CFG_MEM,
      O_return_config       => s_return_config,
      O_CFG_MEM_we          => s_CFG_MEM_we,
      O_CFG_MEM_RAA         => s_CFG_MEM_RAA,
      O_CFG_MEM_type        => s_CFG_MEM_type,
      O_CFG_MEM_address     => s_CFG_MEM_address,
      O_CFG_MEM_address_RAA => s_CFG_MEM_address_RAA,
      O_CFG_MEM_data        => s_CFG_MEM_data_write,
      I_PRG_MEM_data        => s_PRG_MEM_data,
      O_enable_PRG_MEM      => s_enable_PRG_MEM,
      O_PRG_MEM_PC          => s_PRG_MEM_PC
    );

  cfg_mem : entity work.auto_config_memory(arch_auto_config_memory)
    port map (
      I_clock         => I_clock,
      I_enable        => s_enable_CFG_MEM,
      I_return_config => s_return_config,
      I_reset         => I_reset,
      I_we            => s_CFG_MEM_we,
      I_RAA           => s_CFG_MEM_RAA,
      I_type          => s_CFG_MEM_type,
      I_address       => s_CFG_MEM_address,
      I_address_RAA   => s_CFG_MEM_address_RAA,
      I_data          => s_CFG_MEM_data_write,
      O_data          => s_CFG_MEM_data_read,
      O_config        => s_output_config
    );

    prg_mem : entity work.auto_program_memory(arch_auto_program_memory)
      port map (
        I_clock  => I_clock,
        I_reset  => I_reset,
        I_enable => s_enable_PRG_MEM,
        I_PC     => s_PRG_MEM_PC,
        O_data   => s_PRG_MEM_data
      );

    O_config <= s_output_config;
end architecture arch_sdvu_top;
