module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x [2];
  assign x[0] = a;
  assign x[1] = a;
  assign o = x[1];
endmodule
