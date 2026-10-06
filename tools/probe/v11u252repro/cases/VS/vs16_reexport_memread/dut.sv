// § memReadHomePkgKey252v
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam integer X = D.a;
endpackage
package q;
  import p::*;
  export p::*;
  localparam integer QX = X;
  localparam s_t QD = D;
endpackage
module top import q::*; #(parameter Q = 1) ();
  localparam integer Y = X;
endmodule
