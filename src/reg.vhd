-- Project Structure from TPU Blogpost series by @domipheus
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

-- =================
--      Entity
-- =================

entity reg is
    generic (REG_WIDTH : natural := 32; -- Data size for each register
             REG_SIZE  : natural := 4   -- Register selector on 4 bits (16 regs)
             );
    port (I_clock  : in STD_LOGIC; -- Clock
          I_reset  : in STD_LOGIC; -- Reset
          I_enable : in STD_LOGIC; -- Enable
          -- Inputs
          I_we   : in STD_LOGIC);                               -- Write Enable (write the destination value or not)
          I_selD : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);   -- Input - select destination
          I_selA : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);   -- Input - select source A
          I_selB : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);   -- Input - select source B
          I_dataD: in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);  -- Input Data to store in a register
          -- Outputs
          O_dataB: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Output B from regB
          O_dataA: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Output A from regA
          O_dataD: out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); -- Output D from regD (in case of STORE/LOAD/JMP)

end reg;

-- =================
--   Architecture
-- =================

architecture arch_reg of reg is
    -- Internal Objects
    type store_t is array (0 to 2**REG_SIZE-1) of STD_LOGIC_VECTOR(REG_WIDTH-1 downto 0); -- Array of given number SLVs set to a given size
    signal reg_bank: store_t := (others => X"0000");                                  -- Affectation of the array and initialization at 0
begin
    -- Processes
    TransferData: process(I_clock) -- I_clock added to the sensitivity list of the process
    begin
        if rising_edge(I_clock) then
          if I_reset = '1' then -- Reset routine
            reg_bank <= (others => X"0000");
          elsif I_enable= '1' then
            O_dataA <= reg_bank(to_integer(unsigned(I_selA)));     -- Propagate the input to the output (A)
            O_dataB <= reg_bank(to_integer(unsigned(I_selB)));     -- Propagate the input to the output (B)
            O_dataD <= reg_bank(to_integer(unsigned(I_selD)));     -- Propagate the input to the output (D)
            if (I_we = '1') then                                   -- If write-enable propagate the data
              reg_bank(to_integer(unsigned(I_selD))) <= I_dataD; -- Write dataD to the selD register
            end if;
          end if;
        end if;
    end process;
end arch_reg;
