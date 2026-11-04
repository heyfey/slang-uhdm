// § impPaLhsDisjointClone133
package p; parameter int X = 4; endpackage
interface ifc import p::*; #(parameter int Q = X) ();
  logic [Q-1:0] d;
endinterface
module top(output logic [3:0] o);
  ifc u();
  assign u.d = '1;
  assign o = u.d;
endmodule
