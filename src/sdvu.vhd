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
generic(INSTR_SIZE : natural := 16; -- Instruction size
        SIZE       : natural := 16; -- Adress width
        REG_NB     : natural := 4;  -- log2 number of registers. Dependency with adress width
        REG_SIZE   : natural := 16  -- Size of a single register
       );
port(clk_in         : in  std_logic;
     instruction_in : in  std_logic_vector(INSTR_SIZE-1 downto 0);
     addr_out       : out std_logic_vector(SIZE-1 downto 0)
    );
end entity sdvu;

-- Architecture
architecture arch_sdvu of sdvu is
  -- Internal Objects
  -- Signals
  -- TODO: ÅDD SIGNALS
  -- Components
  -- ALU
  component alu
    generic (
      REG_WIDTH : natural := 16;
      OP_SIZE   : natural := 4
    );
    port (
      I_clk      : in  STD_LOGIC;
      I_en       : in  STD_LOGIC;
      I_reset    : in  STD_LOGIC;
      I_aluop    : in  STD_LOGIC_VECTOR (3  downto 0);
      I_cfgMask  : in  STD_LOGIC_VECTOR (1  downto 0);
      I_dataA    : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_dataB    : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_dataImmA : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_dataImmB : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_address  : in  STD_LOGIC_VECTOR (23 downto 0);
      I_type     : in  STD_LOGIC_VECTOR (1  downto 0);
      O_dataResult : out STD_LOGIC_VECTOR (23 downto 0);
      I_WE       : in  STD_LOGIC;
      O_WE       : out STD_LOGIC
    );
  end component alu;

  -- Control Unit
  component control_unit
    port (
      I_clk   : in  STD_LOGIC;
      I_reset : in  STD_LOGIC;
      O_state : out STD_LOGIC_VECTOR (1 downto 0)
    );
  end component control_unit;

  -- Decoder
  component decoder
    port (
      I_clk      : in  STD_LOGIC;
      I_en       : in  STD_LOGIC;
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
      PC_SIZE : natural := 16
    );
    port (
      I_clk       : in  STD_LOGIC;
      I_reset     : in  STD_LOGIC;
      I_PC_toSet  : in  STD_LOGIC_VECTOR (PC_SIZE-1 downto 0);
      I_PC_OPCode : in  STD_LOGIC_VECTOR (1 downto 0);
      O_PC        : out STD_LOGIC_VECTOR (PC_SIZE-1 downto 0)
    );
  end component pc;
  -- Register File
  component reg
    generic (
      REG_WIDTH : natural := 16;
      SIZE      : natural := 4
    );
    port (
      I_clk   : in  STD_LOGIC;
      I_reset : in  STD_LOGIC;
      I_en    : in  STD_LOGIC;
      I_dataD : in  STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_selD  : in  STD_LOGIC_VECTOR (SIZE-1 downto 0);
      I_selA  : in  STD_LOGIC_VECTOR (SIZE-1 downto 0);
      O_dataA : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_selB  : in  STD_LOGIC_VECTOR (SIZE-1 downto 0);
      O_dataB : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
      I_we    : in  STD_LOGIC
    );
  end component reg;


-- Components mapping
begin
  -- Mapping ALU
  sdvu_alu : alu
  generic map (
    REG_WIDTH => REG_WIDTH,
    OP_SIZE   => OP_SIZE
  )
  port map (
    I_clk      => I_clk,
    I_en       => I_en,
    I_reset    => I_reset,
    I_aluop    => I_aluop,
    I_cfgMask  => I_cfgMask,
    I_dataA    => I_dataA,
    I_dataB    => I_dataB,
    I_dataImmA => I_dataImmA,
    I_dataImmB => I_dataImmB,
    I_address  => I_address,
    I_type     => I_type,
    I_WE       => I_WE,
    O_WE       => O_WE
  );

  -- Mapping Control Unit
  sdvu_control_unit : control_unit
  port map (
    I_clk   => I_clk,
    I_reset => I_reset,
    O_state => O_state
  );

  -- Mapping Decoder
  sdvu_decoder : decoder
  port map (
    I_clk      => I_clk,
    I_en       => I_en,
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
    PC_SIZE => PC_SIZE
  )
  port map (
    I_clk       => I_clk,
    I_reset     => I_reset,
    I_PC_toSet  => I_PC_toSet,
    I_PC_OPCode => I_PC_OPCode,
    O_PC        => O_PC
  );

    -- Mapping Register File
    sdvu_reg : reg
    generic map (
      REG_WIDTH => REG_WIDTH,
      SIZE      => SIZE
    )
    port map (
      I_clk   => I_clk,
      I_reset => I_reset,
      I_en    => I_en,
      I_dataD => I_dataD,
      I_selD  => I_selD,
      I_selA  => I_selA,
      O_dataA => O_dataA,
      I_selB  => I_selB,
      O_dataB => O_dataB,
      I_we    => I_we
    );


end architecture arch_sdvu;
