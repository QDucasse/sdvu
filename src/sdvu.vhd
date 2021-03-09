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
use work.constant_codes.all;


-- =================
--      Entity
-- =================


-- Entity
entity sdvu is
generic(INSTR_SIZE : natural := 32; -- Instruction size
        SIZE       : natural := 16; -- Adress width
        REG_NB     : natural := 4;  -- log2 number of registers. Dependency with adress width
        REG_SIZE   : natural := 32  -- Size of a single register
       );
port(clock_in         : in  std_logic;
     instruction_in : in  std_logic_vector(INSTR_SIZE-1 downto 0);
     addr_out       : out std_logic_vector(SIZE-1 downto 0)
    );
end entity sdvu;

-- Architecture
architecture arch_sdvu of sdvu is
  -- Internal Objects

  -- Components
  -- ALU
  component alu
    generic (
      REG_NB    : natural := 16;
      OP_SIZE   : natural := 4;
      ADDR_SIZE : natural := 24
    );
    port (
      I_clock    : in  STD_LOGIC;
      I_enable   : in  STD_LOGIC;
      I_reset    : in  STD_LOGIC;
      -- Inputs
      I_aluop    : in  STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
      I_cfgMask  : in  STD_LOGIC_VECTOR (1 downto 0);
      I_dataA    : in  STD_LOGIC_VECTOR (REG_NB-1 downto 0);
      I_dataB    : in  STD_LOGIC_VECTOR (REG_NB-1 downto 0);
      I_dataImmA : in  STD_LOGIC_VECTOR (REG_NB-1 downto 0);
      I_dataImmB : in  STD_LOGIC_VECTOR (REG_NB-1 downto 0);
      I_address  : in  STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
      I_type     : in  STD_LOGIC_VECTOR (1 downto 0);
      I_WE       : in  STD_LOGIC;
      -- Outputs
      O_dataResult : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
      O_WE       : out STD_LOGIC
    );
  end component alu;


  -- Control Unit
  component control_unit
    generic (
      OP_SIZE      : natural := 4;
      STATE_NUMBER : natural := 12
    );
    port (
      I_clock : in  STD_LOGIC;
      I_reset : in  STD_LOGIC;
      I_op    : in  STD_LOGIC_VECTOR(OP_SIZE-1 downto 0);
      O_state : out STD_LOGIC_VECTOR (STATE_NUMBER-1 downto 0)
    );
  end component control_unit;


  -- Decoder
  component decoder
    generic (
      OP_SIZE  : natural := 4;
      REG_SIZE : natural := 4
    );
    port (
      I_clock    : in  STD_LOGIC;
      I_enable   : in  STD_LOGIC;
      I_dataInst : in  STD_LOGIC_VECTOR (31 downto 0);
      O_aluop    : out STD_LOGIC_VECTOR (3  downto 0);
      O_cfgMask  : out STD_LOGIC_VECTOR (1  downto 0);
      O_rB       : out STD_LOGIC_VECTOR (3  downto 0);
      O_immB     : out STD_LOGIC_VECTOR (10 downto 0);
      O_address  : out STD_LOGIC_VECTOR (23 downto 0);
      O_type     : out STD_LOGIC_VECTOR (1  downto 0);
      O_WE       : out STD_LOGIC
    );
  end component decoder;


  -- PC
  component pc
    generic (
      PC_WIDTH    : natural := 16;
      PC_OP_WIDTH : natural := 2
    );
    port (
      I_clock     : in  STD_LOGIC;
      I_reset     : in  STD_LOGIC;
      I_enable    : in  STD_LOGIC;
      I_PC_toSet  : in  STD_LOGIC_VECTOR (PC_WIDTH-1 downto 0);
      I_PC_OPCode : in  STD_LOGIC_VECTOR (PC_OP_WIDTH-1 downto 0);
      O_PC        : out STD_LOGIC_VECTOR (PC_WIDTH-1 downto 0)
    );
  end component pc;


  -- Register File
  component reg
    generic (
      REG_WIDTH : natural := 32;
      REG_SIZE  : natural := 4
    );
    port (
      I_clock  : in  STD_LOGIC;
      I_reset  : in  STD_LOGIC;
      I_enable : in  STD_LOGIC;
      I_we     : in  STD_LOGIC;
      I_selD   : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
      I_selA   : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
      I_selB   : in  STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
      I_dataD  : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      O_dataB  : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      O_dataA  : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      O_dataD  : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0
    );
  end component reg;

  -- Signals

  -- Signals to/from alu
  signal s_aluop      : STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
  signal s_cfgMask    : STD_LOGIC_VECTOR (1 downto 0);
  signal s_dataA      : STD_LOGIC_VECTOR (REG_NB-1 downto 0);
  signal s_dataB      : STD_LOGIC_VECTOR (REG_NB-1 downto 0);
  signal s_dataImmA   : STD_LOGIC_VECTOR (REG_NB-1 downto 0);
  signal s_dataImmB   : STD_LOGIC_VECTOR (REG_NB-1 downto 0);
  signal s_address    : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
  signal s_type       : STD_LOGIC_VECTOR (1 downto 0);
  signal s_dataResult : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
  signal s_rd_WE      : STD_LOGIC;

  -- Signals to/from control unit
  signal s_instruction : STD_LOGIC_VECTOR(INSTR_SIZE-1 down to 0);
  signal s_state : STD_LOGIC_VECTOR(STATE_NUMBER-1 downto 0);

  -- Signals to/from registers

  -- Signals to/from pc
  signal s_PC_to_set : STD_LOGIC_VECTOR(PC_WIDTH-1 downto 0);
  signal s_PC_to_set : STD_LOGIC_VECTOR(PC_OP_WIDTH-1 downto 0);

  end package;


