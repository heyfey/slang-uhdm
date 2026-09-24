module child #(parameter int W = 2, parameter type U = logic [W-1:0]) (input U a, output logic [15:0] o);
   assign o = 16'(a);
endmodule
module top(input logic [31:0] x, output logic [15:0] o1, output logic [15:0] o2);
   child #(.W(8)) u1(.a(x[7:0]), .o(o1));
   child #(.W(4)) u2(.a(x[3:0]), .o(o2));
endmodule
