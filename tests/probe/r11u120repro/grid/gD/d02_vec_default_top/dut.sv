module top #(parameter int unsigned N = 2, parameter int unsigned W = 4,
             parameter type data_t = logic [W-1:0])
  (input data_t [N-1:0] d_i, output data_t o);
  assign o = d_i[1];
endmodule
