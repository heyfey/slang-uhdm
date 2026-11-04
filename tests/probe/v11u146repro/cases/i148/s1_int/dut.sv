// § pkgTfSigRangeTopViewConst148
package p;
  localparam int W = 4;
  function automatic logic [W-1:0] inc(logic [W-1:0] x); return x + 1; endfunction
endpackage
module top(input logic [3:0] a, output logic [3:0] b);
  assign b = p::inc(a);
endmodule
