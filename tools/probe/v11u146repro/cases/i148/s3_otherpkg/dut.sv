// § pkgTfSigRangeTopViewConst148
package q; parameter W = 4; endpackage
package p;
  function automatic logic [q::W-1:0] inc(logic [q::W-1:0] x); return x + 1; endfunction
endpackage
module top(input logic [3:0] a, output logic [3:0] b);
  assign b = p::inc(a);
endmodule
