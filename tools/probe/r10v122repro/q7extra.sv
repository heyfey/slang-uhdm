// r10v122 arm q7 - shapes the pass's own grid did not spell.
package Psi7_pkg;
  // x01 COMPOUND assignment ON THE SELECT itself
  function automatic int Fn_selCompound(int h1);
    bit [15:0] vX1;
    vX1 = 16'h1;
    if (h1 != 0) begin
      vX1 ^= 16'h2;
      vX1[3] ^= 1'b1;
    end
    Fn_selCompound = int'(vX1);
  endfunction

  // x02 a PROCEDURAL CONTINUOUS assign (assign_stmt) holds the select
  function automatic int Fn_assignStmt(int h2);
    bit [15:0] vX2;
    vX2 = 16'h4;
    if (h2 != 1) begin
      vX2 |= 16'h5;
      vX2[6] = 1'b1;
    end
    Fn_assignStmt = int'(vX2);
  endfunction

  // x03 THREE nested blocks, each with its own select of the SAME variable
  function automatic int Fn_threeDeep(int h3);
    bit [15:0] vX3;
    vX3 = 16'h7;
    if (h3 != 2) begin
      vX3[15:12] = 4'h1;
      if (h3 > 3) begin
        vX3[11:8] = 4'h2;
        if (h3 > 4) begin
          vX3[7:4] = 4'h3;
          vX3 ^= 16'h8;
        end
      end
    end
    Fn_threeDeep = int'(vX3);
  endfunction

  // x04 the SAME variable selected in TWO SIBLING blocks
  function automatic int Fn_twoSiblings(int h4);
    bit [15:0] vX4;
    vX4 = 16'h9;
    if (h4 != 3) begin
      vX4[1] = 1'b1;
      vX4 ^= 16'hA;
    end
    if (h4 != 4) begin
      vX4[14:10] = 5'h5;
      vX4 |= 16'hB;
    end
    Fn_twoSiblings = int'(vX4);
  endfunction

  // x05 a MULTI-DECLARATOR block-item declaration
  function automatic int Fn_multiDecl(int h5);
    bit [15:0] vX5a, vX5b;
    vX5a = 16'hC; vX5b = 16'hD;
    if (h5 != 5) begin
      vX5a ^= 16'hE;
      vX5a[2] = 1'b1;
      vX5b[13:11] = 3'h2;
      vX5b |= 16'hF;
    end
    Fn_multiDecl = int'(vX5a ^ vX5b);
  endfunction

  // x06 a DYNAMIC-ARRAY / QUEUE local beside a selected packed vector
  function automatic int Fn_queueBeside(int h6);
    int qX6 [$];
    bit [15:0] vX6;
    vX6 = 16'h10;
    qX6.push_back(h6);
    if (h6 != 6) begin
      vX6 ^= 16'h11;
      vX6[5] = 1'b1;
    end
    Fn_queueBeside = int'(vX6) + qX6.size();
  endfunction

  // x07 a DO-WHILE body
  function automatic int Fn_doWhile(int h7);
    bit [15:0] vX7;
    int kX7;
    vX7 = 16'h12; kX7 = 0;
    if (h7 != 7) begin
      vX7[9] = 1'b1;
      do begin
        vX7 ^= 16'h13;
        kX7++;
      end while (kX7 < 2);
    end
    Fn_doWhile = int'(vX7);
  endfunction

  // x08 a FOREACH body
  function automatic int Fn_foreach(int h8);
    bit [15:0] vX8;
    int aX8 [3];
    vX8 = 16'h14;
    if (h8 != 8) begin
      vX8[7] = 1'b1;
      foreach (aX8[ix]) begin
        vX8 ^= 16'(aX8[ix]);
      end
    end
    Fn_foreach = int'(vX8);
  endfunction

  // x09 the select's INDEX is itself a reference to a selected variable
  function automatic int Fn_idxIsRef(int h9);
    bit [15:0] vX9;
    bit [3:0]  iX9;
    vX9 = 16'h15; iX9 = 4'h2;
    if (h9 != 9) begin
      iX9 ^= 4'h3;
      vX9[iX9] = 1'b1;
      iX9[1] = 1'b0;
    end
    Fn_idxIsRef = int'(vX9) + int'(iX9);
  endfunction

  // x10 an UNPACKED-array element write beside a whole read - NEGATIVE-ish
  function automatic int Fn_unpackedElem(int hA);
    bit [7:0] uXA [0:3];
    int sXA;
    sXA = 0;
    if (hA != 10) begin
      uXA[1] = 8'h16;
      sXA = int'(uXA[1]);
    end
    Fn_unpackedElem = sXA;
  endfunction
endpackage
