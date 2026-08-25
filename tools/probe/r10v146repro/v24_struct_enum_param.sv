// Parameter TYPES: packed struct, enum, packed array, and a parameter whose
// value is an aggregate, all through a $unit import.
package pv24;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  typedef enum logic [1:0] { E0 = 0, E1 = 1 } e_t;
  parameter st_t         P_ST  = '{a:4'h1, b:4'h2};
  parameter e_t          P_EN  = E1;
  parameter logic [7:0]  P_ARR [0:1] = '{8'h11, 8'h22};
  parameter int          P_I   = 3;
endpackage
import pv24::*;
module top_v24;
  st_t s; e_t e; int q;
  assign s = P_ST;
  assign e = P_EN;
  initial q = P_I + P_ARR[0];
endmodule
