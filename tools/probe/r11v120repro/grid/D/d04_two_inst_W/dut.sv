module child #(parameter int W = 4, parameter int N = 2, parameter type data_t = logic [W-1:0]) (input data_t [N-1:0] d_i, output logic [31:0] o);
   assign o = 32'(d_i);
endmodule
module top(input logic [31:0] x, output logic [31:0] o1, output logic [31:0] o2);
   child #(.W(8), .N(3)) u1(.d_i(x[23:0]), .o(o1));
   child #(.W(2), .N(4)) u2(.d_i(x[7:0]), .o(o2));
endmodule
