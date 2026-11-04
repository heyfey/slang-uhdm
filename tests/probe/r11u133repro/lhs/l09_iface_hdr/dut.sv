// § impPaLhsDisjointClone133
package p; parameter int X = 4; endpackage
interface ifc import p::*; #(parameter int Q = X) ();
  logic [Q-1:0] d;
endinterface
module top(output int o);
  ifc u();
  assign o = $bits(u.d);
endmodule
