// § pkgTfSigRangeTopViewConst148
package p;
  parameter A = 3;
  parameter W = A + 1;
  function automatic logic [W-1:0] inc(logic [W-1:0] x); return x + 1; endfunction
endpackage
module top(input logic [3:0] a, output logic [3:0] b);
  import p::*;
  assign b = inc(a);
endmodule
