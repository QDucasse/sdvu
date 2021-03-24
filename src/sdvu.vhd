-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- SDVU design stitching all the other units

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
entity sdvu is
  port(I_clock : in STD_LOGIC;
       I_reset : in STD_LOGIC;

       -- Config memory
       I_CFG_MEM_data    : in STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
       O_enable_CFG_MEM  : out STD_LOGIC;
       O_CFG_MEM_we      : out STD_LOGIC;
       O_CFG_MEM_type    : out STD_LOGIC_VECTOR(1 downto 0);
       O_CFG_MEM_address : out STD_LOGIC_VECTOR(REG_SIZE-1 downto 0);
       O_CFG_MEM_data    : out STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
       -- Program memory
       I_PRG_MEM_data    : in STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
       O_enable_PRG_MEM  : out STD_LOGIC;
       O_PRG_MEM_PC      : out STD_LOGIC_VECTOR(PC_SIZE-1 downto 0)
      );
end sdvu;

-- Architecture
architecture arch_sdvu of sdvu is
  -- Internal Objects
  -- Signals
  -- Instruction related
  signal s_instruction : STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);
  signal s_op_code     : STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);

  -- Control-unit related
  signal s_reset          : STD_LOGIC;
  signal s_enable_ALU     : STD_LOGIC;
  signal s_enable_CFG_MEM : STD_LOGIC;
  signal s_enable_DECODER : STD_LOGIC;
  signal s_enable_PC      : STD_LOGIC;
  signal s_enable_PRG_MEM : STD_LOGIC;
  signal s_enable_REG     : STD_LOGIC;

  signal s_CFG_MEM_we     : STD_LOGIC;
  signal s_REG_we_ALU     : STD_LOGIC;
  signal s_REG_we_LOAD    : STD_LOGIC;

  -- Decoder related
  signal s_cfgMask     : STD_LOGIC_VECTOR (1 downto 0);
  signal s_sel_rA      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_sel_rB      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_sel_rD      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_immA        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_immB        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_address     : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_type        : STD_LOGIC_VECTOR (1 downto 0);
  -- Register related
  signal s_dataA       : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataB       : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataD_ALU   : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataD_LOAD  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataD_STORE : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  -- PC related
  signal s_PC         : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
  signal s_PC_OPCode  : STD_LOGIC_VECTOR (PC_OP_SIZE-1 downto 0);

-- Components mapping
begin
  -- Mapping ALU
  sdvu_alu : entity work.alu(arch_alu)
    port map (
      I_clock      => I_clock,
      I_enable     => s_enable_ALU, -- based on the state of the control unit
      I_reset      => s_reset,      -- based on the state of the control unit
      -- Inputs
      I_op_code    => s_op_code,
      I_cfgMask    => s_cfgMask,
      I_dataA      => s_dataA,
      I_dataB      => s_dataB,
      I_immA       => s_immA,
      I_immB       => s_immB,
      I_address    => s_address,
      I_type       => s_type,
      -- Outputs
      O_result     => s_dataD_ALU
    );


  -- Mapping Control Unit
  sdvu_control_unit : entity work.control_unit(arch_control_unit)
    port map (
      I_clock          => I_clock,
      I_reset          => I_reset,
      -- Inputs
      I_op_code        => s_op_code,
      I_PC_OPCode      => s_PC_OPCode,
      -- Outputs
      O_reset          => s_reset,
      O_enable_ALU     => s_enable_ALU,
      O_enable_CFG_MEM => s_enable_CFG_MEM,
      O_enable_DECODER => s_enable_DECODER,
      O_enable_PC      => s_enable_PC,
      O_enable_PRG_MEM => s_enable_PRG_MEM,
      O_enable_REG     => s_enable_REG,
      O_CFG_MEM_we     => s_CFG_MEM_we,
      O_REG_we_ALU     => s_REG_we_ALU,
      O_REG_we_LOAD    => s_REG_we_LOAD,
      O_PC_OPCode      => s_PC_OPCode
    );


  -- Mapping Decoder
  sdvu_decoder : entity work.decoder(arch_decoder)
    port map (
      I_clock       => I_clock,
      I_enable      => s_enable_DECODER,
      -- Inputs
      I_instruction => s_instruction,
      -- Outputs
      O_op_code     => s_op_code,
      O_cfgMask     => s_cfgMask,
      O_rA          => s_sel_rA,
      O_rB          => s_sel_rB,
      O_rD          => s_sel_rD,
      O_immA        => s_immA,
      O_immB        => s_immB,
      O_address     => s_address,
      O_type        => s_type
    );


  -- Mapping Program Counter
  sdvu_pc : entity work.pc(arch_pc)
    port map (
      I_clock     => I_clock,
      I_reset     => s_reset,
      I_enable    => s_enable_PC,
      -- Inputs
      I_newPC     => s_address,
      I_PC_OPCode => s_PC_OPCode,
      -- Outputs
      O_PC        => s_PC
    );


  -- Mapping Register File
  sdvu_reg : entity work.reg(arch_reg)
    port map (
      I_clock  => I_clock,
      I_reset  => s_reset,
      I_enable => s_enable_REG,
      -- Inputs
      I_we_ALU     => s_REG_we_ALU,
      I_we_LOAD    => s_REG_we_LOAD,
      I_selA       => s_sel_rA,
      I_selB       => s_sel_rB,
      I_selD       => s_sel_rD,
      I_dataD_ALU  => s_dataD_ALU,
      I_dataD_LOAD => s_dataD_LOAD,
      -- Outputs
      O_dataB   => s_dataB,
      O_dataA   => s_dataA,
      O_dataD   => s_dataD_STORE
    );

  -- Using memory results
  s_instruction <= I_PRG_MEM_data;
  s_dataD_LOAD  <= I_CFG_MEM_data;

  -- CFG MEM output signals
  O_enable_CFG_MEM  <= s_enable_CFG_MEM;
  O_CFG_MEM_we      <= s_CFG_MEM_we;
  O_CFG_MEM_type    <= s_type;
  O_CFG_MEM_address <= s_address;
  O_CFG_MEM_data    <= s_dataD_STORE;   -- In case of store

  -- PRG MEM output signals
  O_enable_PRG_MEM  <= s_enable_PRG_MEM;
  O_PRG_MEM_PC      <= s_PC;

end architecture arch_sdvu;
