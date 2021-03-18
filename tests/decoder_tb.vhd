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
use work.tb_helpers.all;

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
    signal clock   : std_logic  := '0';  -- Clock signal
    signal enable  : std_logic  := '0';  -- Enable signal
    signal running : boolean    := true; -- Running flag, Simulation continues while true

     -- Signals for decode
     signal I_instruction    : STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0);
     signal O_op_code        : STD_LOGIC_VECTOR (OP_SIZE-1 downto 0);
     signal O_cfgMask        : STD_LOGIC_VECTOR (1 downto 0);
     signal O_rA, O_rb, O_rd : STD_LOGIC_VECTOR (REG_SEL_SIZE-1  downto 0);
     signal O_imma, O_immB   : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
     signal O_address        : STD_LOGIC_VECTOR (REG_SIZE-1 downto 0);
     signal O_type           : STD_LOGIC_VECTOR (1 downto 0);

begin
    -- Clock, Reset and Enable generation
    ClockProcess : process
    begin
      genClock(clock, running, HALF_PERIOD);
    end process;

    EnableProcess : process
    begin
      genPulse(enable, 10 ns, false);
    end process;

    -- DUT
      dut : entity work.decoder(arch_decoder)
        port map (
          I_clock       => clock,
          I_enable      => enable,
          I_instruction => I_instruction,
          O_op_code     => O_op_code,
          O_cfgMask     => O_cfgMask,
          O_rA          => O_rA,
          O_rB          => O_rB,
          O_rD          => O_rD,
          O_immA        => O_immA,
          O_immB        => O_immB,
          O_address     => O_address,
          O_type        => O_type
        );


    -- Stimulus process
    StimulusProcess: process
    begin
      wait until enable='1';
      report "DECODE: Running testbench";
      -- TESTING OPERATIONS
      -- Test 1: Binary - RR Instruction type
      I_instruction <= OP_SUB & "00" & "1111" & "00000000001" & "00000000010";
      -- OP_SUB(0001) | CFG_RR(00) | RD = 15(1111) | RA = 0 (0000000 0000) | RB = 1 (0000000 0001)
      wait_cycles(clock, 2);
      -- Used
      assert_true(O_op_code=OP_SUB,      "Binary RR - Correct OP Code");
      assert_true(O_cfgMask=CFG_RR,      "Binary RR - Correct Config Mask");
      assert_true(O_rd=X"F",             "Binary RR - Correct RD Selector");
      assert_true(O_ra=X"1",             "Binary RR - Correct RA Selector");
      assert_true(O_rb=X"2",             "Binary RR - Correct RB Selector");
      -- Unused but computed
      assert_true(O_immA=X"00000001",    "Binary RR - ImmA unused");
      assert_true(O_immB=X"00000002",    "Binary RR - ImmB unused");
      -- Unused not computed
      assert_true(O_address=X"00000000", "Binary RR - Address unused");
      assert_true(O_type="00",           "Binary RR - Type unused");

      -- Test 2: Binary - RI Instruction type
      I_instruction <= OP_MUL & "01" & "1110" & "00000000010" & "11111111111";
      -- OP_MUL(0010) | CFG_RI(01) | RD = 14 (1110) | RA = 0 (0000000 0000) | ImmB = 2047 (11111111111)
      wait_cycles(clock, 2);
      -- Used
      assert_true(O_op_code=OP_MUL,      "Binary RI - Correct OP Code");
      assert_true(O_cfgMask=CFG_RI,      "Binary RI - Correct Config Mask");
      assert_true(O_rd=X"E",             "Binary RI - Correct RD Selector");
      assert_true(O_ra=X"2",             "Binary RI - Correct RA Selector");
      assert_true(O_immB=X"000007FF",    "Binary RI - Correct ImmB");
      -- Unused but computed
      assert_true(O_rb=X"F",             "Binary RI - RB unused");
      assert_true(O_immA=X"00000002",    "Binary RI - ImmA unused");
      -- Unused
      assert_true(O_address=X"00000000", "Binary RI - Address unused");
      assert_true(O_type="00",           "Binary RI - Type unused");



      -- Test 3: Binary - IR Instruction type
      I_instruction <= OP_DIV & "10" & "1101" & "11111111111" & "00000000010";
      -- OP_DIV(0011) | CFG_IR(10) | RD = 13 (1101) | ImmA = 2047 (11111111111) | RB = 2 (0000000 0010)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_DIV,      "Binary IR - Correct OP Code");
      assert_true(O_cfgMask=CFG_IR,      "Binary IR - Correct Config Mask");
      assert_true(O_rd=X"D",             "Binary IR - Correct RD Selector");
      assert_true(O_immA=X"000007FF",    "Binary IR - Correct ImmA");
      assert_true(O_rb=X"2",             "Binary IR - Correct RB Selector");
      -- Unused but computed
      assert_true(O_ra=X"F",             "Binary IR - RA unused");
      assert_true(O_immB=X"00000002",    "Binary IR - ImmB unused");
      -- Unused
      assert_true(O_address=X"00000000", "Binary IR - Address unused");
      assert_true(O_type="00",           "Binary IR - Type unused");

      -- Test 4: Binary - II Instruction type
      I_instruction <= OP_ADD & "11" & "1111" & "11111111111" & "11111111111";
      -- OP_ADD (0000) | CFG_II(11) | RD = 15 (1111) | ImmA = 2047 (11111111111) | ImmB = 2 (11111111111)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_ADD,      "Binary II - Correct OP Code");
      assert_true(O_cfgMask=CFG_II,      "Binary II - Correct Config Mask");
      assert_true(O_rd=X"F",             "Binary II - Correct RD Selector");
      assert_true(O_immA=X"000007FF",    "Binary II - Correct ImmA");
      assert_true(O_immB=X"000007FF",    "Binary II - Correct ImmB");
      -- Unused but computed
      assert_true(O_ra=X"F",             "Binary II - RA unused");
      assert_true(O_rb=X"F",             "Binary II - RB unused");
      -- Unused
      assert_true(O_address=X"00000000", "Binary II - Address unused");
      assert_true(O_type="00",           "Binary II - Type unused");

      -- Test 5: NOT
      I_instruction <= OP_NOT & "1111" & "000000000000000000000001";
      -- OP_NOT (1010) | RD = 15 (1111) | RA = 1 (00000000000000000000 0001)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_NOT,      "Not - Correct OP Code");
      assert_true(O_ra=X"1",             "Not - Correct RA Selector");
      assert_true(O_rd=X"F",             "Not - Correct RD Selector");
      -- Unused
      assert_true(O_immA=X"00000000",    "Not - ImmA unused");
      assert_true(O_immB=X"00000000",    "Not - ImmB unused");
      assert_true(O_cfgMask="00",        "Not - Config Mask unused");
      assert_true(O_rb=X"0",             "Not - RB unused");
      assert_true(O_address=X"00000000", "Not - Address unused");
      assert_true(O_type="00",           "Not - Type unused");

      -- Test 6: LOAD - REG
      I_instruction <= OP_LOAD & "00" & "00" & "1111" & "00000000000000000001";
      -- OP_LOAD(1101) | LOAD_REG(00) | VAL_BOOL (00) | RD = 15 (1111) | RA = 1 (0000000000000000 0001)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_LOAD,     "Load Reg - Correct OP Code");
      assert_true(O_cfgMask=LOAD_REG,    "Load Reg - Correct Config Mask");
      assert_true(O_ra=X"1",             "Load Reg - Correct RA Selector");
      assert_true(O_rd=X"F",             "Load Reg - Correct RD Selector");
      assert_true(O_type=TYPE_BOOL,      "Load Reg - Correct type");
      -- Unused but computed
      assert_true(O_immA=X"00000001",    "Load Reg - ImmA unused");
      assert_true(O_address=X"00000001", "Load Reg - Address unused");
      -- Unused not computed
      assert_true(O_immB=X"00000000",    "Load Reg - ImmB unused");
      assert_true(O_rb=X"0",             "Load Reg - RB unused");


      -- Test 7: LOAD - IMM
      I_instruction <= OP_LOAD & "01" & "01" & "1111" & "00000000011111111111";
      -- OP_LOAD(1101) | LOAD_IMM(01) | VAL_BYTE (01) | RD = 15 (1111) | ImmA = 2047 (000000000 11111111111)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_LOAD,     "Load Imm - Correct OP Code");
      assert_true(O_cfgMask=LOAD_IMM,    "Load Imm - Correct Config Mask");
      assert_true(O_immA=X"000007FF",    "Load Imm - Correct ImmA");
      assert_true(O_rd=X"F",             "Load Imm - Correct RD Selector");
      assert_true(O_type=TYPE_BYTE,      "Load Imm - Correct type");
      -- Unused but computed
      assert_true(O_ra=X"F",             "Load Imm - RA unused");
      assert_true(O_address=X"000007FF", "Load Imm - Address unused");
      -- Unused not computed
      assert_true(O_immB=X"00000000",    "Load Imm - ImmB unused");
      assert_true(O_rb=X"0",             "Load Imm - RB unused");

      -- Test 8: LOAD - ADR
      I_instruction <= OP_LOAD & "10" & "10" & "1111" & "11111111111111111111";
      -- OP_LOAD(1101) | LOAD_ADR(10) | VAL_INT (10) | RD = 15 (1111) | address = 1048575 (11111111111111111111)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_LOAD,     "Load Adr - Correct OP Code");
      assert_true(O_cfgMask=LOAD_ADR,    "Load Adr - Correct Config Mask");
      assert_true(O_address=X"000FFFFF", "Load Adr - Correct Address");
      assert_true(O_rd=X"F",             "Load Adr - Correct RD Selector");
      assert_true(O_type=TYPE_INT,       "Load Adr - Correct type");
      -- Unused but computed
      assert_true(O_ra=X"F",             "Load Adr - RA unused");
      assert_true(O_immA=X"000007FF",    "Load Adr - ImmA unused");
      -- Unused not computed
      assert_true(O_immB=X"00000000",    "Load Adr - ImmB unused");
      assert_true(O_rb=X"0",             "Load Adr - RB unused");

      -- Test 9: LOAD - RAA
      I_instruction <= OP_LOAD & "11" & "11" & "1111" & "00000000000000000001";
      -- OP_LOAD(1101) | LOAD_RAA(11) | VAL_STATE (11) | RD = 15 (1111) | RA = 1 (0000000000000000 0001)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_LOAD,     "Load Raa - Correct OP Code");
      assert_true(O_cfgMask=LOAD_RAA,    "Load Raa - Correct Config Mask");
      assert_true(O_ra=X"1",             "Load Raa - Correct RA Selector");
      assert_true(O_rd=X"F",             "Load Raa - Correct RD Selector");
      assert_true(O_type=TYPE_STATE,     "Load Raa - Correct type");
      -- Unused but computed
      assert_true(O_immA=X"00000001",    "Load Raa - ImmA unused");
      assert_true(O_address=X"00000001", "Load Raa - Address unused");
      -- Unused not computed
      assert_true(O_immB=X"00000000",    "Load Raa - ImmB unused");
      assert_true(O_rb=X"0",             "Load Raa - RB unused");

      -- Test 10: STORE - ADR
      I_instruction <= OP_STORE & "00" & "00" & "1111" & "11111111111111111111";
      -- OP_STORE(1100) | STORE_ADR(00) | VAL_BOOL (00) | RD = 15 (1111) | address = 1048575 (11111111111111111111)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_STORE,    "Store Adr - Correct OP Code");
      assert_true(O_cfgMask=STORE_ADR,   "Store Adr - Correct Config Mask");
      assert_true(O_address=X"000FFFFF", "Store Adr - Correct Address");
      assert_true(O_rd=X"F",             "Store Adr - Correct RD Selector");
      assert_true(O_type=TYPE_BOOL,      "Store Adr - Correct type");
      -- Unused but computed
      assert_true(O_ra=X"F",             "Store Adr - RA unused");
      -- Unused not computed
      assert_true(O_immA=X"00000000",    "Store Adr - ImmA unused");
      assert_true(O_immB=X"00000000",    "Store Adr - ImmB unused");
      assert_true(O_rb=X"0",             "Store Adr - RB unused");

      -- Test 11: STORE - RAA
      I_instruction <= OP_STORE & "01" & "01" & "1111" & "00000000000000000001";
      -- OP_STORE(1100) | STORE_RAA(01) | VAL_BYTE (01) | RD = 15 (1111) | RA = 1 (0000000000000000 0001)
      wait_cycles(clock, 2);
      assert_true(O_op_code=OP_STORE,    "Store Raa - Correct OP Code");
      assert_true(O_cfgMask=STORE_RAA,   "Store Raa - Correct Config Mask");
      assert_true(O_ra=X"1",             "Store Raa - Correct RA Selector");
      assert_true(O_rd=X"F",             "Store Raa - Correct RD Selector");
      assert_true(O_type=TYPE_BYTE,      "Store Raa - Correct type");
      -- Unused but computed
      assert_true(O_address=X"00000001", "Store Raa - Address unused");
      -- Unused not computed
      assert_true(O_immA=X"00000000",    "Store Raa - ImmA unused");
      assert_true(O_immB=X"00000000",    "Store Raa - ImmB unused");
      assert_true(O_rb=X"0",             "Store Raa - RB unused");

      -- Test 12: JMP
      I_instruction <= OP_JMP & "1111" & "111111111111111111111111";
      -- OP_JMP(1011) | RD = 15 (1111) | Addr = FFFFFF
      wait_cycles(clock, 2);
      -- Used
      assert_true(O_op_code=OP_JMP,      "Jump - Correct OP Code");
      assert_true(O_address=X"00FFFFFF", "Jump - Correct Address");
      assert_true(O_rd=X"F",             "Jump - Correct RD Selector");
      -- Unused
      assert_true(O_cfgMask="00",        "Jump - Config Mask unused");
      assert_true(O_type="00",           "Jump - Type unused");
      assert_true(O_ra=X"0",             "Jump - RA unused");
      assert_true(O_immA=X"00000000",    "Jump - ImmA unused");
      assert_true(O_immB=X"00000000",    "Jump - ImmB unused");
      assert_true(O_rb=X"0",             "Jump - RB unused");

      running <= false;
      report "DECODE: Testbench complete";
    end process;

end arch_decoder_tb;
