module child #(parameter int N = 2, parameter type data_t = int) (input data_t [N-1:0] d_i, output logic [63:0] o);
   assign o = 64'(d_i);
endmodule
module top(input logic [63:0] x, output logic [63:0] o);
   child u(.d_i(x), .o(o));
endmodule
