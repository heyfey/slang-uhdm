// § modParamKwTdCopy250
package p;
  typedef int pi_t;
  typedef byte pb_t;
endpackage
module top;
  import p::*;
  parameter pi_t P = 3;
  parameter p::pi_t Q = 4;
  localparam pb_t R = 5;
  int v;
  assign v = P + Q + R;
endmodule
