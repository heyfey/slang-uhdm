// § pkgTfSigRangeTopViewConst148
package p;
  parameter W = 4;
  task automatic t(input logic [W-1:0] x, output logic [W-1:0] y); y = x; endtask
endpackage
module top(input logic [3:0] a, output logic [3:0] b);
  always_comb p::t(a, b);
endmodule
