module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input wire rt_t a, output logic [7:0] o);
  assign o = a;
endmodule
