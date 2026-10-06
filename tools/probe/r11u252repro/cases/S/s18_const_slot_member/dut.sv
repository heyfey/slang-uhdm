// § impPatMemberReadParentsAll252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { int a; int b; } s_t;
  localparam s_t O = '{a : 3, b : 0};
endpackage
module top import p::*; #(parameter Q = 1) ();
  logic [O.a:0] v;
  logic [7:0] w;
  assign w = {O.a{1'b1}};
  assign v = w[O.a -: 2];
endmodule
