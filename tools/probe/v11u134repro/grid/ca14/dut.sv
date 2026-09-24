// § contAssignLhsTsUnparented134
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef struct packed { e_t k; logic [3:0] d; } s_t;
endpackage
module m1(input logic c, output logic [1:0] o);
  import p::*;
  s_t s;
  assign s = '{k: B, d: {4{c}}};
  assign o = s.k;
endmodule
module m2(input logic c, output logic [3:0] o);
  import p::*;
  s_t t;
  always_comb t = '{k: C, d: 4'h1};
  assign o = t.d;
endmodule
module top(input logic c, output logic [1:0] o1, output logic [3:0] o2);
  m1 u1(.c(c), .o(o1));
  m2 u2(.c(c), .o(o2));
endmodule
