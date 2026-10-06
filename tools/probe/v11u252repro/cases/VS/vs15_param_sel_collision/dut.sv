// § concatSelInParamInit252v
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam s_t E = '{a : 4, b : 5, c : 6};
  localparam s_t [1:0] ALL = {E, D};
endpackage
module top import p::*; #(parameter Q = 1, parameter logic [3:0] ALL = 4'h3, parameter logic Z = ALL[1]) ();
endmodule
