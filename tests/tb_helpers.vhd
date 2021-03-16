-- =================================
-- Testbench helpers

-- =================
--    Libraries
-- =================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tb_helpers is
  -- Generate a clock signal with a given half period
  procedure genClk(signal clock : inout std_logic; signal running : in boolean; half_period : time);
  -- Reset the signal for a given reset time
  procedure genReset(signal reset_n : inout std_logic; reset_time : time; high : boolean);
  -- Wait for a given number of cycles
  procedure wait_cycles(signal clock : in std_logic; n : natural);
  -- Convert an int to the corresponding std logic vector
  pure function int_to_slv(i : integer) return std_logic_vector;
end package tb_helpers;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package body tb_helpers is


  pure function int_to_slv(i : integer) return std_logic_vector is
   begin
     return std_logic_vector(to_unsigned(i, 32));
  end function;


  -- Generate a clock with a given half period
  procedure genClk(signal clock   : inout std_logic;
                   signal running : in boolean;
                   half_period    : time) is
    begin
      if running then
        clock <= '1';
        wait for half_period;
        clock <= '0';
        wait for half_period;
      else
        wait;
      end if;
    end procedure;

  -- Generate a reset signal after a given time
  procedure genReset(signal reset_n : inout std_logic;
                     reset_time : time;
                     high       : boolean) is
    begin
      if high then
        reset_n <= '1';
        wait for reset_time;
        reset_n <= '0';
      else
        reset_n <= '0';
        wait for reset_time;
        reset_n <= '1';
      end if;
      wait;
    end procedure;


  -- Wait for a given number of cycles
  procedure wait_cycles(signal clock : in std_logic;
                        n : natural) is
    begin
      for i in 1 to n loop
        wait until rising_edge(clock);
      end loop;
    end procedure;

end package body tb_helpers;
