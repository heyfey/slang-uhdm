module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (output logic [7:0] o, output logic [7:0] p);
  rt_t x = 8'h5a, y = 8'ha5;
  assign o = x;
  assign p = y;
endmodule
