module child #(parameter int N = 2, parameter type data_t = logic signed [3:0]) (input data_t [N-1:0] d_i, output logic signed [31:0] o);
   assign o = d_i[0] + d_i[N-1];
endmodule
module top(input logic [31:0] x, output logic signed [31:0] o);
   child #(.N(4)) u(.d_i(x[15:0]), .o(o));
endmodule
