// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
package b;
  import a::*;
  parameter int W = 4;
endpackage
module top(input logic [2:0] i, output logic [3:0] o);
  import b::*;
  import a::*;
  e_t s;
  assign s = e_t'(i);
  assign o = (s == N1) ? W[3:0] : 4'h0;
endmodule
