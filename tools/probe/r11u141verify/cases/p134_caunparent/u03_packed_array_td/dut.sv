// § contAssignLhsTsUnparented134
// case u03: LHS typed by a packed-array typedef of a struct typedef
module top(input logic [15:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  typedef s_t [1:0] arr_t;
  arr_t v;
  assign v = i;
  assign o = v[1].lo;
endmodule
