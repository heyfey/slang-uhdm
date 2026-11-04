module child #(parameter type T = logic) (input T [3:0] a, output logic [15:0] o);
   assign o = 16'(a);
endmodule
module mid #(parameter type M = logic [2:0]) (input logic [31:0] x, output logic [15:0] o);
   child #(.T(M)) c(.a(x[11:0]), .o(o));
endmodule
module top(input logic [31:0] x, output logic [15:0] o1, output logic [15:0] o2);
   mid m1(.x(x), .o(o1));
   mid #(.M(logic [1:0])) m2(.x(x), .o(o2));
endmodule
