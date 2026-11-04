module inner #(parameter type data_t = logic [3:0]) (input data_t [1:0] d_i, output data_t o);
  assign o = d_i[0] ^ d_i[1];
endmodule
module top (input logic [11:0] d, output logic [5:0] o);
  inner #(.data_t(logic [5:0])) u (.d_i(d), .o(o));
endmodule
