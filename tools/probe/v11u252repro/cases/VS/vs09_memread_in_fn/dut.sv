// § impPatMemberReadParentsAll252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  function automatic integer f(); return D.a; endfunction
  localparam s_t G = '{a : 9, b : 8, c : 7};
  localparam integer Y = (1 == 0) ? G.a : D.c;
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = f() + Y;
endmodule
