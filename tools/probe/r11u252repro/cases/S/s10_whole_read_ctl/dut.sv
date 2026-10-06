// § impPatMemberReadParentsAll252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { int a; int b; } s_t;
  localparam s_t O = '{a : 3, b : 0};
  localparam s_t P = O;
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
