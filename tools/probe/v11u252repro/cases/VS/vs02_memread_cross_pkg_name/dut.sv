// § memReadHomePkgKey252v
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam int X = D.a;
endpackage
package q;
  typedef struct packed { integer a; integer b; } t_t;
  localparam t_t D = '{a : 7, b : 8};
endpackage
module top import q::*; #(parameter Q = 1) (output logic [63:0] o);
  assign o = D;
endmodule
