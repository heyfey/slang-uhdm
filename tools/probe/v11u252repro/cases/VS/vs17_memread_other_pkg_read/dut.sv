// § impPatMemberReadParentsAll252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
endpackage
package p2;
  import p::*;
  localparam integer Y = D.b;
endpackage
module top import p::*, p2::*; #(parameter Q = 1) ();
endmodule
