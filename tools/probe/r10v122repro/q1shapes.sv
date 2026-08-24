// r10v122 arm q1 - every SELECT SHAPE on a subroutine-local packed vector,
// each cell in its OWN nested begin so the declaring block never answers.
package Zeta9_pkg;
  parameter int POLY9 = 32'h04C11DB7;
  localparam int IDX3 = 3;

  // c01 bit select, LITERAL index (the head's own shape)
  function automatic int unsigned Fn_bitLit(int unsigned s0);
    bit [31:0] regQ;
    regQ = 32'hFFFF_FFFF;
    if (s0 != 0) begin
      regQ ^= POLY9;
      regQ[0] = 1'b1;
    end
    Fn_bitLit = regQ;
  endfunction

  // c02 PART select
  function automatic int unsigned Fn_partSel(int unsigned s1);
    bit [31:0] regW;
    regW = 32'h0;
    if (s1 > 2) begin
      regW |= 32'h55;
      regW[7:4] = 4'h5;
    end
    Fn_partSel = regW;
  endfunction

  // c03 INDEXED part select, ASCENDING
  function automatic int unsigned Fn_idxUp(int unsigned s2, int kk);
    bit [31:0] regE;
    regE = 32'h1;
    if (kk > 0) begin
      regE ^= s2;
      regE[kk +: 4] = 4'h2;
    end
    Fn_idxUp = regE;
  endfunction

  // c04 INDEXED part select, DESCENDING
  function automatic int unsigned Fn_idxDn(int unsigned s3, int mm);
    bit [31:0] regR;
    regR = 32'h2;
    if (mm > 8) begin
      regR &= s3;
      regR[mm -: 4] = 4'h3;
    end
    Fn_idxDn = regR;
  endfunction

  // c05 VARIABLE index (a var_select in golden)
  function automatic int unsigned Fn_varIdx(int unsigned s4, int nn);
    bit [31:0] regT;
    regT = 32'h4;
    if (nn != 7) begin
      regT ^= s4;
      regT[nn] = 1'b0;
    end
    Fn_varIdx = regT;
  endfunction

  // c06 PARAMETER index
  function automatic int unsigned Fn_parmIdx(int unsigned s5);
    bit [31:0] regY;
    regY = 32'h8;
    if (s5 == 9) begin
      regY += 32'd4;
      regY[IDX3] = 1'b1;
    end
    Fn_parmIdx = regY;
  endfunction

  // c07 2-D UNPACKED element write
  function automatic int Fn_twoDim(int s6);
    bit [7:0] memI [0:3];
    int accV;
    accV = 0;
    if (s6 > 1) begin
      memI[2] = 8'hAA;
      accV = int'(memI[2]);
    end
    Fn_twoDim = accV;
  endfunction

  // c08 CONCAT lvalue - NEGATIVE (unnamed operation, no VpiName)
  function automatic int unsigned Fn_concatLv(int unsigned s7);
    bit [15:0] regO;
    bit [15:0] regP;
    regO = 16'h1; regP = 16'h2;
    if (s7 != 3) begin
      regO ^= 16'h30;
      {regO[1], regP[0]} = 2'b11;
    end
    Fn_concatLv = {regO, regP};
  endfunction

  // c09 RVALUE-only select - NEGATIVE
  function automatic int unsigned Fn_rvalOnly(int unsigned s8);
    bit [31:0] regA;
    bit resB;
    regA = s8;
    if (s8 > 5) begin
      resB = regA[3];
      regA ^= 32'h7;
    end
    Fn_rvalOnly = regA + 32'(resB);
  endfunction

  // c10 select NOT a direct statement - NEGATIVE
  function automatic int unsigned Fn_notDirect(int unsigned s9);
    bit [31:0] regC;
    regC = s9;
    if (s9 > 6) begin
      regC ^= 32'h9;
      if (s9 > 7) begin
        regC[5] = 1'b1;
      end
    end
    Fn_notDirect = regC;
  endfunction

  // c11 TWO selects - the FIRST in statement order must win
  function automatic int unsigned Fn_twoSel(int unsigned sA);
    bit [31:0] regD;
    regD = sA;
    if (sA != 11) begin
      regD ^= 32'hB;
      regD[11:8] = 4'hB;
      regD[1] = 1'b0;
    end
    Fn_twoSel = regD;
  endfunction

  // c12 WHOLE write with `=` before the select - its own ref must move too
  function automatic int unsigned Fn_wholeThenSel(int unsigned sB);
    bit [31:0] regF;
    regF = 32'h0;
    if (sB != 12) begin
      regF = 32'hC;
      regF[3] = 1'b1;
    end
    Fn_wholeThenSel = regF;
  endfunction

  // c13 select FIRST, whole reference AFTER
  function automatic int unsigned Fn_selThenWhole(int unsigned sC);
    bit [31:0] regG;
    regG = 32'h0;
    if (sC != 13) begin
      regG[6] = 1'b1;
      regG ^= 32'hD;
    end
    Fn_selThenWhole = regG;
  endfunction

  // c14 the DECLARING block also holds the select - golden keeps the DECL
  function automatic int unsigned Fn_declSel(int unsigned sD);
    bit [31:0] regH;
    regH = sD;
    regH[9] = 1'b1;
    regH ^= 32'hE;
    Fn_declSel = regH;
  endfunction
endpackage
