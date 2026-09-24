module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0], parameter type T2 = rt_t) (input logic [7:0] a, output logic [7:0] o);
  T2 x;
  assign x = a;
  assign o = x;
endmodule
