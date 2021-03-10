-- TPU Blogpost series by @domipheus
-- Author: Quentin Ducasse
--   mail:   quentin.ducasse@ensta-bretagne.org
--   github: QDucasse
-- =================================
-- Testbench for the decode entity.

-- =================
--    Libraries
-- =================

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.sdvu_constants.all;

-- =================
--      Entity
-- =================

entity decoder_tb is
end decoder_tb;

-- =================
--   Architecture
-- =================

architecture arch_decoder_tb of decoder_tb is
    -- Internal Objects
    -- Clock and Enable signals
    constant HALF_PERIOD : time := 5 ns; -- Clock half period
    signal clock     : std_logic  := '0';  -- Clock signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

    -- Wait for a given number of clock cycles
    procedure wait_cycles(n : natural) is
     begin
       for i in 1 to n loop
         wait until rising_edge(clock);
       end loop;
     end procedure;

     -- Signals for decode
     signal I_instruction : STD_LOGIC_VECTOR (31 downto 0);
     signal O_op_code    : STD_LOGIC_VECTOR (3  downto 0);
     signal O_cfgMask  : STD_LOGIC_VECTOR (1  downto 0);
     signal O_rD       : STD_LOGIC_VECTOR (3  downto 0);
     signal O_rA       : STD_LOGIC_VECTOR (3  downto 0);
     signal O_rB       : STD_LOGIC_VECTOR (3  downto 0);
     signal O_immA     : STD_LOGIC_VECTOR (10 downto 0);
     signal O_immB     : STD_LOGIC_VECTOR (10 downto 0);
     signal O_address  : STD_LOGIC_VECTOR (23 downto 0);
     signal O_type     : STD_LOGIC_VECTOR (1  downto 0);
     signal O_regDwe   : STD_LOGIC;



