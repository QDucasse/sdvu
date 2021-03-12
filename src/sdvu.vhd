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
       O_CFG_MEM_we      : out STD_LOGIC;
       O_CFG_MEM_type    : out STD_LOGIC_VECTOR(1 downto 0);
       O_CFG_MEM_address : out STD_LOGIC_VECTOR(CFG_MEM_SIZE-1 downto 0);
       O_CFG_MEM_data    : out STD_LOGIC_VECTOR(TYPE_SIZE-1 downto 0);
       -- Program memory
       I_PRG_MEM_data    : in STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
       O_PRG_MEM_address : out std_logic_vector(PROG_MEM_SIZE-1 downto 0)
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
  signal s_state       : STD_LOGIC_VECTOR (STATE_NUMBER-1 downto 0);
  -- Decoder related
  signal s_cfgMask     : STD_LOGIC_VECTOR (1 downto 0);
  signal s_sel_rA      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_sel_rB      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_sel_rD      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_immA        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_immB        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_address     : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_WE          : STD_LOGIC;
  signal s_type        : STD_LOGIC_VECTOR (1 downto 0);
  -- Register related
  signal s_dataA      : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataB      : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataD      : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  -- ALU related
  signal s_dataResult : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  -- PC related
  signal s_PC         : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
  signal s_newPC      : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
  signal s_PC_op_code : STD_LOGIC_VECTOR (PC_OP_SIZE-1 downto 0);

-- Components mapping
begin
  -- Mapping ALU
  sdvu_alu : entity work.alu(arch_alu)
    port map (
      I_clock      => I_clock,
      I_enable     => s_state(1), -- based on the state of the control unit
      I_reset      => s_state(0),  -- based on the state of the control unit
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
      O_dataResult => s_dataResult
    );


  -- Mapping Control Unit
  sdvu_control_unit : entity work.control_unit(arch_control_unit)
    port map (
      I_clock   => I_clock,
      I_reset   => s_state(0), -- based on the state of the control unit
      -- Inputs
      I_op_code => s_op_code,
      -- Outputs
      O_state   => s_state
    );


  -- Mapping Decoder
  sdvu_decoder : entity work.decoder(arch_decoder)
    port map (
      I_clock       => I_clock,
      I_enable      => s_state(1), -- based on the state of the control unit
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
      O_type        => s_type,
      O_WE          => s_WE
    );


  -- Mapping Program Counter
  sdvu_pc : entity work.pc(arch_pc)
    port map (
      I_clock     => I_clock,
      I_reset     => s_state(0),  -- based on the state of the control unit
      I_enable    => s_state(1), -- based on the state of the control unit
      -- Inputs
      I_newPC     => s_newPC,
      I_PC_OPCode => s_PC_op_code,
      -- Outputs
      O_PC        => s_PC
    );


  -- Mapping Register File
  sdvu_reg : entity work.reg(arch_reg)
    port map (
      I_clock  => I_clock,
      I_reset  => s_state(0),  -- based on the state of the control unit
      I_enable => s_state(1), -- based on the state of the control unit
      -- Inputs
      I_we     => s_WE,
      I_selA   => s_sel_rA,
      I_selB   => s_sel_rB,
      I_selD   => s_sel_rD,
      I_dataD  => s_dataD,
      -- Outputs
      O_dataB  => s_dataB,
      O_dataA  => s_dataA,
      O_dataD  => s_dataD
    );

end architecture arch_sdvu;
