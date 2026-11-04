// § contAssignLhsTsUnparented134
// case u02: a whole-struct continuous assignment inside a generate-for to an array element of a module struct net
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  s_t v [2];
  for (genvar k = 0; k < 2; k++) begin : g
    assign v[k] = i;
  end
  assign o = v[1].hi;
endmodule
