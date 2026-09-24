module inner #(parameter type data_t = bit [2:0]) (input data_t [1:0] d_i, output data_t o);
  assign o = d_i[1];
endmodule
module top (input bit [5:0] d, output bit [2:0] o);
  inner u (.d_i(d), .o(o));
endmodule
