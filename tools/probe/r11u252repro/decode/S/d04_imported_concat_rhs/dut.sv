// § impPatConcatSelReadParents252 (decode only: BlackBePipeInt #331795, golden's elaborated listing of the imported all_cfgs_gp carries no Rhs; this reduction keeps it, not reproduced)
package p;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam s_t O = '{a : 0, b : 5, c : 0};
  localparam s_t M = '{a : (O.a == 0) ? D.a : O.a, b : (O.b == 0) ? D.b : O.b, c : (O.c == 0) ? D.c : O.c};
  localparam s_t [1:0] ALL = {M, D};
endpackage
module top import p::*; #(parameter Q = 1, localparam s_t P = ALL[Q]) ();
endmodule
