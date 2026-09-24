// § defNetTypedefArrayShares134
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module top(input logic c, output logic o);
  p::s_t x [4];
  assign x[1] = {c, c, c};
  assign o = x[1].b;
endmodule
