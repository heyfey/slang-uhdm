// § modParamKwTdCopy250
// typed parameters in an interface overridden at its instance, a program and a class inside the module, with a typed parameter in a generate block
package p;
  typedef shortint s_t;
  typedef time t_t;
endpackage
interface ifc #(parameter p::s_t D = 3);
  logic [D-1:0] v;
endinterface
program prg #(parameter p::t_t T = 5);
  initial #T;
endprogram
module top;
  import p::*;
  parameter s_t Q = 2;
  ifc #(.D(Q + 1)) u();
  prg #(.T(7)) pr();
  if (1) begin : gb
    localparam s_t G = Q * 2;
  end
  assign u.v = '0;
endmodule
