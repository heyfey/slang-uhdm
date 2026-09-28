// § caseItemImpWildParamScopeName210 — c04: the module instantiated twice under a top (depth 2), items in a nested function called from a continuous assignment and from a named begin block
package tp;
  parameter logic [1:0] OPX = 2'b11;
  parameter logic [7:0] A_W = { 2'b10, 4'h?, {OPX} };
  parameter logic [7:0] B_W = { 2'b01, 4'h?, {OPX} };
endpackage
module dec_m import tp::*; (input logic [7:0] i, output int r, output int s);
  function automatic int f(logic [7:0] x);
    unique casez (x)
      A_W: return 1;
      B_W: return 2;
      default: return 0;
    endcase
  endfunction
  assign r = f(i);
  always_comb begin : blk
    casez (i)
      B_W: s = 3;
      default: s = 0;
    endcase
  end
endmodule
module dut (input logic [7:0] i, output int r1, output int r2, output int s1, output int s2);
  dec_m u1 (.i(i), .r(r1), .s(s1));
  dec_m u2 (.i(~i), .r(r2), .s(s2));
endmodule
