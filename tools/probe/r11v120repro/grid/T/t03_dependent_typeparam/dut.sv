module child #(parameter type T = logic, parameter type U = T [1:0]) (input U a, output logic [15:0] o);
   assign o = 16'(a);
endmodule
module top(input logic [31:0] x, output logic [15:0] o);
   child #(.T(logic [3:0])) u(.a(x[7:0]), .o(o));
endmodule
