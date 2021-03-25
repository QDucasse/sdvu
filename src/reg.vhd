-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Register file degining the size and number of registers.

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

entity reg is
    port (I_clock  : in STD_LOGIC; -- Clock
          I_reset  : in STD_LOGIC; -- Reset
          I_enable : in STD_LOGIC; -- Enable
          -- Inputs
          I_we_ALU       : in STD_LOGIC;                                  -- Write Enable (write the destination value or not) ALU
          I_we_LOAD      : in STD_LOGIC;                                  -- Write Enable (write the destination value or not) STORE
          I_we_MOVREG    : in STD_LOGIC;                                  -- Write Enable (write the destination value or not) MOVREG
          I_we_MOVIMM    : in STD_LOGIC;                                  -- Write Enable (write the destination value or not) MOVIMM
          I_selD         : in STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0); -- Input - select destination
          I_selA         : in STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0); -- Input - select source A
          I_selB         : in STD_LOGIC_VECTOR (REG_SEL_SIZE-1 downto 0); -- Input - select source B
          I_dataD_ALU    : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);     -- Input Data to store in a register
          I_dataD_LOAD   : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);     -- Input Data to store in a register
          I_dataD_MOVIMM : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);     -- Input Data to store in a register
          -- Outputs
          O_dataB : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0); -- Output B from regB
          O_dataA : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0); -- Output A from regA
          O_dataD : out STD_LOGIC_VECTOR (REG_SIZE-1 downto 0)  -- Output D from regD (in case of STORE )
          );
end reg;

-- =================
--   Architecture
-- =================

architecture arch_reg of reg is
    -- Internal Objects
    type store_t is array (0 to 2**REG_SEL_SIZE-1) of STD_LOGIC_VECTOR(REG_SIZE-1 downto 0); -- Array of given number SLVs set to a given size
    signal reg_bank: store_t := (others => X"00000000");                                  -- Affectation of the array and initialization at 0
begin
    -- Processes
    TransferData: process(I_clock) -- I_clock added to the sensitivity list of the process
    begin
        if rising_edge(I_clock) then
          if I_reset = '1' then -- Reset routine
            reg_bank <= (others => X"00000000");
          elsif I_enable= '1' then
            O_dataA <= reg_bank(to_integer(unsigned(I_selA)));   -- Propagate the input to the output (A)
            O_dataB <= reg_bank(to_integer(unsigned(I_selB)));   -- Propagate the input to the output (B)
            O_dataD <= reg_bank(to_integer(unsigned(I_selD)));   -- Propagate the input to the output (D)
            if (I_we_ALU = '1') then                                 -- If write-enable propagate the data
              reg_bank(to_integer(unsigned(I_selD))) <= I_dataD_ALU; -- Write dataD to the selD register
            elsif (I_we_LOAD = '1') then                              -- If write-enable propagate the data
              reg_bank(to_integer(unsigned(I_selD))) <= I_dataD_LOAD; -- Write dataD to the selD register
            elsif (I_we_MOVIMM = '1') then
              reg_bank(to_integer(unsigned(I_selD))) <= I_dataD_MOVIMM;
            elsif (I_we_MOVREG = '1') then
              reg_bank(to_integer(unsigned(I_selD))) <= reg_bank(to_integer(unsigned(I_selA)));
            end if;
          end if;
        end if;
    end process;
end arch_reg;
