// r10v122 arm q3 - the BLOCK-CHAIN walk: which ancestor answers first.
package Sigma6_pkg;
  // s01 NAMED begin
  function automatic int Fn_named(int g1);
    bit [19:0] vecNa;
    vecNa = 20'h1;
    if (g1 != 0) begin : lblOne
      vecNa ^= 20'h2;
      vecNa[3] = 1'b1;
    end
    Fn_named = int'(vecNa);
  endfunction

  // s02 TWO levels out - the ref is deeper than the select
  function automatic int Fn_twoOut(int g2);
    bit [19:0] vecNb;
    vecNb = 20'h3;
    if (g2 != 1) begin
      vecNb[5] = 1'b1;
      if (g2 > 2) begin
        vecNb ^= 20'h4;
      end
    end
    Fn_twoOut = int'(vecNb);
  endfunction

  // s03 an INNER block's select is INVISIBLE to an outer ref - NEGATIVE
  function automatic int Fn_innerHidden(int g3);
    bit [19:0] vecNc;
    vecNc = 20'h5;
    if (g3 != 2) begin
      if (g3 > 3) begin
        vecNc[6] = 1'b1;
      end
      vecNc ^= 20'h6;
    end
    Fn_innerHidden = int'(vecNc);
  endfunction

  // s04 SHADOWING declaration in the inner block
  function automatic int Fn_shadow(int g4);
    bit [19:0] vecNd;
    vecNd = 20'h7;
    if (g4 != 3) begin
      bit [19:0] vecNd;
      vecNd ^= 20'h8;
      vecNd[7] = 1'b1;
    end
    Fn_shadow = int'(vecNd);
  endfunction

  // s05 the ref sits in a FOR body, the select two levels out
  function automatic int Fn_forBody(int g5);
    bit [19:0] vecNe;
    vecNe = 20'h9;
    if (g5 != 4) begin
      vecNe[8] = 1'b1;
      for (int ii = 0; ii < 3; ii++) begin
        vecNe ^= 20'(ii);
      end
    end
    Fn_forBody = int'(vecNe);
  endfunction

  // s06 the ref sits in a WHILE body
  function automatic int Fn_whileBody(int g6);
    bit [19:0] vecNf;
    int jj;
    vecNf = 20'hA;
    jj = 0;
    if (g6 != 5) begin
      vecNf[9] = 1'b1;
      while (jj < 2) begin
        vecNf ^= 20'hB;
        jj++;
      end
    end
    Fn_whileBody = int'(vecNf);
  endfunction

  // s07 the ref sits in a CASE item begin
  function automatic int Fn_caseItem(int g7);
    bit [19:0] vecNg;
    vecNg = 20'hC;
    if (g7 != 6) begin
      vecNg[10] = 1'b1;
      case (g7)
        7: begin vecNg ^= 20'hD; end
        default: begin vecNg |= 20'hE; end
      endcase
    end
    Fn_caseItem = int'(vecNg);
  endfunction

  // s08 the DECLARING block is reached FIRST, before a select-bearing one
  function automatic int Fn_declFirst(int g8);
    bit [19:0] vecNh;
    vecNh[11] = 1'b1;
    if (g8 != 7) begin
      begin
        bit [19:0] vecNi;
        vecNi = 20'hF;
        vecNi ^= 20'h10;
      end
      vecNh ^= 20'h11;
    end
    Fn_declFirst = int'(vecNh);
  endfunction
endpackage

module Tau8_top (input logic strobeX, output logic [7:0] outQ);
  // s09 FORK arm
  logic [7:0] forkVec;
  initial begin
    bit [7:0] fLoc;
    fLoc = 8'h1;
    fork
      begin
        fLoc ^= 8'h2;
        fLoc[3] = 1'b1;
      end
      begin
        forkVec = 8'h4;
      end
    join
    outQ = fLoc;
  end
endmodule
