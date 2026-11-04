// § unitTdLawS245
// a $unit vector typedef on a child's variable, the child instanced twice
typedef logic [3:0] nib_t;
module sub(input logic [3:0] i, output logic [3:0] o);
  nib_t v;
  assign v = ~i;
  assign o = v;
endmodule
module top(input logic [3:0] i, output logic [3:0] o1, o2);
  sub a(.i(i), .o(o1));
  sub b(.i(o1), .o(o2));
endmodule
