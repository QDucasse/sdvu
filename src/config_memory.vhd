-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Random Access Memory consisting of an array of 32 16-bits addresses
-- with writes and reads for the global variables configuration.

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

entity config_memory is
    port (I_clock    : in STD_LOGIC; -- Clock signal
          I_enable  : in STD_LOGIC;   -- Unit enable
          I_reset   : in STD_LOGIC;   -- Reset signal
          I_we      : in STD_LOGIC;   -- Write Enable
          I_type    : in STD_LOGIC_VECTOR(1 downto 0);               -- Indication on the type of the value
          I_address : in STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);     -- Address in the RAM
          I_data    : in STD_LOGIC_VECTOR (TYPE_SIZE-1 downto 0);    -- Data to write to address in memory
          O_data    : out STD_LOGIC_VECTOR (TYPE_SIZE-1 downto 0)    -- Read address from memory
          );
end config_memory;

-- =================
--   Architecture
-- =================

architecture arch_config_memory of config_memory is
    -- Internal Objects
    signal memory_bank : STD_LOGIC_VECTOR(2**CFG_MEM_SIZE-1 downto 0) := (others => '0');

begin
  -- Processes
  TransferData: process(I_clock) -- I_clock added to the sensitivity list of the process
  begin
      if rising_edge(I_clock) then  -- If new cycle
        if I_reset = '1' then     -- Reset
          memory_bank <= (others => '0');
        elsif (I_enable = '1') and (I_we = '1') then   -- If write-enable propagate the data
          -- Write the input to RAM address
          case I_type is
            when TYPE_BOOL =>
              memory_bank(to_integer(unsigned(I_address))+SIZE_BOOL-1  downto to_integer(unsigned(I_address))) <= I_data(SIZE_BOOL-1 downto 0);
            when TYPE_BYTE =>
              memory_bank(to_integer(unsigned(I_address))+SIZE_BYTE-1  downto to_integer(unsigned(I_address))) <= I_data(SIZE_BYTE-1 downto 0);
            when TYPE_INT =>
              memory_bank(to_integer(unsigned(I_address))+SIZE_INT-1   downto to_integer(unsigned(I_address))) <= I_data(SIZE_INT-1 downto 0);
            when TYPE_STATE =>
              memory_bank(to_integer(unsigned(I_address))+SIZE_STATE-1 downto to_integer(unsigned(I_address))) <= I_data(SIZE_STATE-1 downto 0);
            when others =>
              -- unreachable
          end case;
        elsif (I_enable = '1') then
          -- Read from the address to the output
          case I_type is
            when TYPE_BOOL =>
              O_data <= X"000000" & memory_bank(to_integer(unsigned(I_address))+SIZE_BOOL-1 downto to_integer(unsigned(I_address)));
            when TYPE_BYTE =>
              O_data <= X"000000" & memory_bank(to_integer(unsigned(I_address))+SIZE_BYTE-1 downto to_integer(unsigned(I_address)));
            when TYPE_INT =>
              O_data <= memory_bank(to_integer(unsigned(I_address))+SIZE_INT-1 downto to_integer(unsigned(I_address)));
            when TYPE_STATE =>
              O_data <= X"0000" & memory_bank(to_integer(unsigned(I_address))+SIZE_STATE-1 downto to_integer(unsigned(I_address)));
            when others =>
              -- Unreachable
          end case;
        end if;
    end if;
  end process;
end arch_config_memory;