begin
    -- Clock and enable signals
    enable  <= '0', '1' after 50 ns;
    clock <= not(clock) after HALF_PERIOD when running else clock;
    -- DUT
      dut : entity work.decoder(arch_decoder)
      port map (
      I_clock      => clock,
      I_enable      => enable,
        I_instruction => I_instruction,
        O_op_code    => O_op_code,
        O_cfgMask  => O_cfgMask,
        O_rD       => O_rD,
        O_rA       => O_rA,
        O_rB       => O_rB,
        O_immA     => O_immA,
        O_immB     => O_immB,
        O_address  => O_address,
        O_type     => O_type,
        O_regDwe   => O_regDwe
      );

    -- Stimulus process
    StimulusProcess: process
      variable res1, res2, res3, res4, res5, res6,
               res7, res8, res9, res10, res11, res12: boolean;

    begin
      report "DECODE: Running testbench";
      wait until enable='1';
      wait_cycles(1);

      -- TESTING OPERATIONS

      -- Test 1: Binary - RR Instruction type
      I_instruction <= OP_SUB & "00" & "1111" & "00000000000" & "00000000001";
      -- OP_SUB(0001) | CFG_RR(00) | RD = 15(1111) | RA = 0 (0000000 0000) | RB = 1 (0000000 0001)
      wait_cycles(2);
      res1 := ((O_op_code = OP_SUB)   and
               (O_cfgMask = CFG_RR) and
               (O_rD = "1111")      and
               (O_rA = "0000")      and
               (O_rB = "0001")      and
               (O_regDwe = '1'));
      if res1 then report "Test Binary - RR: Passed" severity NOTE;
        else report "Test Binary - RR: Failed" severity FAILURE;
      end if;

      -- Test 2: Binary - RI Instruction type
      I_instruction <= OP_MUL & "01" & "1110" & "00000000000" & "11111111111";
      -- OP_MUL(0010) | CFG_RI(01) | RD = 14 (1110) | RA = 0 (0000000 0000) | ImmB = 2047 (11111111111)
      wait_cycles(2);
      res2 := ((O_op_code = OP_MUL)       and
               (O_cfgMask = CFG_RI)     and
               (O_rD = "1110")          and
               (O_rA = "0000")          and
               (O_immB = "11111111111") and
               (O_regDwe = '1'));
      if res2 then report "Test Binary - RI: Passed" severity NOTE;
        else report "Test Binary - RI: Failed" severity FAILURE;
      end if;

      -- Test 3: Binary - IR Instruction type
      I_instruction <= OP_DIV & "10" & "1101" & "11111111111" & "00000000010";
      -- OP_DIV(0011) | CFG_IR(10) | RD = 13 (1101) | ImmA = 2047 (11111111111) | RB = 2 (0000000 0010)
      wait_cycles(2);
      res3 := ((O_op_code = OP_DIV)       and
               (O_cfgMask = CFG_IR)     and
               (O_rD = "1101")          and
               (O_immA = "11111111111") and
               (O_rB = "0010")          and
               (O_regDwe = '1'));
      if res3 then report "Test Binary - IR: Passed" severity NOTE;
        else report "Test Binary - IR: Failed" severity FAILURE;
      end if;

      -- Test 4: Binary - II Instruction type
      I_instruction <= OP_ADD & "11" & "1111" & "11111111111" & "11111111111";
      -- OP_ADD (0000) | CFG_II(11) | RD = 15 (1111) | ImmA = 2047 (11111111111) | ImmB = 2 (11111111111)
      wait_cycles(2);
      res4 := ((O_op_code = OP_ADD)       and
               (O_cfgMask = CFG_II)     and
               (O_rD = "1111")          and
               (O_immA = "11111111111") and
               (O_immB = "11111111111") and
               (O_regDwe = '1'));
      if res4 then report "Test Binary - II: Passed" severity NOTE;
        else report "Test Binary - II: Failed" severity FAILURE;
      end if;

      -- Test 5: NOT
      I_instruction <= OP_NOT & "1111" & "000000000000000000000001";
      -- OP_NOT (1010) | RD = 15 (1111) | RA = 1 (00000000000000000000 0001)
      wait_cycles(2);
      res5 := ((O_op_code = OP_NOT) and
               (O_rD = "1111")    and
               (O_rA = "0001")    and
               (O_regDwe = '1'));
      if res5 then report "Test NOT: Passed" severity NOTE;
        else report "Test NOT: Failed" severity FAILURE;
      end if;

      -- Test 6: LOAD - REG
      I_instruction <= OP_LOAD & "00" & "00" & "1111" & "00000000000000000001";
      -- OP_LOAD(1101) | LOAD_REG(00) | VAL_BOOL (00) | RD = 15 (1111) | RA = 1 (0000000000000000 0001)
      wait_cycles(2);
      res6 := ((O_op_code = OP_LOAD)    and
               (O_cfgMask = LOAD_REG) and
               (O_type = VAL_BOOL)    and
               (O_rD = "1111")        and
               (O_rA = "0001")        and
               (O_regDwe = '1'));
      if res6 then report "Test LOAD - REG: Passed" severity NOTE;
        else report "Test LOAD - REG: Failed" severity FAILURE;
      end if;

      -- Test 7: LOAD - IMM
      I_instruction <= OP_LOAD & "01" & "01" & "1111" & "00000000011111111111";
      -- OP_LOAD(1101) | LOAD_IMM(01) | VAL_BYTE (01) | RD = 15 (1111) | ImmA = 2047 (000000000 11111111111)
      wait_cycles(2);
      res7 := ((O_op_code = OP_LOAD)      and
               (O_cfgMask = LOAD_IMM)   and
               (O_type = VAL_BYTE)      and
               (O_rD = "1111")          and
               (O_immA = "11111111111") and
               (O_regDwe = '1'));
      if res7 then report "Test LOAD - IMM: Passed" severity NOTE;
        else report "Test LOAD - IMM: Failed" severity FAILURE;
      end if;

      -- Test 8: LOAD - ADR
      I_instruction <= OP_LOAD & "10" & "10" & "1111" & "11111111111111111111";
      -- OP_LOAD(1101) | LOAD_ADR(10) | VAL_INT (10) | RD = 15 (1111) | address = 1048575 (11111111111111111111)
      wait_cycles(2);
      res8 := ((O_op_code = OP_LOAD)                      and
               (O_cfgMask = LOAD_ADR)                   and
               (O_type = VAL_INT)                       and
               (O_rD = "1111")                          and
               (O_address = "000011111111111111111111") and
               (O_regDwe = '1'));
      if res8 then report "Test LOAD - ADR: Passed" severity NOTE;
        else report "Test LOAD - ADR: Failed" severity FAILURE;
      end if;

      -- Test 9: LOAD - RAA
      I_instruction <= OP_LOAD & "11" & "11" & "1111" & "00000000000000000001";
      -- OP_LOAD(1101) | LOAD_RAA(11) | VAL_STATE (11) | RD = 15 (1111) | RA = 1 (0000000000000000 0001)
      wait_cycles(2);
      res9 := ((O_op_code = OP_LOAD)    and
               (O_cfgMask = LOAD_RAA) and
               (O_type = VAL_STATE)   and
               (O_rD = "1111")        and
               (O_rA = "0001")        and
               (O_regDwe = '1'));
      if res9 then report "Test LOAD - RAA: Passed" severity NOTE;
        else report "Test LOAD - RAA: Failed" severity FAILURE;
      end if;

      -- Test 10: STORE - ADR
      I_instruction <= OP_STORE & "00" & "00" & "1111" & "11111111111111111111";
      -- OP_STORE(1100) | STORE_ADR(00) | VAL_BOOL (00) | RD = 15 (1111) | address = 1048575 (11111111111111111111)
      wait_cycles(2);
      res10 := ((O_op_code = OP_STORE)                     and
                (O_cfgMask = STORE_ADR)                  and
                (O_type = VAL_BOOL)                      and
                (O_rD = "1111")                          and
                (O_address = "000011111111111111111111") and
                (O_regDwe = '0'));
      if res10 then report "Test STORE - ADR: Passed" severity NOTE;
        else report "Test STORE - ADR: Failed" severity FAILURE;
      end if;

      -- Test 11: STORE - RAA
      I_instruction <= OP_STORE & "01" & "01" & "1111" & "00000000000000000001";
      -- OP_STORE(1100) | STORE_RAA(01) | VAL_BYTE (01) | RD = 15 (1111) | RA = 1 (0000000000000000 0001)
      wait_cycles(2);
      res11 := ((O_op_code = OP_STORE)    and
                (O_cfgMask = STORE_RAA) and
                (O_type = VAL_BYTE)     and
                (O_rD = "1111")         and
                (O_rA = "0001")         and
                (O_regDwe = '0'));
      if res11 then report "Test STORE - RAA: Passed" severity NOTE;
        else report "Test STORE - RAA: Failed" severity FAILURE;
      end if;

      -- Test 12: JMP
      I_instruction <= OP_JMP & "1111" & "111111111111111111111111";
      -- OP_JMP(1011) | RD = 15 (1111) | RA = 1 ( )
      wait_cycles(2);
      res12 := ((O_op_code = OP_JMP)                       and
                (O_rD = "1111")                          and
                (O_address = "111111111111111111111111") and
                (O_regDwe = '0'));
      if res12 then report "Test JMP: Passed" severity NOTE;
        else report "Test JMP: Failed" severity FAILURE;
      end if;



      running <= false;
      report "DECODE: Testbench complete";
    end process;

end arch_decoder_tb;
