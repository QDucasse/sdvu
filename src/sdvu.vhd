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
use work.alu.all;
use work.control_unit.all;
use work.decoder.all;
use work.pc.all;
use work.reg.all;


-- =================
--      Entity
-- =================


-- Entity
entity sdvu is
port(I_clock : in  std_logic;
     I_instr : in  std_logic_vector(INSTR_SIZE-1 downto 0);
     O_addr  : out std_logic_vector(REG_SIZE-1 downto 0)
    );
end entity sdvu;

-- Architecture
architecture arch_sdvu of sdvu is
  -- Internal Objects

  -- Components
  -- ALU
  -- component alu
  --   generic (
  --     REG_SIZE : natural := 32;
  --     OP_SIZE  : natural := 4
  --   );
  --   port (
  --     I_clock      : in  STD_LOGIC;
  --     I_enable     : in  STD_LOGIC;
  --     I_reset      : in  STD_LOGIC;
  --     -- Inputs
  --     I_op_code    : in  STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
  --     I_cfgMask    : in  STD_LOGIC_VECTOR (1 downto 0);
  --     I_dataA      : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  --     I_dataB      : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  --     I_immA       : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  --     I_immB       : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  --     I_address    : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  --     I_type       : in  STD_LOGIC_VECTOR (1 downto 0);
  --     -- Outputs
  --     O_dataResult : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0)
  --   );
  -- end component alu;


  -- Control Unit
  component control_unit
    generic (
      OP_SIZE      : natural := 4;
      STATE_NUMBER : natural := 12
    );
    port (
      I_clock : in  STD_LOGIC;
      I_reset : in  STD_LOGIC;
      I_op_code   : in  STD_LOGIC_VECTOR(OP_SIZE-1 downto 0);
      O_state : out STD_LOGIC_VECTOR (STATE_NUMBER-1 downto 0)
    );
  end component control_unit;


  -- Decoder
  component decoder
    generic (
      OP_SIZE      : natural := 4;
      REG_SEL_SIZE : natural := 4
    );
    port (
      I_clock    : in  STD_LOGIC;
      I_enable   : in  STD_LOGIC;
      I_instruction : in  STD_LOGIC_VECTOR (31 downto 0);
      O_op_code    : out STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
      O_cfgMask  : out STD_LOGIC_VECTOR (1  downto 0);
      O_rB       : out STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
      O_immB     : out STD_LOGIC_VECTOR (10 downto 0);
      O_address  : out STD_LOGIC_VECTOR (23 downto 0);
      O_type     : out STD_LOGIC_VECTOR (1  downto 0);
      O_WE       : out STD_LOGIC
    );
  end component decoder;


  -- PC
  component pc
    generic (
      PC_SIZE    : natural := 16;
      PC_OP_SIZE : natural := 2
    );
    port (
      I_clock     : in  STD_LOGIC;
      I_reset     : in  STD_LOGIC;
      I_enable    : in  STD_LOGIC;
      I_newPC  : in  STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
      I_PC_OPCode : in  STD_LOGIC_VECTOR (PC_OP_SIZE-1 downto 0);
      O_PC        : out STD_LOGIC_VECTOR (PC_SIZE-1 downto 0)
    );
  end component pc;



  -- Register File
  component reg
    generic (
      REG_SIZE     : natural := 32;
      REG_SEL_SIZE : natural := 4
    );
    port (
      I_clock  : in  STD_LOGIC;
      I_reset  : in  STD_LOGIC;
      I_enable : in  STD_LOGIC;
      I_we     : in  STD_LOGIC;
      I_selD   : in  STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
      I_selA   : in  STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
      I_selB   : in  STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0);
      I_dataD  : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
      O_dataB  : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
      O_dataA  : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
      O_dataD  : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0)
    );
  end component reg;


  -- Signals

  -- Signals to/from control unit
  signal s_op_code : STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
  signal s_state   : STD_LOGIC_VECTOR (STATE_NUMBER-1 downto 0);

  -- Signals to/from decoder
  signal s_instruction : STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);
  signal s_cfgMask     : STD_LOGIC_VECTOR (1 downto 0);
  signal s_sel_rA      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_sel_rB      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_sel_rD      : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
  signal s_immA        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_immB        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_address     : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_WE          : STD_LOGIC;

  -- Signals to/from alu
  signal s_dataA      : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_dataB      : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
  signal s_type       : STD_LOGIC_VECTOR (1 downto 0);
  signal s_dataResult : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);

  -- Signals to/from pc
  signal s_PC         : STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
  signal s_PC_op_code : STD_LOGIC_VECTOR (PC_OP_SIZE-1 downto 0);

  -- Signals to/from registers
  signal s_dataD  : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);


-- Components mapping
begin
  -- Mapping ALU
  sdvu_alu : entity work.alu(arch_alu)
    port map (
      I_clock      => I_clock,
      I_enable     => I_enable, -- based on the state of the control unit
      I_reset      => I_reset,  -- based on the state of the control unit
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
  sdvu_control_unit : control_unit
    port map (
      I_clock   => I_clock,
      I_reset   => I_reset, -- based on the state of the control unit
      -- Inputs
      I_op_code => s_op_code,
      -- Outputs
      O_state   => s_state
    );


  -- Mapping Decoder
  sdvu_decoder : decoder
    port map (
      I_clock       => I_clock,
      I_enable      => I_enable, -- based on the state of the control unit
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
  sdvu_pc : pc
    port map (
      I_clock     => I_clock,
      I_reset     => I_reset,  -- based on the state of the control unit
      I_enable    => I_enable, -- based on the state of the control unit
      -- Inputs
      I_newPC     => s_newPC,
      I_PC_OPCode => s_PC_op_code,
      -- Outputs
      O_PC        => s_PC
    );


  -- Mapping Register File
  sdvu_reg : reg
    port map (
      I_clock  => I_clock,
      I_reset  => I_reset,  -- based on the state of the control unit
      I_enable => I_enable, -- based on the state of the control unit
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
