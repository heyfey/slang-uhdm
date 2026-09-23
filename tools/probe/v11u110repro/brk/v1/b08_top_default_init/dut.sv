module dut #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic o);
  rt_t x = 4'h5;
  assign o = ^x ^ ^a;
endmodule
