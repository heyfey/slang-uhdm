module dut #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic o);
  rt_t x [2];
  assign x[0] = a[3:0];
  assign x[1] = a[7:4];
  assign o = ^x[0] ^ ^x[1];
endmodule
