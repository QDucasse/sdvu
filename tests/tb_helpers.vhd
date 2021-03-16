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
  procedure genClock(signal clock : inout std_logic; signal running : in boolean; half_period : time);
  -- Generate a reset signal for a given reset time
  procedure genReset(signal reset : inout std_logic; reset_time : time; high : boolean);
  -- Generate an enable signal for a given reset time
  procedure genEnable(signal enable : inout std_logic; enable_time : time; high : boolean);
  -- Wait for a given number of cycles
  procedure wait_cycles(signal clock : in std_logic; n : natural);
  -- Test a condition and reports a message
  procedure test_expression(condition : boolean; test_name : string);

  -- Convert an int to the corresponding std logic vector
  pure function int_to_slv(i : integer) return std_logic_vector;
end package tb_helpers;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package body tb_helpers is

  -- Generate a clock with a given half period
  procedure genClock(signal clock   : inout std_logic;
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
  procedure genReset(signal reset : inout std_logic;
                     reset_time   : time;
                     high         : boolean) is
    begin
      if high then
        reset <= '1';
        wait for reset_time;
        reset <= '0';
      else
        reset <= '0';
        wait for reset_time;
        reset <= '1';
      end if;
      wait;
    end procedure;

    -- Generate a reset signal after a given time
    procedure genEnable(signal enable : inout std_logic;
                        enable_time   : time;
                        high          : boolean) is
      begin
        if high then
          enable <= '1';
          wait for enable_time;
          enable <= '0';
        else
          enable <= '0';
          wait for enable_time;
          enable <= '1';
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

    -- Test a given expression and reports the result
    procedure test_expression(condition : boolean;
                              test_name : string) is
      begin
        if (condition) then report (test_name & ": passed") severity NOTE;
          else report (test_name & ": Failed") severity FAILURE;
        end if;
      end procedure;

    -- Convert an int to the corresponding std logic vector
    pure function int_to_slv(i : integer) return std_logic_vector is
      begin
        return std_logic_vector(to_unsigned(i, 32));
      end function;

end package body tb_helpers;
