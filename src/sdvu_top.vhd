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
       I_reset : in STD_LOGIC);
end sdvu_top;

-- Architecture
architecture arch_sdvu_top of sdvu_top is
  -- Internal objects

  -- Signals
  -- CFG MEM related
  signal s_enable_CFG_MEM     : STD_LOGIC;
  signal s_CFG_MEM_data_write : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
  signal s_CFG_MEM_we         : STD_LOGIC;
  signal s_CFG_MEM_type       : STD_LOGIC_VECTOR(1 downto 0);
  signal s_CFG_MEM_address    : STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
  signal s_CFG_MEM_data_read  : STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
  -- PRG MEM related
  signal s_enable_PRG_MEM : STD_LOGIC;
  signal s_PRG_MEM_data   : STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
  signal s_PRG_MEM_PC     : STD_LOGIC_VECTOR(PC_SIZE-1 downto 0);

begin
  -- Components Mapping
  top_sdvu : entity work.sdvu(arch_sdvu)
    port map (
      I_clock           => I_clock,
      I_reset           => I_reset,
      I_CFG_MEM_data    => s_CFG_MEM_data_read,
      O_enable_CFG_MEM  => s_enable_CFG_MEM,
      O_CFG_MEM_we      => s_CFG_MEM_we,
      O_CFG_MEM_type    => s_CFG_MEM_type,
      O_CFG_MEM_address => s_CFG_MEM_address,
      O_CFG_MEM_data    => s_CFG_MEM_data_write,
      I_PRG_MEM_data    => s_PRG_MEM_data,
      O_enable_PRG_MEM  => s_enable_PRG_MEM,
      O_PRG_MEM_PC      => s_PRG_MEM_PC
    );

  top_cfg_mem : entity work.auto_config_memory(arch_auto_config_memory)
    port map (
      I_clock   => I_clock,
      I_enable  => s_enable_CFG_MEM,
      I_reset   => I_reset,
      I_we      => s_CFG_MEM_we,
      I_type    => s_CFG_MEM_type,
      I_address => s_CFG_MEM_address,
      I_data    => s_CFG_MEM_data_write,
      O_data    => s_CFG_MEM_data_read
    );

    top_prg_mem : entity work.auto_program_memory(arch_auto_program_memory)
      port map (
        I_clock  => I_clock,
        I_reset  => I_reset,
        I_enable => s_enable_PRG_MEM,
        I_PC     => s_PRG_MEM_PC,
        O_data   => s_PRG_MEM_data
      );


end architecture arch_sdvu_top;
