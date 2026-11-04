// § ifacePortTdCastLogicTs405
module top (input logic [15:0] x, output logic [7:0] o);
  struct packed { logic [7:0] a; logic [7:0] b; } s;
  typedef logic [$bits(s.a)-1:0] T;
  assign s = x;
  assign o = T'(x);
endmodule
