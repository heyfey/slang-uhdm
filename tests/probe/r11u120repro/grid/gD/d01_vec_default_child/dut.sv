module inner #(parameter int unsigned N = 2, parameter int unsigned W = 8,
               parameter type data_t = logic [W-1:0])
  (input data_t [N-1:0] d_i, output data_t o);
  assign o = d_i[0];
endmodule
module top (input logic [15:0] d, output logic [7:0] o);
  inner #(.N(2), .W(8)) u (.d_i(d), .o(o));
endmodule