-- Components mapping
begin
  -- Mapping ALU
  sdvu_alu : alu
    generic map (
      REG_NB    => REG_NB,
      OP_SIZE   => OP_SIZE,
      ADDR_SIZE => ADDR_SIZE
    )
    port map (
      I_clock      => I_clock,
      I_enable     => I_enable, -- TODO
      I_reset      => I_reset,
      I_aluop      => I_aluop,
      I_cfgMask    => I_cfgMask,
      I_dataA      => I_dataA,
      I_dataB      => I_dataB,
      I_dataImmA   => I_dataImmA,
      I_dataImmB   => I_dataImmB,
      I_address    => I_address,
      I_type       => I_type,
      I_WE         => I_WE,
      O_dataResult => O_dataResult,
      O_WE         => O_WE
    );


  -- Mapping Control Unit
  sdvu_control_unit : control_unit
    generic map (
      OP_SIZE      => OP_SIZE,
      STATE_NUMBER => STATE_NUMBER
    )
    port map (
      I_clock => I_clock,
      I_reset => I_reset,
      I_op    => I_op,
      O_state => O_state
    );

  -- Mapping Decoder
  sdvu_decoder : decoder
    generic map (
      OP_SIZE  => OP_SIZE,
      REG_SIZE => REG_SIZE
    )
    port map (
      I_clock    => I_clock,
      I_enable   => I_enable,
      I_dataInst => I_dataInst,
      O_aluop    => O_aluop,
      O_cfgMask  => O_cfgMask,
      O_rB       => O_rB,
      O_immB     => O_immB,
      O_address  => O_address,
      O_type     => O_type,
      O_WE       => O_WE
    );


  -- Mapping Program Counter
  sdvu_pc : pc
    generic map (
      PC_WIDTH    => PC_WIDTH,
      PC_OP_WIDTH => PC_OP_WIDTH
    )
    port map (
      I_clock     => I_clock,
      I_reset     => I_reset,
      I_enable    => I_enable,
      I_PC_toSet  => I_PC_toSet,
      I_PC_OPCode => I_PC_OPCode,
      O_PC        => O_PC
    );


  -- Mapping Register File
  sdvu_reg : reg
    generic map (
      REG_WIDTH => REG_WIDTH,
      REG_SIZE  => REG_SIZE
    )
    port map (
      I_clock  => I_clock,
      I_reset  => I_reset,
      I_enable => I_enable,
      I_we     => I_we,
      I_selD   => I_selD,
      I_selA   => I_selA,
      I_selB   => I_selB,
      I_dataD  => I_dataD,
      O_dataB  => O_dataB,
      O_dataA  => O_dataA,
      O_dataD  => O_dataD
    );

end architecture arch_sdvu;
