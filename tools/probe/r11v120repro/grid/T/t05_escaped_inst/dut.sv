module child #(parameter type T = logic) (input T [3:0] a, output logic [15:0] o);
   assign o = 16'(a);
endmodule
module top(input logic [31:0] x, output logic [15:0] o);
   child #(.T(logic [2:0])) \u$1 (.a(x[11:0]), .o(o));
endmodule
