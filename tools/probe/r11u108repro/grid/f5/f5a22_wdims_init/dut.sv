module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (output logic [15:0] o);
  rt_t [1:0] x = 16'h5a5a;
  assign o = x;
endmodule
