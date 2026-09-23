module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input rt_t [1:0] a, output logic [15:0] o);
  assign o = a;
endmodule
