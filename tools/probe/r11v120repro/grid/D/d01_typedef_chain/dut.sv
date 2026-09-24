typedef logic [7:0] byte_t;
module child #(parameter int N = 2, parameter type data_t = byte_t) (input data_t [N-1:0] d_i, output logic [31:0] o);
   assign o = 32'(d_i);
endmodule
module top(input logic [31:0] x, output logic [31:0] o);
   child #(.N(3)) u(.d_i(x[23:0]), .o(o));
endmodule
