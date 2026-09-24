module child(d_i, o);
   parameter int N = 2;
   parameter type data_t = logic [3:0];
   input data_t [N-1:0] d_i;
   output logic [31:0] o;
   assign o = 32'(d_i);
endmodule
module top(input logic [31:0] x, output logic [31:0] o);
   child #(.N(3)) u(.d_i(x[11:0]), .o(o));
endmodule
