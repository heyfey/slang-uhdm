// r10v122 arm q2 - the same law across OWNERS and HOMES.
package Kappa4_pkg;
  bit [15:0] pkgLevelVec;               // package-scope variable
  class Widget7;
    bit [23:0] propVecA;                // class property
    bit [23:0] propVecB;
    function automatic int inBodyM(int aa);      // IN-BODY method
      bit [23:0] localU;
      localU = 24'h1;
      if (aa != 0) begin
        localU ^= 24'h2;
        localU[4] = 1'b1;
      end
      if (aa > 3) begin
        propVecA ^= 24'h3;
        propVecA[5] = 1'b0;
      end
      inBodyM = int'(localU);
    endfunction
    extern function int oobM(int bb);
  endclass

  function int Widget7::oobM(int bb);   // OUT-OF-BODY method
    bit [23:0] localV;
    localV = 24'h4;
    if (bb != 1) begin
      localV |= 24'h5;
      localV[6] = 1'b1;
    end
    if (bb > 4) begin
      propVecB ^= 24'h6;
      propVecB[7] = 1'b0;
    end
    oobM = int'(localV);
  endfunction

  // a PACKAGE VARIABLE read from a FREE package function
  function automatic int freeFn(int cc);
    if (cc != 2) begin
      pkgLevelVec ^= 16'h7;
      pkgLevelVec[8] = 1'b1;
    end
    freeFn = int'(pkgLevelVec);
  endfunction

  // a TASK local
  task automatic tskOne(input int dd, output int ee);
    bit [11:0] localW;
    localW = 12'h8;
    if (dd != 3) begin
      localW ^= 12'h9;
      localW[2] = 1'b1;
    end
    ee = int'(localW);
  endtask
endpackage

module Omega2_mod (input logic clkS, input logic [7:0] datI, output logic [7:0] datO);
  logic [7:0] modVecA;
  logic [7:0] modVecB;
  logic [7:0] modVecC;

  // BLOCKING select on a module variable inside an always_comb
  always_comb begin
    modVecA = datI;
    if (datI != 8'h0) begin
      modVecA ^= 8'hA;
      modVecA[1] = 1'b1;
    end
  end

  // NONBLOCKING select on a module variable
  always_ff @(posedge clkS) begin
    if (datI != 8'h1) begin
      modVecB <= modVecB ^ 8'hB;
      modVecB[2] <= 1'b1;
    end
  end

  // an INITIAL block-item local
  initial begin
    bit [9:0] blkLocal;
    blkLocal = 10'h1;
    if (datI != 8'h2) begin
      blkLocal ^= 10'h2;
      blkLocal[3] = 1'b1;
    end
    modVecC = 8'(blkLocal);
  end

  // a MODULE-scope function whose local is selected
  function automatic logic [7:0] modFn(logic [7:0] ff);
    logic [7:0] fnLocal;
    fnLocal = ff;
    if (ff != 8'h3) begin
      fnLocal ^= 8'hC;
      fnLocal[4] = 1'b1;
    end
    modFn = fnLocal;
  endfunction

  assign datO = modFn(modVecA) ^ modVecB ^ modVecC;
endmodule
