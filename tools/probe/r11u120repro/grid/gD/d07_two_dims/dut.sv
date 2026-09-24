module inner #(parameter type data_t = logic [1:0]) (input data_t [1:0][1:0] d_i, output data_t o);
  assign o = d_i[1][0];
endmodule
module top (input logic [7:0] d, output logic [1:0] o);
  inner u (.d_i(d), .o(o));
endmodule
