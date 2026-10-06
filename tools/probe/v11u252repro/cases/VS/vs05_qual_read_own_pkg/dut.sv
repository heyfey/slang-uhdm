// § impPatMemberReadParentsAll252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam integer X = p::D.b + 1;
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = X + D.c;
endmodule
