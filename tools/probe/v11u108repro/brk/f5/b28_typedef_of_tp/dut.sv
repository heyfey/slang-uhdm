module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  typedef rt_t my_t;
  my_t x;
  assign x = a;
  assign o = x;
endmodule
