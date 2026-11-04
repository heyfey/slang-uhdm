module child #(parameter type T = logic, parameter type S = logic [3:0]) (input T [1:0] a, input S b, output logic [15:0] o);
   assign o = 16'(a) + 16'(b);
endmodule
module top(input logic [31:0] x, output logic [15:0] o1, output logic [15:0] o2);
   child #(logic [2:0]) u1(.a(x[5:0]), .b(x[9:6]), .o(o1));
   child #(.S(logic [7:0])) u2(.a(x[1:0]), .b(x[9:2]), .o(o2));
endmodule
