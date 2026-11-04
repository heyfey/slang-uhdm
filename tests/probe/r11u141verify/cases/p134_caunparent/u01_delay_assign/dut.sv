// § contAssignLhsTsUnparented134
// case u01: a continuous assignment with a delay to a whole local struct variable
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  s_t v;
  assign #1 v = i;
  assign o = v.lo;
endmodule
